-------------------------------------------------------------------------------
--  CRUSH
--  Cognitive Radio Universal Software Hardware
--  http://www.coe.neu.edu/Research/rcl//projects/CRUSH.php
--  
--  CRUSH is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--  
--  CRUSH is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--  
--  You should have received a copy of the GNU General Public License
--  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--  
--  
--  File: usrp_ddr_intf.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Interfaces transmit and receive data between the FPGA 
--               development board and the USRP N2xx. 
--
--               Converts DDR input data (data transitions on both rising and 
--               falling edges) to SDR data (data transition only on rising
--               edge). To conserve pins at the physical interface, the DDR
--               data runs at twice the SDR data rate. This means the SDR
--               data is split across two clocks, i.e. for 16-bit data the 
--               upper byte is sent first, then the lower byte second. 
--               
--               Uses a phase shifted clock derived from a MMCM
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
--
--               Asserting ddr_data_stall will cause the DDR data to stall for
--               one clock cycle. This results realigning the DDR data by losing
--               one clock cycle worth of data. This is necessary as the DDR 
--               data words are spread across two clock cycles and may not be 
--               properly aligned.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library unisim;
use unisim.vcomponents.all;

entity usrp_ddr_intf is
  generic (
    USE_PHASE_SHIFT         : boolean := FALSE;       -- "TRUE/FALSE", Init MMCM phase to MAN_PHASE_SHIFT on reset
    USE_CUSTOM_PCB_FIX      : boolean := FALSE;       -- "TRUE/FALSE", Fix polarity issue due to incorrect PCB routing
    MAN_PHASE_SHIFT         : integer := 0);          -- MMCM phase shift tap setting (0 - 549)
  port (
    reset                   : in    std_logic;                      -- Asynchronous reset
    -- USRP DDR interface control via UART (sampled by clk_ddr clock domain)
    user_ddr_intf_mode      : in    std_logic_vector(7 downto 0);   -- USRP DDR interface mode
    user_ddr_intf_mode_stb  : in    std_logic;                      -- Strobe to set mode
    UART_TX                 : out   std_logic;                      -- UART
    -- Physical Transmit / Receive data interface
    RX_DATA_CLK_N           : in    std_logic;                      -- Receive data clock (N)
    RX_DATA_CLK_P           : in    std_logic;                      -- Receive data clock (P)
    RX_DATA_N               : in    std_logic_vector(6 downto 0);   -- Receive data (N)
    RX_DATA_P               : in    std_logic_vector(6 downto 0);   -- Receive data (N)
    TX_DATA_N               : out   std_logic_vector(7 downto 0);   -- Transmit data (N)
    TX_DATA_P               : out   std_logic_vector(7 downto 0);   -- Transmit data (P)
    clk_ddr                 : out   std_logic;                      -- MMCM derived clock
    clk_ddr_2x              : out   std_logic;                      -- MMCM derived clock (2x)
    clk_ddr_locked          : out   std_logic;                      -- MMCM DDR data clock locked
    clk_ddr_phase           : out   std_logic_vector(9 downto 0);   -- MMCM phase offset, 0 - 559
    -- Receive data FIFO interface
    clk_rx_fifo             : in    std_logic;                      -- Receive data FIFO clock
    rx_fifo_reset           : in    std_logic;                      -- Receive data FIFO reset
    rx_fifo_data_i          : out   std_logic_vector(13 downto 0);  -- Receive data FIFO output
    rx_fifo_data_q          : out   std_logic_vector(13 downto 0);  -- Receive data FIFO output
    rx_fifo_rd_en           : in    std_logic;                      -- Receive data FIFO read enable
    rx_fifo_underflow       : out   std_logic;                      -- Receive data FIFO underflow
    rx_fifo_almost_empty    : out   std_logic;                      -- Receive data FIFO almost empty
    -- Receive data FIFO interface
    clk_tx_fifo             : in    std_logic;                      -- Transmit data FIFO clock
    tx_fifo_reset           : in    std_logic;                      -- Transmit data FIFO reset
    tx_fifo_data_i          : in    std_logic_vector(15 downto 0);  -- Transmit data FIFO output
    tx_fifo_data_q          : in    std_logic_vector(15 downto 0);  -- Transmit data FIFO output
    tx_fifo_wr_en           : in    std_logic;                      -- Transmit data FIFO write enable
    tx_fifo_overflow        : out   std_logic;                      -- Transmit data FIFO overflow
    tx_fifo_almost_full     : out   std_logic);                     -- Transmit data FIFO almost full
