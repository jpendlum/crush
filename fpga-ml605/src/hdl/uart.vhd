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
--  File: uart.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Universal asynchronous receiver transmitter. Transmits and
--               receives serial data and includes parity checking.
--               TX and RX interfaces are independent.
--               Transmit data tx_data is registered and transmission begins 
--               when tx_data_load_stb is strobed. While the component is busy 
--               (busy = '1'), further tx_data_load_stb strobes are ignored.
--               Receive data strobe rx_data_vld_stb toggles to indicate 
--               serial data was received and rx_data is valid.
--               Parity bit is always transmitted / received. If UART does not
--               use a parity bit, set PARITY to either MARK ('1') or 
--               SPACE ('0') and STOP_BITS to 1.
--               
--               Note: For 1 stop bit, use PARITY "NONE"
--                     For 2 stop bits, use PARITY "MARK"
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
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
end entity;

architecture RTL of uart is

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant BIT_PERIOD           : integer := (CLOCK_FREQ/BAUD);
  constant HALF_BIT_PERIOD      : integer := (CLOCK_FREQ/BAUD)/2;

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  type rx_state_type is (RX_IDLE_S,RX_START_BIT_S,RX_DATA_S,RX_PARITY_S,RX_STOP_BIT_S,RX_VERIFY_S);
  signal rx_state               : rx_state_type;

  type tx_state_type is (TX_IDLE_S,TX_START_BIT_S,TX_DATA_S,TX_PARITY_S,TX_STOP_BIT_S);
  signal tx_state               : tx_state_type;

  signal rx_meta                : std_logic;
  signal rx_sync                : std_logic;
  signal rx_sync_dly1           : std_logic;
  -- 1 Start bit + STOP_BITS + 1 parity bit + DATA_BITS
  signal rx_start_bit           : std_logic;
  signal rx_stop_bit            : std_logic;
  signal rx_parity              : std_logic;
  signal rx_parity_calc         : std_logic_vector(DATA_BITS-1 downto 0);
  signal rx_parity_local        : std_logic;
  signal rx_data_int            : std_logic_vector(DATA_BITS-1 downto 0);
  signal rx_bit_cnt             : integer range 0 to DATA_BITS;
  signal rx_bit_period_cnt      : integer range 0 to BIT_PERIOD-1;
  signal tx_int                 : std_logic;
  signal tx_data_int            : std_logic_vector(DATA_BITS-1 downto 0);
  signal tx_parity              : std_logic;
  signal tx_parity_mux          : std_logic;
  signal tx_parity_calc         : std_logic_vector(DATA_BITS-1 downto 0);
  signal tx_bit_cnt             : integer range 0 to DATA_BITS-1;
  signal tx_bit_period_cnt      : integer range 0 to BIT_PERIOD-1;

