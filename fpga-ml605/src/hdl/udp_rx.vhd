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
--  File: udp_rx.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Receives UDP message, extracts useful header information,
--               and stores the payload in a FIFO. While the FIFO has room
--               for more than one packet, the header information will update
--               on a per packet basis. When done_stb asserts, the user is
--               responsible for storing payload_size to ensure the correct
--               number of bytes is read from the output payload FIFO incase
--               another UDP packet is received.
--
--               This component is designed to interface with Xilinx's Tri-mode 
--               Ethernet MAC via the AXI bus.
--
--               The output fifo holds 2048 bytes, which is large enough to 
--               hold more than one full frame of 1472 bytes.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unimacro;
use unimacro.vcomponents.all;

entity udp_rx is
  generic (
    DEVICE                : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
  port (
    -- User interface
    clk                   : in    std_logic;                      -- Clock (FIFO)
    reset                 : in    std_logic;                      -- Active high reset
    -- User receive data filter. Payload is discarded if any of the following do not match.
    -- If a value is set to 0, any value will be accepted.
    mac_addr_src          : in    std_logic_vector(47 downto 0);  -- Filter Source MAC address
    mac_addr_dest         : in    std_logic_vector(47 downto 0);  -- Filter Destination MAC address
    ip_addr_src           : in    std_logic_vector(31 downto 0);  -- Filter Source IP address
    ip_addr_dest          : in    std_logic_vector(31 downto 0);  -- Filter Destination IP address
    port_src              : in    std_logic_vector(15 downto 0);  -- Filter Source Port
    port_dest             : in    std_logic_vector(15 downto 0);  -- Filter Destination Port
    -- User data interface
    done_stb              : out   std_logic;                      -- Received UDP transmission
    busy                  : out   std_logic;                      -- Receiving ethernet data
    frame_error           : out   std_logic;                      -- Error detected
    payload_size          : out   std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
    payload_data          : out   std_logic_vector( 7 downto 0);  -- Output FIFO data
    payload_data_rd_en    : in    std_logic;                      -- Output FIFO read enable
    payload_almost_empty  : out   std_logic;                      -- Output FIFO almost empty
    -- Tri-Mode Ethernet MAC AXI Interface
    rx_mac_aclk           : in    std_logic;                      -- RX clock
    rx_reset              : in    std_logic;                      -- Reset from EMAC
    rx_axis_mac_tdata     : in    std_logic_vector(7 downto 0);   -- Frame data
    rx_axis_mac_tvalid    : in    std_logic;                      -- Frame data valid
    rx_axis_mac_tlast     : in    std_logic;                      -- Last frame
    rx_axis_mac_tuser     : in    std_logic);                     -- Frame error
end entity;

architecture RTL of udp_rx is

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
  -- Signals Declaration
  -----------------------------------------------------------------------------
  type state_type is (IDLE,STORE_HEADER,STORE_PAYLOAD,DROP_PACKET);
  signal state                    : state_type;

  signal counter                  : integer range 0 to 1472;
  signal header_data              : std_logic_vector(335 downto 0);
  signal payload_data_in          : std_logic_vector(7 downto 0);
  signal payload_data_wr_en       : std_logic;
  -- Received header data
  signal mac_addr_src_rx          : std_logic_vector(47 downto 0);
  signal mac_addr_dest_rx         : std_logic_vector(47 downto 0);
  signal ip_addr_src_rx           : std_logic_vector(31 downto 0);
  signal ip_addr_dest_rx          : std_logic_vector(31 downto 0);
  signal port_src_rx              : std_logic_vector(15 downto 0);
  signal port_dest_rx             : std_logic_vector(15 downto 0);
  signal payload_size_rx          : std_logic_vector(15 downto 0);
  -- Header validation registers
  signal header_valid             : std_logic;
  signal mac_addr_src_valid       : std_logic;
  signal mac_addr_dest_valid      : std_logic;
  signal ip_checksum_valid        : std_logic;
  signal ip_addr_src_valid        : std_logic;
  signal ip_addr_dest_valid       : std_logic;
  signal port_src_valid           : std_logic;
  signal port_dest_valid          : std_logic;
  -- Checksum pipelining registers
  signal ip_header_sum_1          : std_logic_vector(17 downto 0);
  signal ip_header_sum_2          : std_logic_vector(17 downto 0);
  signal ip_header_sum_3          : std_logic_vector(17 downto 0);
  signal ip_header_sum_4          : std_logic_vector(17 downto 0);
  signal ip_header_sum            : std_logic_vector(19 downto 0);
  signal ip_checksum              : std_logic_vector(15 downto 0);
  -- Synchronizer signals
  signal done_handshake           : std_logic;
  signal done_handshake_meta      : std_logic;
  signal done_handshake_sync      : std_logic;
  signal done                     : std_logic;
  signal done_dly1                : std_logic;
  signal done_meta                : std_logic;
  signal done_sync                : std_logic;
  signal busy_meta                : std_logic;
  signal busy_sync                : std_logic;
  signal payload_almost_full      : std_logic;
  signal payload_size_meta        : std_logic_vector(10 downto 0);
  signal payload_size_sync        : std_logic_vector(10 downto 0);
  signal frame_error_meta         : std_logic;
  signal frame_error_sync         : std_logic;

  attribute keep                          : string;
  attribute keep of payload_almost_full   : signal is "TRUE";
  attribute keep of payload_almost_empty  : signal is "TRUE";

begin

  -- Synchronizers between clock domains
  proc_synchronizer_to_clk : process(clk)
  begin
    if rising_edge(clk) then
      done_dly1                   <= done;
      done                        <= done_meta;
      done_meta                   <= done_sync;
      done_stb                    <= '0';
      if (done = '1' AND done_dly1 = '0') then
        done_stb                  <= '1';
        done_handshake            <= '1';
      elsif (done = '0') then
        done_handshake            <= '0';
      end if;
      busy                        <= busy_meta;
      busy_meta                   <= busy_sync;
      payload_size                <= payload_size_meta;
      payload_size_meta           <= payload_size_sync;
      frame_error                 <= frame_error_meta;
      frame_error_meta            <= frame_error_sync;
    end if;
  end process;

  proc_synchronizer_to_rx_mac_aclk : process(rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      done_handshake_sync         <= done_handshake_meta;
      done_handshake_meta         <= done_handshake;
    end if;
  end process;

  -- Output (payload) buffer fifo
  output_buffer_fifo_8x2048 : fifo_8x2048
    port map (
      rst                         => rx_reset,
      wr_clk                      => rx_mac_aclk,
      wr_en                       => payload_data_wr_en,
      din                         => payload_data_in,
      full                        => open,
      almost_full                 => payload_almost_full,
      overflow                    => open,
      wr_data_count               => open,
      rd_clk                      => clk,
      rd_en                       => payload_data_rd_en,
      dout                        => payload_data,
      empty                       => open,
      almost_empty                => payload_almost_empty,
      underflow                   => open,
      rd_data_count               => open);

  -- Filter received frames by checking each relevant header field. If any of the
  -- input filters are 0, then accept any value.
  proc_check_header : process(rx_mac_aclk,rx_reset)
  begin
  if rising_edge(rx_mac_aclk) then
    if (rx_reset = '1') then
      header_valid                <= '0';
      mac_addr_src_valid          <= '0';
      mac_addr_dest_valid         <= '0';
      ip_checksum_valid           <= '0';
      ip_addr_src_valid           <= '0';
      ip_addr_dest_valid          <= '0';
      port_src_valid              <= '0';
      port_dest_valid             <= '0';
    else
      if (mac_addr_src = mac_addr_src_rx OR mac_addr_src = x"000000000000") then
        mac_addr_src_valid        <= '1';
      else
        mac_addr_src_valid        <= '0';
      end if;
      if (mac_addr_dest = mac_addr_dest_rx OR mac_addr_dest = x"000000000000") then
        mac_addr_dest_valid       <= '1';
      else
        mac_addr_dest_valid       <= '0';
      end if;
      if (ip_checksum = x"0000") then
        ip_checksum_valid         <= '1';
      else
        ip_checksum_valid         <= '0';
      end if;
      if (ip_addr_src = ip_addr_src_rx OR ip_addr_src = x"00000000") then
        ip_addr_src_valid         <= '1';
      else
        ip_addr_src_valid         <= '0';
      end if;
      if (ip_addr_dest = ip_addr_dest_rx OR ip_addr_dest = x"00000000") then
        ip_addr_dest_valid        <= '1';
      else
        ip_addr_dest_valid        <= '0';
      end if;
      if (port_src = port_src_rx OR port_src = x"0000") then
        port_src_valid            <= '1';
      else
        port_src_valid            <= '0';
      end if;
      if (port_dest = port_dest_rx OR port_dest = x"0000") then
        port_dest_valid           <= '1';
      else
        port_dest_valid           <= '0';
      end if;
      -- Check to ensure each header field is valid
      if (mac_addr_src_valid = '1' AND mac_addr_dest_valid = '1' AND
          ip_checksum_valid = '1'  AND ip_addr_src_valid = '1'   AND
          ip_addr_dest_valid = '1' AND port_src_valid = '1'      AND
          port_dest_valid = '1') then
        header_valid              <= '1';
      else
        header_valid              <= '0';
      end if;
    end if;
  end if;
  end process;

  -- Received data format from EMAC. Additional fields kept for future use.
  -- Ethernet frame. Note Xilinx's EMAC does not send all fields
  mac_addr_dest_rx                <= header_data(335 downto 288);   -- MAC destination address
  mac_addr_src_rx                 <= header_data(287 downto 240);   -- MAC source address
  --                              <= header_data(239 downto 224);   -- Type, IPv4
  -- IP header
  --                              <= header_data(223 downto 220);   -- Version, IPv4
  --                              <= header_data(219 downto 216);   -- IHL
  --                              <= header_data(215 downto 210);   -- DSCP
  --                              <= header_data(209 downto 208);   -- ECN
  payload_size_rx                 <= std_logic_vector(unsigned(header_data(207 downto 192)) - to_unsigned(28,11)); -- Total Length (bytes) (20 byte IP header + 8 bytes UDP header)
  --                              <= header_data(191 downto 176);   -- Indentification
  --                              <= header_data(175 downto 173);   -- Flags
  --                              <= header_data(172 downto 160);   -- Fragment Offset
  --                              <= header_data(159 downto 152);   -- Time To Live
  --                              <= header_data(151 downto 144);   -- Protocol (UDP)
  --                              <= header_data(143 downto 128);   -- Header Checksum
  ip_addr_src_rx                  <= header_data(127 downto  96);   -- Source IP Address
  ip_addr_dest_rx                 <= header_data( 95 downto  64);   -- Destination IP Address
  -- UDP header
  port_src_rx                     <= header_data( 63 downto  48);   -- Source Port
  port_dest_rx                    <= header_data( 47 downto  32);   -- Destination Port
  --                              <= header_data( 31 downto  16);   -- Length (8 byte UDP header)
  --                              <= header_data( 15 downto   0);   -- Checksum (0 is valid)

  -- Verify the IP checksum. See http://en.wikipedia.org/wiki/IPv4_header_checksum
  -- Pipelined to improve speed.
  proc_calc_checksum : process(rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      ip_header_sum_1           <= std_logic_vector(unsigned("00" & header_data(223 downto 208)) + 
                                                    unsigned("00" & header_data(207 downto 192)) + 
                                                    unsigned("00" & header_data(191 downto 176)));
      ip_header_sum_2           <= std_logic_vector(unsigned("00" & header_data(175 downto 160)) + 
                                                    unsigned("00" & header_data(159 downto 144)) + 
                                                    unsigned("00" & header_data(127 downto 112)));
      ip_header_sum_3           <= std_logic_vector(unsigned("00" & header_data(111 downto  96)) + 
                                                    unsigned("00" & header_data( 95 downto  80)) + 
                                                    unsigned("00" & header_data( 79 downto  64)));
      ip_header_sum_4           <= std_logic_vector(unsigned(ip_header_sum_1) + 
                                                    unsigned("00" & header_data(143 downto 128)));
      ip_header_sum             <= std_logic_vector(unsigned("00" & ip_header_sum_2) + 
                                                    unsigned("00" & ip_header_sum_3) + 
                                                    unsigned("00" & ip_header_sum_4));
      ip_checksum               <= NOT(std_logic_vector(unsigned(ip_header_sum(19 downto 16)) + 
                                                        unsigned(ip_header_sum(15 downto  0))));
    end if;
  end process;

  -- UDP receiver state machine. Receives a UDP packet through the EMAC AXI interface.
  proc_rx_state_machine : process(rx_mac_aclk,rx_reset)
  begin
    if rising_edge(rx_mac_aclk) then
      if (rx_reset = '1') then
        payload_size_sync                   <= (others=>'0');
        payload_data_in                     <= (others=>'0');
        payload_data_wr_en                  <= '0';
        frame_error_sync                    <= '0';
        header_data                         <= (others=>'0');
        done_sync                           <= '0';
        busy_sync                           <= '0';
        counter                             <= 0;
        state                               <= IDLE;
      else
        case state is
          when IDLE =>
            payload_data_wr_en              <= '0';
            busy_sync                       <= '0';
            counter                         <= 0;
            -- Done signal strobe clock domain crossing handshake
            if (done_handshake_sync = '1') then
              done_sync                     <= '0';
            end if;
            if (rx_axis_mac_tvalid = '1') then
              busy_sync                     <= '1';
              counter                       <= counter + 1;
              header_data(335 downto 328)   <= rx_axis_mac_tdata;
              state                         <= STORE_HEADER;
            end if;

          when STORE_HEADER =>
            counter                         <= counter + 1;
            header_data(header_data'length-8*counter-1 downto header_data'length-8*counter-8) <= rx_axis_mac_tdata;
            if (counter = 41) then
              counter                       <= 0;
              if (header_valid = '1') then
                counter                     <= to_integer(unsigned(payload_size_rx(10 downto 0)));
                state                       <= STORE_PAYLOAD;
              -- If the header is not valid, then discard the packet
              else
                state                       <= DROP_PACKET;
              end if;
            end if;

          when STORE_PAYLOAD =>
            -- Only store payload bytes, ignore zero padding at the end.
            if (rx_axis_mac_tvalid = '1' AND counter > 0) then
              payload_data_in               <= rx_axis_mac_tdata;
              payload_data_wr_en            <= '1';
              counter                       <= counter - 1;
            else
              payload_data_wr_en            <= '0';
            end if;
            if (rx_axis_mac_tlast = '1') then
              done_sync                     <= '1';
              payload_size_sync             <= payload_size_rx(10 downto 0);
              frame_error_sync              <= rx_axis_mac_tuser;
              state                         <= IDLE;
            end if;

          -- Header data did not match, wait for end of payload.
          when DROP_PACKET =>
            if (rx_axis_mac_tlast = '1') then
              state                         <= IDLE;
            end if;

          when others =>
            state                           <= IDLE;
        end case;
      end if;
    end if;
  end process;

end architecture;