end entity;

architecture RTL of usrp_ddr_intf is

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

  component edge_detect
    generic (
      EDGE                      : string  := "RISING"); -- Rising, Falling, or Both
    port (
      clk                       : in    std_logic;
      reset                     : in    std_logic;
      input_detect              : in    std_logic;      -- Input data
      edge_detect_stb           : out   std_logic);     -- Edge detected strobe
  end component;

  component mmcm_ddr_to_sdr is
    port (
      CLKIN_100MHz              : in     std_logic;
      CLKOUT_100MHz             : out    std_logic;
      CLKOUT_200MHz             : out    std_logic;
      -- Dynamic phase shift ports
      PSCLK                     : in     std_logic;
      PSEN                      : in     std_logic;
      PSINCDEC                  : in     std_logic;
      PSDONE                    : out    std_logic;
      -- Status and control signals
      RESET                     : in     std_logic;
      LOCKED                    : out    std_logic);
  end component;

  component fifo_36x512 is
    port (
      wr_rst                    : in std_logic;
      wr_clk                    : in std_logic;
      rd_rst                    : in std_logic;
      rd_clk                    : in std_logic;
      din                       : in std_logic_vector(35 downto 0);
      wr_en                     : in std_logic;
      rd_en                     : in std_logic;
      dout                      : out std_logic_vector(35 downto 0);
      full                      : out std_logic;
      almost_full               : out std_logic;
      empty                     : out std_logic;
      almost_empty              : out std_logic;
      overflow                  : out std_logic;
      underflow                 : out std_logic);
  end component;

  component uart is
    generic (
      CLOCK_FREQ        : integer := 100e6;           -- Input clock frequency (Hz)
      BAUD              : integer := 115200;          -- Baud rate (bits/sec)
      DATA_BITS         : integer := 8;               -- Number of data bits
      PARITY            : string  := "MARK";          -- EVEN, ODD, MARK (always = '1'), SPACE (always = '0'), NONE
      NO_STROBE_ON_ERR  : string  := "TRUE");         -- No rx_data_stb if error in received data.
    port (
      clk               : in    std_logic;            -- Clock
      reset             : in    std_logic;            -- Active high reset
      tx_busy           : out   std_logic;            -- Transmitting data
      tx_data_stb       : in    std_logic;            -- Transmit buffer load and begin transmission strobe
      tx_data           : in    std_logic_vector(DATA_BITS-1 downto 0);
      rx_busy           : out   std_logic;            -- Receiving data
      rx_data_stb       : out   std_logic;            -- Receive buffer data valid strobe
      rx_data           : out   std_logic_vector(DATA_BITS-1 downto 0);
      rx_error          : out   std_logic;            -- '1' = Invalid parity bit, start bit, or stop bit(s)
      tx                : out   std_logic;            -- TX output
      rx                : in    std_logic);           -- RX input
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  -- RX modes (lower nibble)
  constant RX_ADC_RAW_MODE          : std_logic_vector(3 downto 0) := x"0";
  constant RX_ADC_DSP_MODE          : std_logic_vector(3 downto 0) := x"1";
  constant RX_SINE_TEST_MODE        : std_logic_vector(3 downto 0) := x"2";
  constant RX_TEST_PATTERN_MODE     : std_logic_vector(3 downto 0) := x"3";
  constant RX_ALL_1s_MODE           : std_logic_vector(3 downto 0) := x"4";
  constant RX_ALL_0s_MODE           : std_logic_vector(3 downto 0) := x"5";
  constant RX_CHA_1s_CHB_0s_MODE    : std_logic_vector(3 downto 0) := x"6";
  constant RX_CHA_0s_CHB_1s_MODE    : std_logic_vector(3 downto 0) := x"7";
  constant RX_CHECK_ALIGN_MODE      : std_logic_vector(3 downto 0) := x"8";
  constant RX_TX_LOOPBACK_MODE      : std_logic_vector(3 downto 0) := x"9";
  -- TX modes (upper nibble)
  constant TX_PASSTHRU_MODE         : std_logic_vector(3 downto 0) := x"0";
  constant TX_DAC_RAW_MODE          : std_logic_vector(3 downto 0) := x"1";
  constant TX_DAC_DSP_MODE          : std_logic_vector(3 downto 0) := x"2";
  constant TX_SINE_TEST_MODE        : std_logic_vector(3 downto 0) := x"3";

  -------------------------------------------------------------------------------
  -- Signal Declaration
  -------------------------------------------------------------------------------
  type state_type is (IDLE, SET_RX_TEST_MODE, WAIT_FOR_UART_DONE,
                      CHECK_DDR_DATA, STORE_BEST_PHASE, SET_NEXT_PHASE,
                      WAIT_FOR_NEXT_PHASE, SET_BEST_PHASE, WAIT_BEST_PHASE,
                      SET_RX_CHECK_ALIGN, WAIT_FOR_UART_DONE2, 
                      CHECK_DATA_ALIGNMENT, SET_DATA_ALIGNMENT);
  signal state                      : state_type;

  signal clk_ddr_int                : std_logic;
  signal clk_ddr_2x_int             : std_logic;
  signal ddr_data_clk               : std_logic;
  signal ddr_data_clk_bufr          : std_logic;
  signal clk_ddr_locked_int         : std_logic;
  signal clk_ddr_locked_n           : std_logic;
  signal psen                       : std_logic;
  signal psincdec                   : std_logic;
  signal psdone                     : std_logic;
  signal tx_busy                    : std_logic;
  signal ddr_data_stall_stb         : std_logic;
  signal ddr_intf_mode              : std_logic_vector(7 downto 0);
  signal ddr_intf_mode_stb          : std_logic;
  signal phase_init                 : std_logic;
  signal best_phase                 : integer range 0 to 549;
  signal mmcm_phase                 : integer range 0 to 549;
  signal error_cnt                  : integer range 0 to 8192;
  signal best_phase_error_cnt       : integer range 0 to 8192;
  signal word_cnt                   : integer range 0 to 8192;
  signal align_a_cnt                : integer range 0 to 8192;
  signal align_b_cnt                : integer range 0 to 8192;

  signal rx_data_a                  : std_logic_vector(13 downto 0);
  signal rx_data_b                  : std_logic_vector(13 downto 0);
  signal rx_data_2x_a               : std_logic_vector( 6 downto 0);
  signal rx_data_2x_b               : std_logic_vector( 6 downto 0);
  signal rx_data_2x_ddr             : std_logic_vector( 6 downto 0);
  signal rx_fifo_almost_full        : std_logic;
  signal rx_fifo_almost_full_n      : std_logic;
  signal rx_fifo_din                : std_logic_vector(35 downto 0);
  signal rx_fifo_dout               : std_logic_vector(35 downto 0);

  signal ping_pong                  : std_logic;
  signal tx_data_a                  : std_logic_vector(15 downto 0);
  signal tx_data_b                  : std_logic_vector(15 downto 0);
  signal tx_data_2x_a               : std_logic_vector( 7 downto 0);
  signal tx_data_2x_b               : std_logic_vector( 7 downto 0);
  signal tx_data_2x_ddr             : std_logic_vector( 7 downto 0);
  signal tx_fifo_almost_empty       : std_logic;
  signal tx_fifo_almost_empty_n     : std_logic;
  signal tx_fifo_din                : std_logic_vector(35 downto 0);
  signal tx_fifo_dout               : std_logic_vector(35 downto 0);

  attribute keep                          : string;
  attribute keep of best_phase            : signal is "TRUE";
  attribute keep of best_phase_error_cnt  : signal is "TRUE";

