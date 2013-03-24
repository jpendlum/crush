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
--  along with CRUSH.  If not, see <http://www.gnu.org/licenses/>.
--  
--  
--  
--  File: spectrum_sense.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Specturm sensing by implementing a FFT and threshold 
--               detection. 
--               
--               User asserts start_stb to begin the FFT. Note, data must
--               be immediately ready to be loaded with xn_rfd. After the
--               FFT is complete, done_stb asserts and frequency and threshold
--               exceeded data will begin outputting automatically. The 
--               frequency and threshold data are both aligned with xk_index.
--
--               The threshold is compared to xk_real^2 + xk_imag^2, as the
--               square-root LUT is more resource intensive than a simple
--               compare. Any frequency bin that exceeds the threshold will
--               assert threshold_exceed.
--
--               FFT is configured to output frequency data in natural order.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unimacro;
use unimacro.vcomponents.all;

entity spectrum_sense is
  generic (
    DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
  port (
    clk                   : in    std_logic;                      -- Clock
    reset                 : in    std_logic;                      -- Active high reset
    start_stb             : in    std_logic;                      -- Start spectrum sensing
    busy                  : out   std_logic;                      -- Busy
    done_stb              : out   std_logic;                      -- FFT done, begin data unload on next cycle
    -- FFT
    fft_size              : in    std_logic_vector(4 downto 0);   -- 0 = 64, 1 = 128, etc...
    xn_real               : in    std_logic_vector(13 downto 0);  -- x(n) time domain signal (real)
    xn_imag               : in    std_logic_vector(13 downto 0);  -- x(n) time domain signal (imag)
    xk_valid              : out   std_logic;                      -- X(k) data valid
    xk_real               : out   std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (real)
    xk_imag               : out   std_logic_vector(15 downto 0);  -- X(k) frequency domain signal (imag)
    xk_index              : out   std_logic_vector(12 downto 0);  -- k
    -- Threshold detection
    xk_magnitude_squared  : out   std_logic_vector(31 downto 0);  -- Magnitude squared, X_r(k)^2 + X_i(k)^2
    threshold             : in    std_logic_vector(31 downto 0);  -- Threshold (Magnitude squared)
    threshold_exceeded    : out   std_logic);                     -- Threshold exceeded. Aligned with X(k) data
end entity;

architecture RTL of spectrum_sense is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component fft
    port (
      clk               : in    std_logic;                      -- Clock
      ce                : in    std_logic;                      -- Clock enable
      sclr              : in    std_logic;                      -- Synchronous Reset
      nfft              : in    std_logic_vector(4 downto 0);   -- Set transform size (64 - 8k)
      nfft_we           : in    std_logic;                      -- Transform size write enable
      start             : in    std_logic;                      -- Begin transform  
      unload            : in    std_logic;                      -- Unload frequency data (xk)
      fwd_inv           : in    std_logic;                      -- Set forward or inverse transform
      fwd_inv_we        : in    std_logic;                      -- Write enable
      rfd               : out   std_logic;                      -- Ready for data
      busy              : out   std_logic;                      -- Transform busy
      edone             : out   std_logic;                      -- Transform done (one cycle early)
      done              : out   std_logic;                      -- Transform done
      dv                : out   std_logic;                      -- Output data valid
      xn_re             : in    std_logic_vector(13 downto 0);  -- Input data (Real component)
      xn_im             : in    std_logic_vector(13 downto 0);  -- Input data (Complex component)
      xn_index          : out   std_logic_vector(12 downto 0);  -- Input data load index
      xk_index          : out   std_logic_vector(12 downto 0);  -- Frequency bin
      xk_re             : out   std_logic_vector(27 downto 0);  -- Frequency data (Real component)
      xk_im             : out   std_logic_vector(27 downto 0)); -- Frequency data (Complex component)
  end component; 

  component MULT_MACRO
    generic ( 
      DEVICE            : string  := "VIRTEX6";
      LATENCY           : integer := 0;
      WIDTH_A           : integer := 14;
      WIDTH_B           : integer := 14);
    port (
      P                 : out   std_logic_vector((WIDTH_A+WIDTH_B)-1 downto 0);
      A                 : in    std_logic_vector(WIDTH_A-1 downto 0);   
      B                 : in    std_logic_vector(WIDTH_B-1 downto 0);   
      CE                : in    std_logic;
      CLK               : in    std_logic;   
      RST               : in    std_logic);   
  end component;

  component ADDSUB_MACRO
    generic ( 
      DEVICE            : string  := "VIRTEX6";
      LATENCY           : integer := 2;
      WIDTH             : integer := 48);
    port (
      CARRYOUT          : out   std_logic;
      RESULT            : out   std_logic_vector(WIDTH-1 downto 0);
      A                 : in    std_logic_vector(WIDTH-1 downto 0);   
      ADD_SUB           : in    std_logic;   
      B                 : in    std_logic_vector(WIDTH-1 downto 0);   
      CARRYIN           : in    std_logic;  
      CE                : in    std_logic;
      CLK               : in    std_logic;   
      RST               : in    std_logic);   
  end component;

  component saturate
    generic (
      WIDTH_IN        : integer;                                        -- Input bit width
      WIDTH_OUT       : integer);                                       -- Output bit width
    port (
      i               : in    std_logic_vector(WIDTH_IN-1 downto 0);    -- Signed Input 
      o               : out   std_logic_vector(WIDTH_OUT-1 downto 0));  -- Signed Saturated Output
  end component;

  component trunc_unbiased
    generic (
      WIDTH_IN        : integer;                                                -- Input bit width
      TRUNCATE        : integer);                                               -- Number of bits to truncate
    port (
      i               : in    std_logic_vector(WIDTH_IN-1 downto 0);            -- Signed Input
      o               : out   std_logic_vector(WIDTH_IN-TRUNCATE-1 downto 0));  -- Truncated Signed Output
  end component;

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  type state_type is (IDLE, START_FFT, WAIT_FOR_FFT, WAIT_FOR_DATA_VALID, DATA_DELAY1,
                      DATA_DELAY2, UNLOAD_DATA);
  signal state                          : state_type;

  signal fft_start                      : std_logic;
  signal fft_rfd                        : std_logic;
  signal fft_busy                       : std_logic;
  signal fft_edone                      : std_logic;
  signal fft_done                       : std_logic;
  signal fft_unload                     : std_logic;
  signal fft_size_reg                   : std_logic_vector(4 downto 0);
  signal fft_size_stb                   : std_logic;

  signal xk_real_fft                    : std_logic_vector(27 downto 0);
  signal xk_real_trunc                  : std_logic_vector(22 downto 0);
  signal xk_real_saturate               : std_logic_vector(15 downto 0);
  signal xk_real_int                    : std_logic_vector(15 downto 0);
  signal xk_real_dly1                   : std_logic_vector(15 downto 0);
  signal xk_real_dly2                   : std_logic_vector(15 downto 0);
  signal xk_real_squared                : std_logic_vector(31 downto 0);
  signal xk_real_squared_ext            : std_logic_vector(32 downto 0);
  signal xk_imag_fft                    : std_logic_vector(27 downto 0);
  signal xk_imag_trunc                  : std_logic_vector(22 downto 0);
  signal xk_imag_saturate               : std_logic_vector(15 downto 0);
  signal xk_imag_int                    : std_logic_vector(15 downto 0);
  signal xk_imag_dly1                   : std_logic_vector(15 downto 0);
  signal xk_imag_dly2                   : std_logic_vector(15 downto 0);
  signal xk_imag_squared                : std_logic_vector(31 downto 0);
  signal xk_imag_squared_ext            : std_logic_vector(32 downto 0);
  signal xk_magnitude_squared_int       : std_logic_vector(32 downto 0);
  signal xk_magnitude_squared_saturate  : std_logic_vector(31 downto 0);

  signal xk_valid_fft                   : std_logic;
  signal xk_valid_dly1                  : std_logic;
  signal xk_valid_dly2                  : std_logic;
  signal xk_valid_dly3                  : std_logic;
  signal xk_index_fft                   : std_logic_vector(12 downto 0);
  signal xk_index_dly1                  : std_logic_vector(12 downto 0);
  signal xk_index_dly2                  : std_logic_vector(12 downto 0);
  signal xk_index_dly3                  : std_logic_vector(12 downto 0);

begin

  ---------------------------------------------------------------------------
  -- Fast Fourier Transform
  ---------------------------------------------------------------------------
  inst_fft : fft
    port map (
      clk               => clk,
      ce                => '1',
      sclr              => reset,
      nfft              => fft_size_reg,
      nfft_we           => fft_size_stb,
      start             => fft_start,
      unload            => fft_unload,
      fwd_inv           => '0',
      fwd_inv_we        => '0',
      rfd               => fft_rfd,
      busy              => fft_busy,
      edone             => fft_edone,
      done              => fft_done,
      dv                => xk_valid_fft,
      xn_re             => xn_real,
      xn_im             => xn_imag,
      xn_index          => open,
      xk_index          => xk_index_fft,
      xk_re             => xk_real_fft,
      xk_im             => xk_imag_fft);

  ---------------------------------------------------------------------------
  -- Control State Machine
  ---------------------------------------------------------------------------
  proc_control_state_machine : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        fft_size_reg        <= (others=>'0');
        fft_size_stb        <= '0';
        fft_start           <= '0';
        fft_unload          <= '0';
        busy                <= '0';
        done_stb            <= '0';
        state               <= IDLE;
      else
        -- Strobes are only one clock cycle
        fft_size_stb        <= '0';
        -- State Machine
        case state is
          when IDLE =>
            -- Only update fft_size when idle.
            if (fft_size_reg /= fft_size AND start_stb = '0') then
              fft_size_reg  <= fft_size;
              fft_size_stb  <= '1';
            end if;
            if (start_stb = '1') then
              fft_start     <= '1';
              busy          <= '1';
              state         <= START_FFT;
            end if;

          -- Wait for FFT to start
          when START_FFT =>
            fft_start       <= '1';
            if (fft_rfd = '1') then
              state         <= WAIT_FOR_FFT;
            end if;

          -- Wait for FFT to finish
          when WAIT_FOR_FFT =>
            fft_start       <= '0';
            if (fft_edone = '1') then
              fft_unload    <= '1';
              state         <= DATA_DELAY1;
            end if;

          -- Wait for FFT data to be valid
          when WAIT_FOR_DATA_VALID =>
            fft_unload      <= '0';
            if (xk_valid_fft = '1') then
              state         <= DATA_DELAY1;
            end if;

          -- Pipeline delays FFT data so it aligns with the
          -- threshold detection logic.
          when DATA_DELAY1 =>
            state           <= DATA_DELAY2;

          when DATA_DELAY2 =>
            -- Assert done strobe one clock cycle before
            -- frequency data and threshold data begins unloading.
            done_stb        <= '1';
            state           <= UNLOAD_DATA;

          -- Wait for FFT data to finish unloading
          when UNLOAD_DATA =>
            done_stb        <= '0';
            if (xk_valid_fft = '0') then
              state         <= IDLE;
            end if;

          when others =>
            state           <= IDLE;
          end case;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Magnitude squared calculation
  ---------------------------------------------------------------------------
  -- Reduce FFT output to 16 bits, but try to maintain dynamic range by
  -- grabbing the slice (18 downto 3). This range was determined 
  -- experimentally.
  int_xk_real_trunc : trunc_unbiased
    generic map (
      WIDTH_IN          => 28,
      TRUNCATE          => 5)
    port map (
      i                 => xk_real_fft,
      o                 => xk_real_trunc);

  int_xk_imag_trunc : trunc_unbiased
    generic map (
      WIDTH_IN          => 28,
      TRUNCATE          => 5)
    port map (
      i                 => xk_imag_fft,
      o                 => xk_imag_trunc);

  inst_xk_real_saturate : saturate
    generic map (
      WIDTH_IN          => 23,
      WIDTH_OUT         => 16)
    port map (
      i                 => xk_real_trunc,
      o                 => xk_real_saturate);

  inst_xk_imag_saturate : saturate
    generic map (
      WIDTH_IN          => 23,
      WIDTH_OUT         => 16)
    port map (
      i                 => xk_imag_trunc,
      o                 => xk_imag_saturate);

  proc_saturate_trunc : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        xk_real_int     <= (others=>'0');
        xk_imag_int     <= (others=>'0');
      else
        xk_real_int     <= xk_real_saturate;
        xk_imag_int     <= xk_imag_saturate;
      end if;
    end if;
  end process;

  -- Square xk_real
  inst_MULT_MACRO_xk_real : MULT_MACRO
    generic map ( 
      DEVICE            => DEVICE,
      LATENCY           => 1,
      WIDTH_A           => 16,
      WIDTH_B           => 16)
    port map (
      P                 => xk_real_squared,
      A                 => xk_real_int,
      B                 => xk_real_int,
      CE                => '1',
      CLK               => clk,
      RST               => reset);

  xk_real_squared_ext   <= '0' & xk_real_squared;

  -- Square xk_imag
  inst_MULT_MACRO_xk_imag : MULT_MACRO
    generic map ( 
      DEVICE            => DEVICE,
      LATENCY           => 1,
      WIDTH_A           => 16,
      WIDTH_B           => 16)
    port map (
      P                 => xk_imag_squared,
      A                 => xk_imag_int,
      B                 => xk_imag_int,
      CE                => '1',
      CLK               => clk,
      RST               => reset);

  xk_imag_squared_ext   <= '0' & xk_imag_squared;

  -- xk_real^2 + xk_imag^2
  inst_ADDSUB_MACRO : ADDSUB_MACRO
    generic map ( 
      DEVICE            => DEVICE,
      LATENCY           => 1,
      WIDTH             => 33)
    port map (
      CARRYOUT          => open,
      RESULT            => xk_magnitude_squared_int,
      A                 => xk_real_squared_ext,
      ADD_SUB           => '1',
      B                 => xk_imag_squared_ext,
      CARRYIN           => '0',
      CE                => '1',
      CLK               => clk,
      RST               => reset);

  -- Grab lower 32 bits, unsigned saturate if necessary
  xk_magnitude_squared_saturate   <= xk_magnitude_squared_int(31 downto 0) when xk_magnitude_squared_int(32) = '0' else
                                     (others=>'1');

  ---------------------------------------------------------------------------
  -- Threshold compare
  ---------------------------------------------------------------------------
  proc_threshold_compare : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        threshold_exceeded    <= '0';
      else
        if (xk_magnitude_squared_saturate >= threshold) then
          threshold_exceeded  <= '1';
        else
          threshold_exceeded  <= '0';
        end if;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Align outputs with threshold compare
  ---------------------------------------------------------------------------
  proc_data_alignment : process(clk)
  begin
    if rising_edge(clk) then
      xk_valid_dly1               <= xk_valid_fft;
      xk_valid_dly2               <= xk_valid_dly1;
      xk_valid_dly3               <= xk_valid_dly2;
      xk_valid                    <= xk_valid_dly3;
      xk_index_dly1               <= xk_index_fft;
      xk_index_dly2               <= xk_index_dly1;
      xk_index_dly3               <= xk_index_dly2;
      xk_index                    <= xk_index_dly3;
      xk_real_dly1                <= xk_real_int;
      xk_real_dly2                <= xk_real_dly1;
      xk_real                     <= xk_real_dly2;
      xk_imag_dly1                <= xk_imag_int;
      xk_imag_dly2                <= xk_imag_dly1;
      xk_imag                     <= xk_imag_dly2;
      xk_magnitude_squared        <= xk_magnitude_squared_saturate;
    end if;
  end process;

end architecture;