begin

  proc_receiver : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        rx_meta                         <= '0';
        rx_sync                         <= '0';
        rx_busy                         <= '0';
        rx_state                        <= RX_IDLE_S;
        rx_data_int                     <= (others=>'0');
        rx_data                         <= (others=>'0');
        rx_data_stb                     <= '0';
        rx_error                        <= '0';
        rx_start_bit                    <= '0';
        rx_stop_bit                     <= '0';
        rx_parity                       <= '0';
        rx_bit_cnt                      <= 0;
        rx_bit_period_cnt               <= 0;
      else
        -- Sychronizer
        rx_meta                         <= rx;
        rx_sync                         <= rx_meta;
        rx_sync_dly1                    <= rx_sync;

        case rx_state is
          when RX_IDLE_S =>
            -- Initial conditions
            rx_bit_period_cnt           <= 0;
            rx_bit_cnt                  <= 0;
            rx_data_stb                 <= '0';
            rx_busy                     <= '0';
            -- Start bit detected
            if (rx_sync_dly1 = '1' AND rx_sync = '0') then
              rx_busy                   <= '1';
              rx_state                  <= RX_START_BIT_S;
            end if;

          -- Wait for half a bit period to align to the middle of the bit
          when RX_START_BIT_S =>
            if (rx_bit_period_cnt = HALF_BIT_PERIOD-1) then
              rx_start_bit              <= rx_sync;
              rx_bit_period_cnt         <= 0;
              rx_state                  <= RX_DATA_S;
            else
              rx_bit_period_cnt         <= rx_bit_period_cnt + 1;
            end if;

          -- Wait a full bit period then sample each bit.
          when RX_DATA_S =>
            if (rx_bit_period_cnt = BIT_PERIOD-1) then
              rx_bit_cnt                <= rx_bit_cnt + 1;
              -- Shift register, UART is LSB first
              rx_data_int(DATA_BITS-1)  <= rx_sync;
              for i in DATA_BITS-1 downto 1 loop
                rx_data_int(i-1)        <= rx_data_int(i);
              end loop;
              rx_bit_period_cnt         <= 0;
            else
              rx_bit_period_cnt         <= rx_bit_period_cnt + 1;
            end if;
            -- Need to use DATA_BITS instead of DATA_BITS-1 due to
            -- rx_bit_cnt = 0 is not counted.
            if (rx_bit_cnt = DATA_BITS) then
              rx_bit_cnt                <= 0;
              if (PARITY(PARITY'left) = 'N') then
                rx_state                <= RX_STOP_BIT_S;
              else
                rx_state                <= RX_PARITY_S;
              end if;
            end if;

          -- Sample parity bit
          when RX_PARITY_S =>
            if (rx_bit_period_cnt = BIT_PERIOD-1) then
              rx_bit_period_cnt         <= 0;
              rx_parity                 <= rx_sync;
              rx_state                  <= RX_STOP_BIT_S;
            else
              rx_bit_period_cnt         <= rx_bit_period_cnt + 1;
            end if;

          -- Wait for stop bit
          -- Note: The statemachine will return to RX_IDLE while still
          --       aligned to the middle of the received bits. This 
          --       alignment is intentional and corrected with the
          --       next start bit.
          when RX_STOP_BIT_S =>
            if (rx_bit_period_cnt = BIT_PERIOD-1) then
              rx_bit_period_cnt         <= 0;
              rx_stop_bit               <= rx_sync;
              rx_state                  <= RX_VERIFY_S;
            else
              rx_bit_period_cnt         <= rx_bit_period_cnt + 1;
            end if;

          when RX_VERIFY_S =>
            rx_data                     <= rx_data_int;
            -- Even if an error occurs, output the data strobe
            if (NO_STROBE_ON_ERR(NO_STROBE_ON_ERR'left) = 'F') then
              rx_data_stb               <= '1';
            end if;
            if (rx_parity = rx_parity_local AND rx_stop_bit = '1' AND rx_start_bit = '0') then
              -- Only output the data strobe if no errors have occured
              if (NO_STROBE_ON_ERR(NO_STROBE_ON_ERR'left) = 'T') then
                rx_data_stb             <= '1';
              end if;
              rx_error                  <= '0';
            else
              rx_error                  <= '1';
            end if;
            rx_state                    <= RX_IDLE_S;

          when others =>
            rx_state                    <= RX_IDLE_S;
        end case;
      end if;
    end if;
  end process;

  -- Calculate expected parity bit
  rx_parity_local     <= '1'                              when PARITY(PARITY'left) = 'M' else -- Mark
                         '0'                              when PARITY(PARITY'left) = 'S' else -- Space
                         rx_parity_calc(DATA_BITS-1)      when PARITY(PARITY'left) = 'E' else -- Even
                         NOT(rx_parity_calc(DATA_BITS-1)) when PARITY(PARITY'left) = 'O';     -- Odd
  rx_parity_calc(0)   <= rx_data_int(0);
  rx_calc_parity_bit : for i in 1 to DATA_BITS-1 generate
    rx_parity_calc(i) <= rx_data_int(i) XOR rx_parity_calc(i-1);
  end generate;

  proc_transmitter : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        tx                              <= '1';
        tx_int                          <= '1';
        tx_state                        <= TX_IDLE_S;
        tx_bit_cnt                      <= 0;
        tx_bit_period_cnt               <= 0;
        tx_data_int                     <= (others=>'0');
        tx_parity                       <= '0';
        tx_busy                         <= '0';
      else
        tx                              <= tx_int;

        case tx_state is
          when TX_IDLE_S =>
            tx_busy                     <= '0';
            if (tx_data_stb = '1') then
              tx_busy                   <= '1';
              tx_data_int               <= tx_data;
              tx_state                  <= TX_START_BIT_S;
            end if;

          when TX_START_BIT_S =>
            tx_int                      <= '0';
            if (tx_bit_period_cnt = BIT_PERIOD-1) then
              -- Send out first bit
              tx_int                    <= tx_data_int(0);
              -- Register TX parity
              tx_parity                 <= tx_parity_mux;
              tx_bit_period_cnt         <= 0;
              tx_state                  <= TX_DATA_S;
            else
              tx_bit_period_cnt         <= tx_bit_period_cnt + 1;
            end if;

          when TX_DATA_S =>
            if (tx_bit_period_cnt = BIT_PERIOD-1) then
              -- Shift register, UART is LSB first
              tx_int                    <= tx_data_int(0);
              for i in 1 to DATA_BITS-1 loop
                tx_data_int(i-1)        <= tx_data_int(i);
              end loop;
              tx_bit_period_cnt         <= 0;
              tx_bit_cnt                <= tx_bit_cnt + 1;
            else
              tx_bit_period_cnt         <= tx_bit_period_cnt + 1;
            end if;
            if (tx_bit_cnt = DATA_BITS-1) then
              tx_bit_cnt                <= 0;
              if (PARITY(PARITY'left) = 'N') then
                tx_state                <= TX_STOP_BIT_S;
              else
                tx_state                <= TX_PARITY_S;
              end if;
            end if;

          when TX_PARITY_S =>
            tx_int                      <= tx_parity;
            if (tx_bit_period_cnt = BIT_PERIOD-1) then
              tx_bit_period_cnt         <= 0;
              tx_state                  <= TX_STOP_BIT_S;
            else
              tx_bit_period_cnt         <= tx_bit_period_cnt + 1;
            end if;

          when TX_STOP_BIT_S =>
            tx_int                      <= '1';
            if (tx_bit_period_cnt = BIT_PERIOD-1) then
              tx_bit_period_cnt         <= 0;
              tx_state                  <= TX_IDLE_S;
            else
              tx_bit_period_cnt         <= tx_bit_period_cnt + 1;
            end if;

          when others =>
            tx_state                    <= TX_IDLE_S;

        end case;
      end if;
    end if;
  end process;

  -- Generate parity bit
  tx_parity_mux       <= '1'                              when PARITY(PARITY'left) = 'M' else -- Mark
                         '0'                              when PARITY(PARITY'left) = 'S' else -- Space
                         tx_parity_calc(DATA_BITS-1)      when PARITY(PARITY'left) = 'E' else -- Even
                         NOT(tx_parity_calc(DATA_BITS-1)) when PARITY(PARITY'left) = 'O';     -- Odd
  tx_parity_calc(0)   <= tx_data_int(0);
  tx_calc_parity_bit : for i in 1 to DATA_BITS-1 generate
    tx_parity_calc(i) <= tx_data_int(i) XOR tx_parity_calc(i-1);
  end generate;

end architecture;