begin

  inst_rx_clk_IBUFDS : IBUFDS
    generic map (
      DIFF_TERM                     => TRUE,
      IOSTANDARD                    => "DEFAULT")
    port map (
      I                             => RX_DATA_CLK_P,
      IB                            => RX_DATA_CLK_N,
      O                             => ddr_data_clk);

    -- Use a BUFR to buffer the DDR data clk
  inst_BUFR : BUFR
    generic map (
      BUFR_DIVIDE                   => "BYPASS",
      SIM_DEVICE                    => "VIRTEX6")
    port map (
      I                             => ddr_data_clk,
      CE                            => '1',
      CLR                           => '0',
      O                             => ddr_data_clk_bufr);

  -- Route BUFR DDR data clock to MMCM to generate a phase shifted
  -- global clock whose rising edge is ideally in the middle of
  -- the DDR data "eye"
  inst_mmcm_ddr_to_sdr : mmcm_ddr_to_sdr
    port map (
      CLKIN_100MHz                  => ddr_data_clk_bufr,
      CLKOUT_100MHz                 => clk_ddr_int,
      CLKOUT_200MHz                 => clk_ddr_2x_int,
      PSCLK                         => clk_ddr_int,
      PSEN                          => psen,
      PSINCDEC                      => psincdec,
      PSDONE                        => psdone,
      RESET                         => reset,
      LOCKED                        => clk_ddr_locked_int);

  clk_ddr                           <= clk_ddr_int;
  clk_ddr_2x                        <= clk_ddr_2x_int;
  clk_ddr_locked                    <= clk_ddr_locked_int;
  clk_ddr_locked_n                  <= NOT(clk_ddr_locked_int);
  clk_ddr_phase                     <= std_logic_vector(to_unsigned(best_phase,10));

  -- UART to set receive and transmit modes
  inst_uart : uart
    generic map (
      CLOCK_FREQ                    => 100e6,
      BAUD                          => 115200,
      DATA_BITS                     => 8,
      PARITY                        => "EVEN",
      NO_STROBE_ON_ERR              => "TRUE")
    port map (
      clk                           => clk_ddr_int,
      reset                         => clk_ddr_locked_n,
      tx_busy                       => tx_busy,
      tx_data_stb                   => ddr_intf_mode_stb,
      tx_data                       => ddr_intf_mode,
      rx_busy                       => open,
      rx_data_stb                   => open,
      rx_data                       => open,
      rx_error                      => open,
      tx                            => UART_TX,
      rx                            => '1');

  -- Calibrate interface in two ways:
  -- 1) Adjust phase so we sample at the center of the data bit. This is done in a 
  --    rudamentary way by choosing the phase with the lowest number of bit errors
  --    in 1 bits. The entire process takes approximately (10e3/200e6)
  --    = 28 ms. This process is overriden by USE_PHASE_SHIFT = "TRUE" and the MMCM
  --    phase shift is set to PHASE_SHIFT.
  -- 2) The DDR data is split across two clock cycles, which means we may erroneously
  --    capture the lower word as the upper word. This is corrected by recognizing
  --    this situation and stalling the data for one clock cycle.
  proc_calibrate : process(clk_ddr_int,clk_ddr_locked_n)
  begin
    if rising_edge(clk_ddr_int) then
      if (clk_ddr_locked_n = '1') then
        ddr_data_stall_stb          <= '0';
        ddr_intf_mode               <= (others=>'0');
        ddr_intf_mode_stb           <= '0';
        phase_init                  <= '0';
        best_phase                  <= 0;
        mmcm_phase                  <= 0;
        error_cnt                   <= 0;
        word_cnt                    <= 0;
        best_phase_error_cnt        <= 0;
        align_a_cnt                 <= 0;
        align_b_cnt                 <= 0;
        psincdec                    <= '1';
        psen                        <= '0';
        state                       <= IDLE;
      else
        -- Ensure strobes last only one clock cycle
        ddr_data_stall_stb          <= '0';
        ddr_intf_mode_stb           <= '0';

        case state is
          when IDLE =>
            -- Only forward USRP DDR interface mode changes when
            -- we are not calibrating the interface.
            ddr_intf_mode           <= user_ddr_intf_mode;
            ddr_intf_mode_stb       <= user_ddr_intf_mode_stb;
            if (phase_init = '0') then
              if (USE_PHASE_SHIFT = TRUE) then
                best_phase          <= MAN_PHASE_SHIFT;
                state               <= SET_BEST_PHASE;
              else
                best_phase          <= 0;
                state               <= SET_RX_TEST_MODE;
              end if;
            end if;

          when SET_RX_TEST_MODE =>
            ddr_intf_mode           <= TX_PASSTHRU_MODE & RX_CHA_1s_CHB_0s_MODE;
            ddr_intf_mode_stb       <= '1';
            if (tx_busy = '1') then
              state                 <= WAIT_FOR_UART_DONE;
            end if;

          when WAIT_FOR_UART_DONE =>
            ddr_intf_mode_stb       <= '0';
            if (tx_busy = '0') then
              state                 <= CHECK_DDR_DATA;
            end if;

          when CHECK_DDR_DATA =>
            if (rx_data_a /= "11111111111111" OR rx_data_b /= "00000000000000") then
              error_cnt             <= error_cnt + 1;
            end if;
            if (word_cnt = 8191) then
              word_cnt              <= 0;
              state                 <= STORE_BEST_PHASE;
            else
              word_cnt              <= word_cnt + 1;
            end if;

          when STORE_BEST_PHASE =>
            if (error_cnt < best_phase_error_cnt) then
              best_phase_error_cnt  <= error_cnt;
              best_phase            <= mmcm_phase;
            end if;
            error_cnt               <= 0;
            mmcm_phase              <= mmcm_phase + 1;
            state                   <= SET_NEXT_PHASE;

          when SET_NEXT_PHASE =>
            psincdec                <= '1';
            psen                    <= '1';
            state                   <= WAIT_FOR_NEXT_PHASE;

          when WAIT_FOR_NEXT_PHASE =>
            psen                    <= '0';
            if (psdone = '1') then
              if (mmcm_phase < 549) then
                state               <= CHECK_DDR_DATA;
              else
                mmcm_phase          <= 0;
                state               <= SET_BEST_PHASE;
              end if;
            end if;

          when SET_BEST_PHASE =>
            if (mmcm_phase < best_phase) then
              psincdec              <= '1';
              psen                  <= '1';
              state                 <= WAIT_BEST_PHASE;
            else
              state                 <= SET_RX_CHECK_ALIGN;
            end if;

          when WAIT_BEST_PHASE =>
            psen                    <= '0';
            if (psdone = '1') then
              state                 <= SET_BEST_PHASE;
            end if;

          when SET_RX_CHECK_ALIGN =>
            ddr_intf_mode           <= TX_PASSTHRU_MODE & RX_CHECK_ALIGN_MODE;
            ddr_intf_mode_stb       <= '1';
            if (tx_busy = '1') then
              state                 <= WAIT_FOR_UART_DONE2;
            end if;

          when WAIT_FOR_UART_DONE2 =>
            ddr_intf_mode_stb       <= '0';
            if (tx_busy = '0') then
              state                 <= CHECK_DATA_ALIGNMENT;
            end if;

          when CHECK_DATA_ALIGNMENT =>
            if (rx_data_a = "01101101001001" AND rx_data_b = "00111001100011") then
              align_a_cnt           <= align_a_cnt + 1;
            end if;
            if (rx_data_a = "10010010110110" AND rx_data_b = "11000110011100") then
              align_b_cnt           <= align_b_cnt + 1;
            end if;
            if (word_cnt = 8191) then
              word_cnt              <= 0;
              state                 <= SET_DATA_ALIGNMENT;
            else
              word_cnt              <= word_cnt + 1;
            end if;

          when SET_DATA_ALIGNMENT =>
            if (align_a_cnt < align_b_cnt) then
              ddr_data_stall_stb    <= '1';
            end if;
            phase_init              <= '1';
            state                   <= IDLE;

          when others =>
            state                   <= IDLE;
        end case;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- LVDS DDR Data Interface, 2x Clock Domain (200 MHz)
  -- Transmit 16-bit TX I/Q data and receive 14-bit RX I/Q data at 
  -- 200 MHz DDR.
  -----------------------------------------------------------------------------

  -- Reconstruct the RX DDR data, which is split across two clocks.
  proc_reconstruct_rx_data : process(clk_ddr_2x_int)
  begin
    if rising_edge(clk_ddr_2x_int) then
      -- Stalling the data corrects for misalignment due to the data
      -- being split across two clock cycles
      if (ddr_data_stall_stb = '0') then
        rx_data_a(13 downto 7)      <= rx_data_a(6 downto 0);
        rx_data_a( 6 downto 0)      <= rx_data_2x_a;
        rx_data_b(13 downto 7)      <= rx_data_b(6 downto 0);
        rx_data_b( 6 downto 0)      <= rx_data_2x_b;
      end if;
    end if;
  end process;

  -- DDR LVDS Data Input
  gen_rx_ddr_lvds : for i in 0 to 6 generate
    inst_IDDR : IDDR
      generic map (
        DDR_CLK_EDGE                => "SAME_EDGE_PIPELINED",
        SRTYPE                      => "ASYNC")
      port map (
        Q1                          => rx_data_2x_a(i),
        Q2                          => rx_data_2x_b(i),
        C                           => clk_ddr_2x_int,
        CE                          => '1',
        D                           => rx_data_2x_ddr(i),
        R                           => clk_ddr_locked_n,
        S                           => '0');

    inst_IBUFDS : IBUFDS
      generic map (
        DIFF_TERM                   => TRUE,
        IOSTANDARD                  => "DEFAULT")
      port map (
        I                           => RX_DATA_P(i),
        IB                          => RX_DATA_N(i),
        O                           => rx_data_2x_ddr(i));
  end generate;

  -- Send TX data DDR using the receive data clock. 
  -- Crosses clock domain from 100 MHz to 200 MHz. No metastability 
  -- expected as the 2x clock is derived from the RX DDR clock 
  -- with low slew between the two clocks.
  proc_tx_data_1x_to_2x : process(clk_ddr_2x_int,clk_ddr_locked_n)
  begin
    if rising_edge(clk_ddr_2x_int) then
      if (clk_ddr_locked_n = '1') then
        ping_pong                       <= '0';
      else
        -- Stalling the data corrects for misalignment due to the data
        -- being split across two clock cycles
        if (ddr_data_stall_stb = '0') then
          if (ping_pong = '0') then
            ping_pong                   <= '1';
            -- IMPORTANT NOTE: The Custom PCB was routed incorrectly causing
            -- one of the differential pairs to have crossed polarity. This
            -- is easy to fix by negating the signal.
            if (USE_CUSTOM_PCB_FIX = TRUE) then
              tx_data_2x_a(7 downto 1)  <= tx_data_a(15 downto 9);
              tx_data_2x_a(0)           <= NOT(tx_data_a(8));
              tx_data_2x_b(7 downto 1)  <= tx_data_b(15 downto 9);
              tx_data_2x_b(0)           <= NOT(tx_data_b(8));
            else
              tx_data_2x_a              <= tx_data_a(15 downto 8);
              tx_data_2x_b              <= tx_data_b(15 downto 8);
            end if;
          else
            ping_pong               <= '0';
            if (USE_CUSTOM_PCB_FIX = TRUE) then
              tx_data_2x_a(7 downto 1)  <= tx_data_a(7 downto 1);
              tx_data_2x_a(0)           <= NOT(tx_data_a(0));
              tx_data_2x_b(7 downto 1)  <= tx_data_b(7 downto 1);
              tx_data_2x_b(0)           <= NOT(tx_data_b(0));
            else
              tx_data_2x_a              <= tx_data_a(7 downto 0);
              tx_data_2x_b              <= tx_data_b(7 downto 0);
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- DDR LVDS Data Output
  gen_tx_ddr_lvds : for i in 0 to 7 generate
    inst_ODDR : ODDR
      generic map (
        DDR_CLK_EDGE                => "SAME_EDGE",
        SRTYPE                      => "ASYNC")
      port map (
        Q                           => tx_data_2x_ddr(i),
        C                           => clk_ddr_2x_int,
        CE                          => '1',
        D1                          => tx_data_2x_a(i),
        D2                          => tx_data_2x_b(i),
        R                           => clk_ddr_locked_n,
        S                           => '0');

    inst_OBUFDS : OBUFDS
      generic map (
        IOSTANDARD                  => "DEFAULT")
      port map (
        I                           => tx_data_2x_ddr(i),
        O                           => TX_DATA_P(i),
        OB                          => TX_DATA_N(i));
  end generate;

  -----------------------------------------------------------------------------
  -- FIFOs for clock crossing and buffering
  -----------------------------------------------------------------------------
  
  -- RX
  rx_fifo_almost_full_n             <= NOT(rx_fifo_almost_full);
  rx_fifo_din                       <= x"00" & rx_data_a & rx_data_b;
  rx_fifo_data_i                    <= rx_fifo_dout(27 downto 14);
  rx_fifo_data_q                    <= rx_fifo_dout(13 downto 0);

  inst_rx_data_fifo_36x512 : fifo_36x512
    port map (
      wr_rst                        => clk_ddr_locked_n,
      wr_clk                        => clk_ddr_int,
      rd_rst                        => rx_fifo_reset,
      rd_clk                        => clk_rx_fifo,
      din                           => rx_fifo_din,
      wr_en                         => rx_fifo_almost_full_n,
      rd_en                         => rx_fifo_rd_en,
      dout                          => rx_fifo_dout,
      full                          => open,
      almost_full                   => rx_fifo_almost_full,
      empty                         => open,
      almost_empty                  => rx_fifo_almost_empty,
      overflow                      => open,
      underflow                     => rx_fifo_underflow);

  -- TX
  tx_fifo_almost_empty_n            <= NOT(tx_fifo_almost_empty);
  tx_fifo_din                       <= x"0" & tx_fifo_data_i & tx_fifo_data_q;
  tx_data_a                         <= tx_fifo_dout(31 downto 16);
  tx_data_b                         <= tx_fifo_dout(15 downto 0);

  inst_tx_data_fifo_36x512 : fifo_36x512
    port map (
      wr_rst                        => tx_fifo_reset,
      wr_clk                        => clk_tx_fifo,
      rd_rst                        => clk_ddr_locked_n,
      rd_clk                        => clk_ddr_int,
      din                           => tx_fifo_din,
      wr_en                         => tx_fifo_wr_en,
      rd_en                         => tx_fifo_almost_empty_n,
      dout                          => tx_fifo_dout,
      full                          => open,
      almost_full                   => tx_fifo_almost_full,
      empty                         => open,
      almost_empty                  => tx_fifo_almost_empty,
      overflow                      => tx_fifo_overflow,
      underflow                     => open);

end RTL;

