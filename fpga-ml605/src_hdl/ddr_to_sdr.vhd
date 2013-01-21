-------------------------------------------------------------------------------
--  CRUSH
--  Cognitive Radio Universal Software Hardware
--  http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php
-- 
--  File: ddr_to_sdr.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Converts DDR input data (data transitions on both rising and 
--               falling edges) to SDR data (data transition only on rising
--               edge). Uses a phase shifted clock derived from a MMCM
--               to properly clock the DDR data in at the center of the data
--               eye. As a consequence of this design method, the MMCM's
--               phase shift must be calibrated and the MMCM MUST BE LOCKED 
--               down with a location constraint.
--               
--               The MMCM phase can be shifted in 1/56th steps of the
--               VCO frequency.
--               
--               Note: It is expected that clk_sdr freq >= clk_ddr freq.
--                     If clk_sdr freq < clk_ddr freq, data will be lost
--                     when the buffer FIFO overflows.
--               
--               Input Bit Width Customization?
--               Input data is assumed to be no more than 18 bits wide. This 
--               can be changed, but the buffer FIFO will need to be 
--               regenerated with a wider bitwidth.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ddr_to_sdr is
  generic (
    BIT_WIDTH         : integer;                                      -- Input data width
    USE_PHASE_SHIFT   : std_logic;                                    -- '1' = Init MMCM phase on reset
    PHASE_SHIFT       : integer);                                     -- MMCM phase shift tap setting (0 - 55)
  port (
    reset             : in    std_logic;                              -- Active high reset
    -- Calibrate MMCM Phase
    clk_mmcm_psen     : in    std_logic;                              -- MMCM phase shift clock
    phase_inc_stb     : in    std_logic;                              -- Increment MMCM phase
    phase_dec_stb     : in    std_logic;                              -- Decrement MMCM phase
    phase_cnt         : out   std_logic_vector(5 downto 0);           -- Current phase shift, 0 - 55.
    -- DDR interface
    ddr_data_clk      : in    std_logic;                              -- DDR data clock (from pin)
    ddr_data          : in    std_logic_vector(BIT_WIDTH-1 downto 0); -- DDR data (from pin)
    clk_ddr           : out   std_logic;                              -- MMCM derived DDR clock
    clk_ddr_locked    : out   std_logic;                              -- MMCM DDR data clock locked
    -- SDR interface
    clk_sdr           : in    std_logic;                              -- SDR data clock
    sdr_data_vld      : out   std_logic;                              -- '1' = SDR data valid 
    sdr_data          : out   std_logic_vector((2*BIT_WIDTH)-1 downto 0));
end entity;

architecture RTL of ddr_to_sdr is

-------------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------------
  component BUFR is
    generic (
      BUFR_DIVIDE               : string;           -- "BYPASS", "1", "2", "3", "4", "5", "6", "7", "8"
      SIM_DEVICE                : string);          -- Specify target device, "VIRTEX4", "VIRTEX5", "VIRTEX6"
    port (
      O                         : out   std_logic;  -- Clock buffer output
      CE                        : in    std_logic;  -- Clock enable input
      CLR                       : in    std_logic;  -- Clock buffer reset input
      I                         : in    std_logic); -- Clock buffer input
  end component;

  component mmcm_ddr_to_sdr is
    port (
      CLKIN_100MHz              : in     std_logic;
      CLKOUT_100MHz             : out    std_logic;
      -- Dynamic phase shift ports
      PSCLK                     : in     std_logic;
      PSEN                      : in     std_logic;
      PSINCDEC                  : in     std_logic;
      PSDONE                    : out    std_logic;
      -- Status and control signals
      RESET                     : in     std_logic;
      LOCKED                    : out    std_logic);
  end component;

  component IDDR is
    generic (
      DDR_CLK_EDGE              : string;           -- "OPPOSITE_EDGE", "SAME_EDGE"
                                                    -- or "SAME_EDGE_PIPELINED"
      INIT_Q1                   : std_logic;        -- Initial value of Q1: '0' or '1'
      INIT_Q2                   : std_logic;        -- Initial value of Q2: '0' or '1'
      SRTYPE                    : string);          -- Set/Reset type: "SYNC" or "ASYNC"
    port (
      Q1                        : out   std_logic;  -- Output for positive edge of clock
      Q2                        : out   std_logic;  -- Output for negative edge of clock
      C                         : in    std_logic;  -- Clock input
      CE                        : in    std_logic;  -- Clock enable input
      D                         : in    std_logic;  -- DDR data input
      R                         : in    std_logic;  -- Reset
      S                         : in    std_logic); -- Set
  end component;

  component fifo_36x16 is
    port (
      rst                       : in std_logic;
      wr_clk                    : in std_logic;
      rd_clk                    : in std_logic;
      din                       : in std_logic_vector(35 downto 0);
      wr_en                     : in std_logic;
      rd_en                     : in std_logic;
      dout                      : out std_logic_vector(35 downto 0);
      full                      : out std_logic;
      almost_full               : out std_logic;
      empty                     : out std_logic;
      almost_empty              : out std_logic;
      valid                     : out std_logic;
      underflow                 : out std_logic);
  end component;

