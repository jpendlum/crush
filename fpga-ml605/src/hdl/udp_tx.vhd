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
--  File: udp_tx.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Formats input data into a User Datagram Protocol (UDP) message
--               by including the relevant Ethernet frame, IP header, and UDP
--               header data. IP header is hard coded not to fragment and 
--               the maximum payload size is 1472 bytes.
--               
--               This component is designed to interface with
--               Xilinx's Tri-mode Ethernet MAC via the AXI bus. It is assumed
--               that the Tri-mode Ethernet MAC is configured to automatically
--               insert the FCS and padding in the Ethernet header.
--
--               The input data width is user configurable, but should be either
--               8, 16, 32, or 64 bits. The input FIFO holds 2048 bytes (regardless
--               of input width) and is large enough to hold more than a full
--               frame of 1472 bytes. When start_stb is asserted, a state
--               machine will start reading the input FIFO and insert the
--               appropriate header data automatically.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unimacro;
use unimacro.Vcomponents.all;

entity udp_tx is
  generic (
    DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
  port (
    -- User interface
    clk                   : in    std_logic;                      -- Clock (FIFO)
    reset                 : in    std_logic;                      -- Active high reset
    -- User Ethernet frame, IP header, & UDP header configuration
    mac_addr_src          : in    std_logic_vector(47 downto 0);  -- Source MAC address
    mac_addr_dest         : in    std_logic_vector(47 downto 0);  -- Destination MAC address
    ip_addr_src           : in    std_logic_vector(31 downto 0);  -- Source IP address
    ip_addr_dest          : in    std_logic_vector(31 downto 0);  -- Destination IP address
    port_src              : in    std_logic_vector(15 downto 0);  -- Source Port
    port_dest             : in    std_logic_vector(15 downto 0);  -- Destination Port
    -- User data interface
    start_stb             : in    std_logic;                      -- Start UDP transmission
    busy                  : out   std_logic;                      -- UDP transmission in process
    payload_size          : in    std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
    payload_data          : in    std_logic_vector(7 downto 0);   -- Input FIFO data
    payload_data_wr_en    : in    std_logic;                      -- Input FIFO write enable
    payload_almost_full   : out   std_logic;                      -- Input FIFO almost full
    -- Tri-Mode Ethernet MAC AXI Interface
    tx_mac_aclk           : in    std_logic;                      -- TX clock (same as clk)
    tx_reset              : in    std_logic;                      -- TX reset
    tx_axis_mac_tdata     : out   std_logic_vector(7 downto 0);   -- Frame data
    tx_axis_mac_tvalid    : out   std_logic;                      -- Frame data valid
    tx_axis_mac_tlast     : out   std_logic;                      -- Last frame
    tx_axis_mac_tuser     : out   std_logic;                      -- Frame error (FIFO underrun)
    tx_axis_mac_tready    : in    std_logic);                     -- Ready for data
end entity;

architecture RTL of udp_tx is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component fifo_8x2048
    port (
      rst                       : in    std_logic;
      wr_clk                    : in    std_logic;
      wr_en                     : in    std_logic;
      din                       : in    std_logic_vector(7 downto 0);
      full                      : out   std_logic;
      almost_full               : out   std_logic;
      overflow                  : out   std_logic;
      wr_data_count             : out   std_logic_vector(10 downto 0);
      rd_clk                    : in    std_logic;
      rd_en                     : in    std_logic;
      dout                      : out   std_logic_vector(7 downto 0);
      empty                     : out   std_logic;
      almost_empty              : out   std_logic;
      underflow                 : out   std_logic;
      rd_data_count             : out   std_logic_vector(10 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  type state_type is (IDLE,STARTUP_BYTE_1,STARTUP_BYTE_2,
                      WAIT_FOR_READY,SEND_HEADERS,SEND_PAYLOAD);
  signal state                    : state_type;

  signal start                    : std_logic;
  signal start_sync               : std_logic;
  signal start_meta               : std_logic;
  signal busy_int                 : std_logic;
  signal busy_meta                : std_logic;
  signal busy_sync                : std_logic;

  signal counter                  : integer range 0 to 1472;
  signal header_data              : std_logic_vector(335 downto 0);
  signal payload_data_count       : std_logic_vector(10 downto 0);
  signal payload_data_rd_en       : std_logic;
  signal payload_data_out         : std_logic_vector( 7 downto 0);
  signal payload_size_int         : std_logic_vector(10 downto 0);
  signal payload_almost_empty     : std_logic;
  signal payload_underflow        : std_logic;
  signal payload_rd_data_count    : std_logic_vector(10 downto 0);
  -- Checksum pipeling registers
  signal ip_header_sum_1          : std_logic_vector(17 downto 0);
  signal ip_header_sum_2          : std_logic_vector(17 downto 0);
  signal ip_header_sum_3          : std_logic_vector(17 downto 0);
  signal ip_header_sum            : std_logic_vector(19 downto 0);
  signal ip_checksum              : std_logic_vector(15 downto 0);

  attribute keep                          : string;
  attribute keep of payload_almost_full   : signal is "TRUE";
  attribute keep of payload_almost_empty  : signal is "TRUE";

begin

  -- Synchronizers between clock domains
  proc_synchronizer_to_tx_mac_aclk : process(tx_mac_aclk)
  begin
    if rising_edge(tx_mac_aclk) then
      start_meta                  <= start;
      start_sync                  <= start_meta;
    end if;
  end process;

  proc_synchronizer_to_clk : process(clk,reset)
  begin
    if rising_edge(clk) then
      if (reset = '1') then
        start                     <= '0';
      else
        busy_int                  <= busy_meta;
        busy_meta                 <= busy_sync;
        if (start_stb = '1') then
          start                   <= '1';
        elsif (busy_int = '1') then
          start                   <= '0';
        end if;
      end if;
    end if;
  end process;

  busy                            <= busy_int;

  -- Input (payload) buffer FIFO
  input_buffer_fifo_8x2048 : fifo_8x2048
    port map (
      rst                         => tx_reset,
      wr_clk                      => clk,
      wr_en                       => payload_data_wr_en,
      din                         => payload_data,
      full                        => open,
      almost_full                 => payload_almost_full,
      overflow                    => open,
      wr_data_count               => payload_data_count,
      rd_clk                      => tx_mac_aclk,
      rd_en                       => payload_data_rd_en,
      dout                        => payload_data_out,
      empty                       => open,
      almost_empty                => payload_almost_empty,
      underflow                   => payload_underflow,
      rd_data_count               => payload_rd_data_count);

  -- Ethernet frame. Note Xilinx's EMAC will fill in the other fields
  header_data(335 downto 288)     <= mac_addr_dest;     -- MAC destination address
  header_data(287 downto 240)     <= mac_addr_src;      -- MAC source address
  header_data(239 downto 224)     <= x"0800";           -- Type, IPv4
  -- IP header
  header_data(223 downto 220)     <= x"4";              -- Version, IPv4
  header_data(219 downto 216)     <= x"5";              -- IHL
  header_data(215 downto 210)     <= "000000";          -- DSCP
  header_data(209 downto 208)     <= "00";              -- ECN
  header_data(207 downto 192)     <= std_logic_vector(to_unsigned(28,16) + unsigned(payload_size_int));   -- Total Length (bytes) (20 byte IP header + 8 bytes UDP header)
  header_data(191 downto 176)     <= x"0000";           -- Indentification
  header_data(175 downto 173)     <= "000";             -- Flags
  header_data(172 downto 160)     <= "0000000000000";   -- Fragment Offset
  header_data(159 downto 152)     <= x"40";             -- Time To Live
  header_data(151 downto 144)     <= x"11";             -- Protocol (UDP)
  header_data(143 downto 128)     <= ip_checksum;       -- Header Checksum
  header_data(127 downto  96)     <= ip_addr_src;       -- Source IP Address
  header_data( 95 downto  64)     <= ip_addr_dest;      -- Destination IP Address
  -- UDP header
  header_data( 63 downto  48)     <= port_src;          -- Source Port
  header_data( 47 downto  32)     <= port_dest;         -- Destination Port
  header_data( 31 downto  16)     <= std_logic_vector(to_unsigned(8,16) + unsigned(payload_size_int));  -- Length (8 byte UDP header)
  header_data( 15 downto   0)     <= x"0000";           -- Checksum (0 is valid, no need to calculate)

  -- Calculate the IP checksum. See http://en.wikipedia.org/wiki/IPv4_header_checksum
  -- Pipelined to improve speed.
  proc_calc_checksum : process(tx_mac_aclk)
  begin
    if rising_edge(tx_mac_aclk) then
      ip_header_sum_1           <= std_logic_vector(unsigned("00" & header_data(223 downto 208)) + 
                                                    unsigned("00" & header_data(207 downto 192)) + 
                                                    unsigned("00" & header_data(191 downto 176)));
      ip_header_sum_2           <= std_logic_vector(unsigned("00" & header_data(175 downto 160)) + 
                                                    unsigned("00" & header_data(159 downto 144)) + 
                                                    unsigned("00" & header_data(127 downto 112)));
      ip_header_sum_3           <= std_logic_vector(unsigned("00" & header_data(111 downto  96)) + 
                                                    unsigned("00" & header_data( 95 downto  80)) + 
                                                    unsigned("00" & header_data( 79 downto  64)));
      ip_header_sum             <= std_logic_vector(unsigned("00" & ip_header_sum_1) + 
                                                    unsigned("00" & ip_header_sum_2) + 
                                                    unsigned("00" & ip_header_sum_3));
      ip_checksum               <= NOT(std_logic_vector(unsigned(ip_header_sum(19 downto 16)) + 
                                                        unsigned(ip_header_sum(15 downto  0))));
    end if;
  end process;

  -- UDP transmit state machine
  proc_tx_state_machine : process(tx_mac_aclk,tx_reset)
  begin
    if rising_edge(tx_mac_aclk) then
      if (tx_reset = '1') then
        payload_data_rd_en        <= '0';
        payload_size_int          <= (others=>'0');
        tx_axis_mac_tvalid        <= '0';
        tx_axis_mac_tdata         <= (others=>'0');
        tx_axis_mac_tuser         <= '0';
        tx_axis_mac_tlast         <= '0';
        busy_sync                 <= '0';
        counter                   <= 0;
        state                     <= IDLE;
      else
        case state is
          when IDLE =>
            payload_data_rd_en    <= '0';
            tx_axis_mac_tvalid    <= '0';
            tx_axis_mac_tuser     <= '0';
            tx_axis_mac_tlast     <= '0';
            busy_sync             <= '0';
            counter               <= 0;
            -- UDP max payload size of 1472 bytes
            if (payload_size < std_logic_vector(to_unsigned(1472,11))) then
              payload_size_int    <= payload_size;
            else
              payload_size_int    <= std_logic_vector(to_unsigned(1472,11));
            end if;
            if (start_sync = '1') then
              tx_axis_mac_tvalid  <= '1';
              tx_axis_mac_tdata   <= header_data(335 downto 328);
              counter             <= counter + 1;
              busy_sync           <= '1';
              state               <= STARTUP_BYTE_1;
            end if;

          -- Per Virtex 6 Tri-mode Ethernet MAC guide, send two bytes and wait for
          -- tx_axis_mac_tready to assert. Note the FIFO is first word fall through.
          when STARTUP_BYTE_1 =>
            tx_axis_mac_tvalid    <= '1';
            if (tx_axis_mac_tready = '1') then
              tx_axis_mac_tdata   <= header_data(327 downto 320);
              counter             <= counter + 1;
              state               <= STARTUP_BYTE_2;
            end if;

          when STARTUP_BYTE_2 =>
            tx_axis_mac_tvalid    <= '1';
            if (tx_axis_mac_tready = '1') then
              tx_axis_mac_tdata   <= header_data(319 downto 312);
              counter             <= counter + 1;
              state               <= WAIT_FOR_READY;
            end if;

          -- Wait for EMAC to signal it is ready for data.
          when WAIT_FOR_READY =>
            tx_axis_mac_tvalid    <= '1';
            if (tx_axis_mac_tready = '1') then
              tx_axis_mac_tdata   <= header_data(311 downto 304);
              counter             <= counter + 1;
              state               <= SEND_HEADERS;
            end if;

          -- Send Ethernet frame, IP, and UDP headers.
          when SEND_HEADERS =>
            tx_axis_mac_tvalid    <= '1';
            tx_axis_mac_tdata     <= header_data(header_data'length-8*counter-1 downto header_data'length-8*counter-8);
            if (counter = 41) then
              -- Due to register, read enable needs to be asserted one cycle early
              payload_data_rd_en  <= '1';
              counter             <= 0;
              state               <= SEND_PAYLOAD;
            else
              counter             <= counter + 1;
            end if;

          -- Send UDP data payload
          when SEND_PAYLOAD =>
            payload_data_rd_en    <= '1';
            tx_axis_mac_tvalid    <= '1';
            tx_axis_mac_tdata     <= payload_data_out;
            if (counter = to_integer(unsigned(payload_size_int))-1) then
              payload_data_rd_en  <= '0';
              tx_axis_mac_tlast   <= '1';
              counter             <= 0;
              state               <= IDLE;
            else
              counter             <= counter + 1;
            end if;

          when others =>
            state                 <= IDLE;
        end case;
      end if;
    end if;
  end process;

end architecture;