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
--  File: udp_rx_tb.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Testbench for udp_rx.vhd. Sends four UDP packets, one with
--               correct checksum and correct header, one with incorrect 
--               checksum and correct header, and one with correct checksum
--               and incorrect header.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_rx_tb is
end entity;

architecture RTL of udp_rx_tb is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component udp_rx
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
  end component;

  -----------------------------------------------------------------------------
  -- Constants Declaration
  -----------------------------------------------------------------------------
  constant ClockRate_100MHz     : real    := 100.0e6;
  constant ClockPeriod_100MHz   : time    := (1.0e12/ClockRate_100MHz)*(1 ps);
  constant ClockRate_125MHz     : real    := 125.0e6;
  constant ClockPeriod_125MHz   : time    := (1.0e12/ClockRate_125MHz)*(1 ps);
  constant Timeout              : time    := 5 sec;

  -----------------------------------------------------------------------------
  -- Signals Declaration
  -----------------------------------------------------------------------------
  signal clk_100MHz             : std_logic := '0';
  signal clk_125MHz             : std_logic := '0';
  signal reset                  : std_logic := '0';
  signal reset_n                : std_logic := '1';

  type udp_packet_type is array(0 to 79) of std_logic_vector(7 downto 0);

  signal udp_packet_1           : udp_packet_type := 
    (x"11",x"1B",x"AD",x"F0",x"0D",x"11",x"77",x"DE",x"AD",x"C0",
     x"DE",x"77",x"08",x"00",x"45",x"00",x"00",x"42",x"00",x"00",
     x"00",x"00",x"03",x"11",x"34",x"01",x"FA",x"CE",x"FE",x"ED",
     x"CA",x"FE",x"BE",x"EF",x"55",x"55",x"AA",x"AA",x"00",x"3A",
     x"00",x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",
     x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"0F",x"10",x"11",x"12",
     x"13",x"14",x"15",x"16",x"17",x"18",x"19",x"1A",x"1B",x"1C",
     x"1D",x"1E",x"1F",x"20",x"21",x"22",x"23",x"24",x"25",x"26");
  signal udp_packet_2           : udp_packet_type := 
    (x"11",x"1B",x"AD",x"F0",x"0D",x"11",x"77",x"DE",x"AD",x"C0",
     x"DE",x"77",x"08",x"00",x"45",x"00",x"00",x"42",x"00",x"00",
     x"00",x"00",x"03",x"11",x"FF",x"FF",x"FA",x"CE",x"FE",x"ED",
     x"CA",x"FE",x"BE",x"EF",x"55",x"55",x"AA",x"AA",x"00",x"3A",
     x"00",x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",
     x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"0F",x"10",x"11",x"12",
     x"13",x"14",x"15",x"16",x"17",x"18",x"19",x"1A",x"1B",x"1C",
     x"1D",x"1E",x"1F",x"20",x"21",x"22",x"23",x"24",x"25",x"26");
  signal udp_packet_3           : udp_packet_type := 
    (x"11",x"1B",x"AD",x"F0",x"0D",x"11",x"77",x"DE",x"AD",x"C0",
     x"DE",x"77",x"08",x"00",x"45",x"00",x"00",x"42",x"00",x"00",
     x"00",x"00",x"03",x"11",x"2D",x"BE",x"FF",x"FF",x"FF",x"FF",
     x"CA",x"FE",x"BE",x"EF",x"55",x"55",x"AA",x"AA",x"00",x"3A",
     x"00",x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",
     x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"0F",x"10",x"11",x"12",
     x"13",x"14",x"15",x"16",x"17",x"18",x"19",x"1A",x"1B",x"1C",
     x"1D",x"1E",x"1F",x"20",x"21",x"22",x"23",x"24",x"25",x"26");

  signal mac_addr_src           : std_logic_vector(47 downto 0);
  signal mac_addr_dest          : std_logic_vector(47 downto 0);
  signal ip_addr_src            : std_logic_vector(31 downto 0);
  signal ip_addr_dest           : std_logic_vector(31 downto 0);
  signal port_src               : std_logic_vector(15 downto 0);
  signal port_dest              : std_logic_vector(15 downto 0);
  signal done_stb               : std_logic;
  signal busy                   : std_logic;
  signal frame_error            : std_logic;
  signal payload_size           : std_logic_vector(10 downto 0);
  signal payload_data           : std_logic_vector(7 downto 0);
  signal payload_data_rd_en     : std_logic;
  signal payload_almost_empty   : std_logic;
  signal rx_mac_aclk            : std_logic;
  signal rx_reset               : std_logic;
  signal rx_axis_mac_tdata      : std_logic_vector(7 downto 0);
  signal rx_axis_mac_tvalid     : std_logic;
  signal rx_axis_mac_tlast      : std_logic;
  signal rx_axis_mac_tuser      : std_logic;

  signal counter                : integer;