-------------------------------------------------------------------------------
-- Signal Declaration
-------------------------------------------------------------------------------
  type state_type is (IDLE,WAIT_FOR_DONE);
  signal state                  : state_type;

  signal ddr_data_clk_bufr      : std_logic;
  signal clk_ddr_locked_int     : std_logic;
  signal psen                   : std_logic;
  signal psincdec               : std_logic;
  signal psdone                 : std_logic;
  signal phase_cnt_int          : integer;
  signal phase_init             : std_logic;
  signal ddr_data_rising        : std_logic_vector(BIT_WIDTH-1 downto 0);
  signal ddr_data_falling       : std_logic_vector(BIT_WIDTH-1 downto 0);
  signal ddr_data_concatenated  : std_logic_vector((2*BIT_WIDTH)-1 downto 0);
  signal ddr_data_fifo          : std_logic_vector(35 downto 0);

begin

  -- Use a BUFR to buffer the DDR data clk
  BUFR_inst : BUFR
    generic map (
      BUFR_DIVIDE               => "BYPASS",
      SIM_DEVICE                => "VIRTEX6")
    port map (
      I                         => ddr_data_clk,
      CE                        => '1',
      CLR                       => '0',
      O                         => ddr_data_clk_bufr);

  -- Route BUFR DDR data clock to MMCM to generate a phase shifted
  -- global clock whose rising edge is ideally in the middle of
  -- the DDR data "eye"
  mmcm_ddr_to_sdr_inst : mmcm_ddr_to_sdr
    port map (
      CLKIN_100MHz              => ddr_data_clk_bufr,
      CLKOUT_100MHz             => clk_ddr,
      PSCLK                     => clk_mmcm_psen,
      PSEN                      => psen,
      PSINCDEC                  => psincdec,
      PSDONE                    => psdone,
      RESET                     => reset,
      LOCKED                    => clk_ddr_locked_int);

  clk_ddr_locked                <= clk_ddr_locked_int;

  -- MMCM dynamic phase shift state machine
  mmcm_phase_shift_proc : process(clk_mmcm_psen,reset)
  begin
    if rising_edge(clk_mmcm_psen) then
      if (reset = '1') then
        phase_cnt_int           <= 0;
        phase_init              <= '0';
        state                   <= IDLE;
      else
        case state is
          when IDLE =>
            psen                <= '0';
            if (USE_PHASE_SHIFT = '1' AND phase_init = '0') then
              if (phase_cnt_int <= PHASE_SHIFT) then
                psincdec        <= '1';
                psen            <= '1';
                state           <= WAIT_FOR_DONE;
              else
                phase_init      <= '1';
              end if;
            end if;
            if (phase_inc_stb = '1') then
              psincdec          <= '1';
              psen              <= '1';
              -- MMCM phase shift only have 56 taps before rolling over
              if (phase_cnt_int < 55) then
                phase_cnt_int   <= phase_cnt_int + 1;
              else
                phase_cnt_int   <= 0;
              end if;
            end if;
            if (phase_dec_stb = '1') then
              psincdec          <= '0';
              psen              <= '1';
              if (phase_cnt_int > 0) then
                phase_cnt_int   <= phase_cnt_int - 1;
              else
                phase_cnt_int   <= 55;
              end if;
            end if;

          when WAIT_FOR_DONE =>
            psen                <= '0';
            if (psdone = '1') then
              state             <= IDLE;
            end if;

          when others =>
            state               <= IDLE;
        end case;
      end if;
    end if;
  end process;
  phase_cnt                     <= std_logic_vector(to_unsigned(phase_cnt_int,6));

  -- IDDR primative instantiation
  IDDR_gen : for i in 0 to BIT_WIDTH-1 generate
    IDDR_inst : IDDR
      generic map (
        DDR_CLK_EDGE            => "SAME_EDGE_PIPELINED",
        INIT_Q1                 => '0',
        INIT_Q2                 => '0',
        SRTYPE                  => "ASYNC")
      port map (
        Q1                      => ddr_data_rising(i),
        Q2                      => ddr_data_falling(i),
        C                       => clk_ddr_mmcm,
        CE                      => '1',
        D                       => ddr_data(i),
        R                       => clk_ddr_locked_int,
        S                       => '0');
  end generate;

  -- This allows for variable input bitwidths without having to regenerate
  -- the buffer FIFO. If the DDR data bitwidth is larger than 18 bits, the
  -- FIFO will need to be regenerated.
  ddr_data_concatenated         <= ddr_data_rising & ddr_data_falling;
  ddr_data_fifo_gen : for j in 0 to 35 generate
    ddr_data_fifo(j)            <= ddr_data_concatenated(j) when (j < 2*BIT_WIDTH) else '0';
  end generate;

  almost_full_n                 <= NOT(almost_full);
  almost_empty_n                <= NOT(almost_empty);

  -- Clock crossing and buffering FIFO. 
  fifo_36x16_inst : fifo_36x16
    port map (
      rst                       => clk_ddr_locked_int,
      wr_clk                    => clk_ddr,
      rd_clk                    => clk_sdr,
      din                       => ddr_data_fifo,
      wr_en                     => almost_full_n,
      rd_en                     => almost_empty,
      dout                      => sdr_data_fifo,
      full                      => open,
      almost_full               => almost_full,
      empty                     => open,
      almost_empty              => almost_empty,
      valid                     => open,
      underflow                 => open);

  -- Better timing performance when outputs are registered
  proc_sdr_data_reg : process(clk_sdr)
  begin
    if rising_edge(clk_sdr) then
      sdr_data_vld              <= almost_empty_n;
      sdr_data                  <= sdr_data_fifo((2*BIT_WIDTH)-1 downto 0);
    end if;
  end process;

end architecture;