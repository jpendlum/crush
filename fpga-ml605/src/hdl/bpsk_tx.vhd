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
--  File: bpsk_tx.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library unimacro;
use unimacro.vcomponents.all;

entity bpsk_tx is
  port (
    clk                   : in    std_logic;                      -- Clock
    reset                 : in    std_logic;                      -- Active high reset
    -- Control data bus
    mode                  : in    std_logic_vector(1 downto 0);   -- 0 = BPSK, 1 = CW, 2 = PRN data, 3 = Test Pattern
    freq                  : in    std_logic_vector(15 downto 0);  -- Carrier Offset Frequency
    data_freq             : in    std_logic_vector(15 downto 0);  -- Psuedo-Random Data Frequency
    -- I & Q data bus
    i                     : out   std_logic_vector(15 downto 0);  -- Inphase
    q                     : out   std_logic_vector(15 downto 0)); -- Quadrature
end entity;

architecture RTL of bpsk_tx is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component cordic
    port (
      clk                 : in    std_logic;
      phase_in            : in    std_logic_vector(15 downto 0);
      x_out               : out   std_logic_vector(15 downto 0);
      y_out               : out   std_logic_vector(15 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant MODE_BPSK           : std_logic_vector(1 downto 0) := "00";
  constant MODE_CW             : std_logic_vector(1 downto 0) := "01";
  constant MODE_DATA           : std_logic_vector(1 downto 0) := "10";
  constant MODE_TEST_PATTERN   : std_logic_vector(1 downto 0) := "11";

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal mode_int         : std_logic_vector(1 downto 0);
  signal freq_int         : std_logic_vector(15 downto 0);
  signal data_freq_int    : std_logic_vector(15 downto 0);

  signal i_int            : std_logic_vector(15 downto 0);
  signal q_int            : std_logic_vector(15 downto 0);

  signal phase_accum      : std_logic_vector(15 downto 0);
  signal lfsr             : std_logic_vector(16 downto 0);
  signal lfsr_counter     : std_logic_vector(15 downto 0);
  signal lfsr_shift       : std_logic;
  signal data             : std_logic;


begin

  proc_register_inputs : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        mode_int          <= (others=>'0');
        freq_int          <= (others=>'0');
        data_freq_int     <= (others=>'0');
      else
        mode_int          <= mode;
        freq_int          <= freq;
        data_freq_int     <= data_freq;
      end if;
    end if;
  end process;

  inst_cordic : cordic
    port map (
      clk                 => clk,
      phase_in            => phase_accum,
      x_out               => i_int,
      y_out               => q_int);

  -- Phase accumulator
  proc_phase_accum : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        phase_accum       <= (others=>'0');
      else
        -- Keep phase between +/- 2*pi
        if (signed(phase_accum) > "0100000000000000") then
          phase_accum     <= phase_accum + freq_int - "0100000000000000";
        elsif (signed(phase_accum) < "1100000000000000") then
          phase_accum     <= phase_accum + freq_int + "0100000000000000";
        else
          phase_accum     <= phase_accum + freq_int;
        end if;
      end if;
    end if;
  end process;

  -- Rotate 0 or 180 deg. depending on data and mode
  proc_apply_data : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        i                 <= (others=>'0');
        q                 <= (others=>'0');
      else
        case (mode_int) is
          -- Send BPSK waveform modulated with PN data
          when MODE_BPSK =>
            if (data = '0') then
              i             <= NOT(i_int) + '1';
              q             <= NOT(q_int) + '1';
            else
              i             <= i_int;
              q             <= q_int;
            end if;

          -- Send tone
          when MODE_CW =>
            i               <= i_int;
            q               <= q_int;

          -- PN data
          when MODE_DATA =>
            if (data = '0') then
              i             <= x"8000";
              q             <= x"0000";
            else
              i             <= x"7FFF";
              q             <= x"0000";
            end if;

          -- Send 1010 test pattern
          -- Note, receive path is only 14 bits so the 
          -- first 2 MSBs are dropped
          when MODE_TEST_PATTERN =>
            i               <= x"1A2B";
            q               <= x"3C4D";

          when others =>
            i               <= (others=>'0');
            q               <= (others=>'0');
        end case;
      end if;
    end if;
  end process;

  -- 17 bit LFSR to randomize data
  proc_lfsr : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        lfsr              <= "0" & x"0001";
        lfsr_shift        <= '0';
        lfsr_counter      <= (others=>'0');
        data              <= '0';
      else
        data              <= lfsr(0);
        if (lfsr_shift = '1') then
          lfsr(0)         <= lfsr(16) XOR lfsr(13);
          for i in 1 to 16 loop
            lfsr(i)       <= lfsr(i-1);
          end loop;
        end if;
        -- Shift on overflow. Use greater than or
        -- equal to incase data_freq_int updates
        -- to a smaller number
        if (lfsr_counter >= data_freq_int) then
          lfsr_counter    <= (others=>'0');
          lfsr_shift      <= '1';
        else
          lfsr_shift      <= '0';
          lfsr_counter    <= lfsr_counter + '1';
        end if;
      end if;
    end if;
  end process;

end RTL;