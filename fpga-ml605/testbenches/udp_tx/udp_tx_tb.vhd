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
--  File: udp_tx_tb.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Testbench for udp_rx.vhd. Tests sending a UDP packet.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_tx_tb is
end entity;

architecture RTL of udp_tx_tb is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component udp_tx
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
      payload_data_count    : out   std_logic_vector(10 downto 0);  -- Number of bytes in input FIFO
      -- Tri-Mode Ethernet MAC AXI Interface
      tx_mac_aclk           : in    std_logic;                      -- TX clock (same as clk)
      tx_reset              : in    std_logic;                      -- TX reset
      tx_axis_mac_tdata     : out   std_logic_vector(7 downto 0);   -- Frame data
      tx_axis_mac_tvalid    : out   std_logic;                      -- Frame data valid
      tx_axis_mac_tlast     : out   std_logic;                      -- Last frame
      tx_axis_mac_tuser     : out   std_logic;                      -- Frame error (FIFO underrun)
      tx_axis_mac_tready    : in    std_logic);                     -- Ready for data
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

  signal mac_addr_src           : std_logic_vector(47 downto 0);
  signal mac_addr_dest          : std_logic_vector(47 downto 0);
  signal ip_addr_src            : std_logic_vector(31 downto 0);
  signal ip_addr_dest           : std_logic_vector(31 downto 0);
  signal port_src               : std_logic_vector(15 downto 0);
  signal port_dest              : std_logic_vector(15 downto 0);
  signal start_stb              : std_logic;
  signal busy                   : std_logic;
  signal payload_size           : std_logic_vector(10 downto 0);
  signal payload_data           : std_logic_vector(7 downto 0);
  signal payload_data_wr_en     : std_logic;
  signal payload_almost_full    : std_logic;
  signal payload_data_count     : std_logic_vector(10 downto 0);
  signal tx_mac_aclk            : std_logic;
  signal tx_reset               : std_logic;
  signal tx_axis_mac_tdata      : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid     : std_logic;
  signal tx_axis_mac_tlast      : std_logic;
  signal tx_axis_mac_tuser      : std_logic;
  signal tx_axis_mac_tready     : std_logic;
  
  type udp_packet_type is array(0 to 79) of std_logic_vector(7 downto 0);

  signal udp_packet             : udp_packet_type := 
    (x"11",x"1B",x"AD",x"F0",x"0D",x"11",x"77",x"DE",x"AD",x"C0",
     x"DE",x"77",x"08",x"00",x"45",x"00",x"00",x"42",x"00",x"00",
     x"00",x"00",x"03",x"11",x"34",x"01",x"FA",x"CE",x"FE",x"ED",
     x"CA",x"FE",x"BE",x"EF",x"55",x"55",x"AA",x"AA",x"00",x"3A",
     x"00",x"00",x"01",x"02",x"03",x"04",x"05",x"06",x"07",x"08",
     x"09",x"0A",x"0B",x"0C",x"0D",x"0E",x"0F",x"10",x"11",x"12",
     x"13",x"14",x"15",x"16",x"17",x"18",x"19",x"1A",x"1B",x"1C",
     x"1D",x"1E",x"1F",x"20",x"21",x"22",x"23",x"24",x"25",x"26");

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
  dut : udp_tx
    generic map (
      DEVICE                => "VIRTEX6")
    port map (
      clk                   => clk_100MHz,
      reset                 => reset,
      mac_addr_src          => mac_addr_src,
      mac_addr_dest         => mac_addr_dest,
      ip_addr_src           => ip_addr_src,
      ip_addr_dest          => ip_addr_dest,
      port_src              => port_src,
      port_dest             => port_dest,
      start_stb             => start_stb,
      busy                  => busy,
      payload_size          => payload_size,
      payload_data          => payload_data,
      payload_data_wr_en    => payload_data_wr_en,
      payload_almost_full   => payload_almost_full,
      payload_data_count    => payload_data_count,
      tx_mac_aclk           => tx_mac_aclk,
      tx_reset              => tx_reset,
      tx_axis_mac_tdata     => tx_axis_mac_tdata,
      tx_axis_mac_tvalid    => tx_axis_mac_tvalid,
      tx_axis_mac_tlast     => tx_axis_mac_tlast,
      tx_axis_mac_tuser     => tx_axis_mac_tuser,
      tx_axis_mac_tready    => tx_axis_mac_tready);

  tx_mac_aclk               <= clk_125MHz;

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
    payload_data          <= (others=>'0');
    payload_data_wr_en    <= '0';
    tx_reset              <= '1';
    start_stb             <= '0';
    payload_size          <= (others=>'0');
    tx_axis_mac_tready    <= '0';

    -- Wait for reset
    wait until reset = '0';
    tx_reset              <= '0';
    mac_addr_src          <= x"77DEADC0DE77";
    mac_addr_dest         <= x"111BADF00D11";
    ip_addr_src           <= x"FACEFEED";
    ip_addr_dest          <= x"CAFEBEEF";
    port_src              <= x"5555";
    port_dest             <= x"AAAA";
    payload_size          <= std_logic_vector(to_unsigned(38,11));
    -- Align simulation time with rising clock edge
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';

    -----------------------------------------------------------------------------
    -- Test 1: Correct checksum and header
    -----------------------------------------------------------------------------
    for i in 42 to 79 loop
      payload_data        <= udp_packet(i);
      payload_data_wr_en  <= '1';
      wait until clk_100MHz = '1';
    end loop;
    payload_data        <= (others=>'0');
    payload_data_wr_en  <= '0';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    wait until clk_100MHz = '1';
    start_stb           <= '1';
    wait until clk_100MHz = '1';
    start_stb           <= '0';
    -- Begin simulating the AXI interface
    wait until tx_axis_mac_tvalid = '1';
    wait until clk_125MHz = '1';
    tx_axis_mac_tready    <= '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    tx_axis_mac_tready    <= '0';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    wait until clk_125MHz = '1';
    tx_axis_mac_tready    <= '1';
    wait until tx_axis_mac_tlast = '1';
    wait until clk_125MHz = '1';
    tx_axis_mac_tready    <= '0';
    wait until clk_125MHz = '1';

    wait;

  end process;

end architecture;