begin

  -------------------------------------------------------------------------------
  -- Create Clock Process, 100 MHz
  -------------------------------------------------------------------------------
  proc_create_clock_100MHz : process
  begin
    clk_100MHz        <= '0';
    wait for ClockPeriod_100MHz/2;
    clk_100MHz        <= '1';
    wait for ClockPeriod_100MHz/2;
  end process;

  -------------------------------------------------------------------------------
  -- Create Clock Process, 125 MHz
  -------------------------------------------------------------------------------
  proc_create_clock_125MHz : process
  begin
    clk_125MHz        <= '0';
    wait for ClockPeriod_125MHz/2;
    clk_125MHz        <= '1';
    wait for ClockPeriod_125MHz/2;
  end process;

  -------------------------------------------------------------------------------
  -- Reset Process
  -------------------------------------------------------------------------------
  proc_reset : process
  begin
    reset             <= '1';
    wait for 10*ClockPeriod_100MHz;
    wait until clk_100MHz = '1';
    reset             <= '0';
    wait;
  end process;
  reset_n             <= NOT(reset);

  -------------------------------------------------------------------------------
  -- Timeout Process
  -------------------------------------------------------------------------------
  proc_timeout : process
  begin
    wait for Timeout;
    assert(FALSE)
      report "ERROR: Simulation timed out."
      severity FAILURE;
    wait;
  end process;

  -------------------------------------------------------------------------------
  -- Design Under Test
  -------------------------------------------------------------------------------
  dut : udp_rx
  generic map (
    DEVICE                  => "VIRTEX6")
  port map (
    clk                     => clk_100MHz,
    reset                   => reset,
    mac_addr_src            => mac_addr_src,
    mac_addr_dest           => mac_addr_dest,
    ip_addr_src             => ip_addr_src,
    ip_addr_dest            => ip_addr_dest,
    port_src                => port_src,
    port_dest               => port_dest,
    done_stb                => done_stb,
    busy                    => busy,
    frame_error             => frame_error,
    payload_size            => payload_size,
    payload_data            => payload_data,
    payload_data_rd_en      => payload_data_rd_en,
    payload_almost_empty    => payload_almost_empty,
    rx_mac_aclk             => rx_mac_aclk,
    rx_reset                => rx_reset,
    rx_axis_mac_tdata       => rx_axis_mac_tdata,
    rx_axis_mac_tvalid      => rx_axis_mac_tvalid,
    rx_axis_mac_tlast       => rx_axis_mac_tlast,
    rx_axis_mac_tuser       => rx_axis_mac_tuser);

  rx_mac_aclk               <= clk_125MHz;

  -------------------------------------------------------------------------------
  -- Test Bench
  -------------------------------------------------------------------------------
  proc_test_bench : process
  begin
    mac_addr_src          <= (others=>'0');
    mac_addr_dest         <= (others=>'0');
    ip_addr_src           <= (others=>'0');
    ip_addr_dest          <= (others=>'0');
    port_src              <= (others=>'0');
    port_dest             <= (others=>'0');
    payload_data_rd_en    <= '0';
    rx_reset              <= '1';
    rx_axis_mac_tdata     <= (others=>'0');
    rx_axis_mac_tvalid    <= '0';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tuser     <= '0';
    counter               <= 0;

    -- Wait for reset
    wait until reset = '0';
    rx_reset              <= '0';
    mac_addr_src          <= x"77DEADC0DE77";
    mac_addr_dest         <= x"111BADF00D11";
    ip_addr_src           <= x"FACEFEED";
    ip_addr_dest          <= x"CAFEBEEF";
    port_src              <= x"5555";
    port_dest             <= x"AAAA";
    -- Align simulation time with rising clock edge
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    -----------------------------------------------------------------------------
    -- Test 1: Correct checksum and header
    -----------------------------------------------------------------------------
    for i in 0 to 78 loop
      rx_axis_mac_tdata   <= udp_packet_1(i);
      rx_axis_mac_tvalid  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tdata     <= udp_packet_1(79);
    rx_axis_mac_tlast     <= '1';
    rx_axis_mac_tvalid    <= '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    for i in 0 to to_integer(unsigned(payload_size))-1 loop
      payload_data_rd_en  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    payload_data_rd_en    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    -----------------------------------------------------------------------------
    -- Test 2: Incorrect checksum, but correct header
    -----------------------------------------------------------------------------
    for i in 0 to 78 loop
      rx_axis_mac_tdata   <= udp_packet_2(i);
      rx_axis_mac_tvalid  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tdata     <= udp_packet_2(79);
    rx_axis_mac_tlast     <= '1';
    rx_axis_mac_tvalid    <= '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    -----------------------------------------------------------------------------
    -- Test 3: Correct checksum, but incorrect header
    -----------------------------------------------------------------------------
    for i in 0 to 78 loop
      rx_axis_mac_tdata   <= udp_packet_3(i);
      rx_axis_mac_tvalid  <= '1';
      wait until clk_125MHz = '1';
    end loop;
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tdata     <= udp_packet_3(79);
    rx_axis_mac_tlast     <= '1';
    rx_axis_mac_tvalid    <= '1';
    wait until clk_125MHz = '1';
    rx_axis_mac_tlast     <= '0';
    rx_axis_mac_tvalid    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';

    wait;

  end process;

end architecture;