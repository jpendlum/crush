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
--  File: network_intf.vhd
--  Author: Jonathon Pendlum (jon.pendlum@gmail.com)
--  Description: Implements UDP packet TX and RX and the control / data 
--               interfaces.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity network_intf is
  generic (
    DEVICE                    : string := "VIRTEX6");                 -- "VIRTEX5", VIRTEX6", "7SERIES"
  port (
    -- User interface
    clk                       : in    std_logic;                      -- Clock (FIFO)
    reset                     : in    std_logic;                      -- Active high reset
    -- User RX interface
    -- User receive data filter. Payload is discarded if any of the following do not match.
    -- If a value is set to 0, any value will be accepted.
    rx_mac_addr_src           : in    std_logic_vector(47 downto 0);  -- Filter Source MAC address
    rx_mac_addr_dest          : in    std_logic_vector(47 downto 0);  -- Filter Destination MAC address
    rx_ip_addr_src            : in    std_logic_vector(31 downto 0);  -- Filter Source IP address
    rx_ip_addr_dest           : in    std_logic_vector(31 downto 0);  -- Filter Destination IP address
    rx_port_src               : in    std_logic_vector(15 downto 0);  -- Filter Source Port
    rx_port_dest              : in    std_logic_vector(15 downto 0);  -- Filter Destination Port
    -- User RX data interface
    rx_done_stb               : out   std_logic;                      -- Received UDP transmission
    rx_busy                   : out   std_logic;                      -- Receiving ethernet data
    rx_frame_error            : out   std_logic;                      -- Error detected
    rx_payload_size           : out   std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
    rx_payload_data           : out   std_logic_vector(7 downto 0);   -- Output FIFO data
    rx_payload_data_rd_en     : in    std_logic;                      -- Output FIFO read enable
    rx_payload_almost_empty   : out   std_logic;                      -- Output FIFO almost empty
    -- User TX interface
    -- User TX Ethernet frame, IP header, & UDP header configuration
    tx_mac_addr_src           : in    std_logic_vector(47 downto 0);  -- Source MAC address
    tx_mac_addr_dest          : in    std_logic_vector(47 downto 0);  -- Destination MAC address
    tx_ip_addr_src            : in    std_logic_vector(31 downto 0);  -- Source IP address
    tx_ip_addr_dest           : in    std_logic_vector(31 downto 0);  -- Destination IP address
    tx_port_src               : in    std_logic_vector(15 downto 0);  -- Source Port
    tx_port_dest              : in    std_logic_vector(15 downto 0);  -- Destination Port
    -- User TX data interface 
    tx_start_stb              : in    std_logic;                      -- Start UDP transmission
    tx_busy                   : out   std_logic;                      -- UDP transmission in process
    tx_payload_size           : in    std_logic_vector(10 downto 0);  -- Number of payload data in bytes (max 1472)
    tx_payload_data           : in    std_logic_vector(7 downto 0);   -- Input FIFO data
    tx_payload_data_wr_en     : in    std_logic;                      -- Input FIFO write enable
    tx_payload_almost_full    : out   std_logic;                      -- Input FIFO almost full
    -- Tri-mode Ethernet Wrapper Signals
    gtx_clk                   : in    std_logic;                      -- GTX 125 MHz clock
    refclk                    : in    std_logic;                      -- IDELAY 200 MHz clock
    phy_reset_n               : out   std_logic;
    gmii_txd                  : out   std_logic_vector(7 downto 0);
    gmii_tx_en                : out   std_logic;
    gmii_tx_er                : out   std_logic;
    gmii_tx_clk               : out   std_logic;
    gmii_rxd                  : in    std_logic_vector(7 downto 0);
    gmii_rx_dv                : in    std_logic;
    gmii_rx_er                : in    std_logic;
    gmii_rx_clk               : in    std_logic;
    gmii_col                  : in    std_logic;
    gmii_crs                  : in    std_logic;
    mii_tx_clk                : in    std_logic);
end entity;

architecture RTL of network_intf is

  -----------------------------------------------------------------------------
  -- Components Declaration
  -----------------------------------------------------------------------------
  component embedded_emac_block
    port (
      gtx_clk                       : in    std_logic;
      -- Receiver Interface
      rx_statistics_vector          : out   std_logic_vector(27 downto 0);
      rx_statistics_valid           : out   std_logic;
      rx_mac_aclk                   : out   std_logic;
      rx_reset                      : out   std_logic;
      rx_axis_mac_tdata             : out   std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid            : out   std_logic;
      rx_axis_mac_tlast             : out   std_logic;
      rx_axis_mac_tuser             : out   std_logic;
      -- Transmitter Interface
      tx_ifg_delay                  : in    std_logic_vector(7 downto 0);
      tx_statistics_vector          : out   std_logic_vector(31 downto 0);
      tx_statistics_valid           : out   std_logic;
      tx_mac_aclk                   : out   std_logic;
      tx_reset                      : out   std_logic;
      tx_axis_mac_tdata             : in    std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid            : in    std_logic;
      tx_axis_mac_tlast             : in    std_logic;
      tx_axis_mac_tuser             : in    std_logic;
      tx_axis_mac_tready            : out   std_logic;
      tx_collision                  : out   std_logic;
      tx_retransmit                 : out   std_logic;
      -- MAC Control Interface
      pause_req                     : in    std_logic;
      pause_val                     : in    std_logic_vector(15 downto 0);
      -- Reference clock for IDELAYCTRL's
      refclk                        : in    std_logic;
      -- GMII Interface
      gmii_txd                      : out   std_logic_vector(7 downto 0);
      gmii_tx_en                    : out   std_logic;
      gmii_tx_er                    : out   std_logic;
      gmii_tx_clk                   : out   std_logic;
      gmii_rxd                      : in    std_logic_vector(7 downto 0);
      gmii_rx_dv                    : in    std_logic;
      gmii_rx_er                    : in    std_logic;
      gmii_rx_clk                   : in    std_logic;
      gmii_col                      : in    std_logic;
      gmii_crs                      : in    std_logic;
      mii_tx_clk                    : in    std_logic;
      -- asynchronous reset
      glbl_rstn                     : in    std_logic;
      rx_axi_rstn                   : in    std_logic;
      tx_axi_rstn                   : in    std_logic);
  end component;

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
      -- Tri-Mode Ethernet MAC AXI Interface
      tx_mac_aclk           : in    std_logic;                      -- TX clock (same as clk)
      tx_reset              : in    std_logic;                      -- TX reset
      tx_axis_mac_tdata     : out   std_logic_vector(7 downto 0);   -- Frame data
      tx_axis_mac_tvalid    : out   std_logic;                      -- Frame data valid
      tx_axis_mac_tlast     : out   std_logic;                      -- Last frame
      tx_axis_mac_tuser     : out   std_logic;                      -- Frame error (FIFO underrun)
      tx_axis_mac_tready    : in    std_logic);                     -- Ready for data
  end component;

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
      payload_data          : out   std_logic_vector(7 downto 0);   -- Output FIFO data
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
  -- Signals Declaration
  -----------------------------------------------------------------------------

  signal rx_mac_aclk              : std_logic;
  signal rx_reset                 : std_logic;
  signal rx_axis_mac_tdata        : std_logic_vector(7 downto 0);
  signal rx_axis_mac_tvalid       : std_logic;
  signal rx_axis_mac_tlast        : std_logic;
  signal rx_axis_mac_tuser        : std_logic;
  signal tx_mac_aclk              : std_logic;
  signal tx_reset                 : std_logic;
  signal tx_axis_mac_tdata        : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid       : std_logic;
  signal tx_axis_mac_tlast        : std_logic;
  signal tx_axis_mac_tuser        : std_logic;
  signal tx_axis_mac_tready       : std_logic;

  signal phy_reset_counter        : integer;

  signal reset_n                  : std_logic;

begin

  -- PHY reset
  -- the phy reset output (active low) needs to be held for at least 10x25MHZ cycles
  -- this is derived using the 125MHz available and a 6 bit counter
  proc_phy_reset : process (gtx_clk,reset)
  begin
    if rising_edge(gtx_clk) then
      if reset = '1' then
        phy_reset_n               <= '0';
        phy_reset_counter         <= 0;
      else
        if (phy_reset_counter = 63) then
          phy_reset_n             <= '1';
        else
          phy_reset_counter       <= phy_reset_counter + 1;
          phy_reset_n             <= '0';
        end if;
      end if;
    end if;
  end process;

  inst_embedded_emac_block : embedded_emac_block
    port map (
      gtx_clk                     => gtx_clk,
      rx_statistics_vector        => open,
      rx_statistics_valid         => open,
      rx_mac_aclk                 => rx_mac_aclk,
      rx_reset                    => rx_reset,
      rx_axis_mac_tdata           => rx_axis_mac_tdata,
      rx_axis_mac_tvalid          => rx_axis_mac_tvalid,
      rx_axis_mac_tlast           => rx_axis_mac_tlast,
      rx_axis_mac_tuser           => rx_axis_mac_tuser,
      tx_ifg_delay                => x"00",
      tx_statistics_vector        => open,
      tx_statistics_valid         => open,
      tx_mac_aclk                 => tx_mac_aclk,
      tx_reset                    => tx_reset,
      tx_axis_mac_tdata           => tx_axis_mac_tdata,
      tx_axis_mac_tvalid          => tx_axis_mac_tvalid,
      tx_axis_mac_tlast           => tx_axis_mac_tlast,
      tx_axis_mac_tuser           => tx_axis_mac_tuser,
      tx_axis_mac_tready          => tx_axis_mac_tready,
      tx_collision                => open,
      tx_retransmit               => open,
      pause_req                   => '0',
      pause_val                   => (others=>'0'),
      refclk                      => refclk,
      gmii_txd                    => gmii_txd,
      gmii_tx_en                  => gmii_tx_en,
      gmii_tx_er                  => gmii_tx_er,
      gmii_tx_clk                 => gmii_tx_clk,
      gmii_rxd                    => gmii_rxd,
      gmii_rx_dv                  => gmii_rx_dv,
      gmii_rx_er                  => gmii_rx_er,
      gmii_rx_clk                 => gmii_rx_clk,
      gmii_col                    => gmii_col,
      gmii_crs                    => gmii_crs,
      mii_tx_clk                  => mii_tx_clk,
      glbl_rstn                   => reset_n,
      rx_axi_rstn                 => reset_n,
      tx_axi_rstn                 => reset_n);

  reset_n                         <= NOT(reset);

  inst_udp_tx : udp_tx
    generic map (
      DEVICE                      => DEVICE)
    port map (
      clk                         => clk,
      reset                       => reset,
      mac_addr_src                => tx_mac_addr_src,
      mac_addr_dest               => tx_mac_addr_dest,
      ip_addr_src                 => tx_ip_addr_src,
      ip_addr_dest                => tx_ip_addr_dest,
      port_src                    => tx_port_src,
      port_dest                   => tx_port_dest,
      start_stb                   => tx_start_stb,
      busy                        => tx_busy,
      payload_size                => tx_payload_size,
      payload_data                => tx_payload_data,
      payload_data_wr_en          => tx_payload_data_wr_en,
      payload_almost_full         => tx_payload_almost_full,
      tx_mac_aclk                 => tx_mac_aclk,
      tx_reset                    => tx_reset,
      tx_axis_mac_tdata           => tx_axis_mac_tdata,
      tx_axis_mac_tvalid          => tx_axis_mac_tvalid,
      tx_axis_mac_tlast           => tx_axis_mac_tlast,
      tx_axis_mac_tuser           => tx_axis_mac_tuser,
      tx_axis_mac_tready          => tx_axis_mac_tready);
 
  inst_udp_rx : udp_rx
    generic map (
      DEVICE                      => DEVICE)
    port map (
      clk                         => clk,
      reset                       => reset,
      mac_addr_src                => rx_mac_addr_src,
      mac_addr_dest               => rx_mac_addr_dest,
      ip_addr_src                 => rx_ip_addr_src,
      ip_addr_dest                => rx_ip_addr_dest,
      port_src                    => rx_port_src,
      port_dest                   => rx_port_dest,
      done_stb                    => rx_done_stb,
      busy                        => rx_busy,
      frame_error                 => rx_frame_error,
      payload_size                => rx_payload_size,
      payload_data                => rx_payload_data,
      payload_data_rd_en          => rx_payload_data_rd_en,
      payload_almost_empty        => rx_payload_almost_empty,
      rx_mac_aclk                 => rx_mac_aclk,
      rx_reset                    => rx_reset,
      rx_axis_mac_tdata           => rx_axis_mac_tdata,
      rx_axis_mac_tvalid          => rx_axis_mac_tvalid,
      rx_axis_mac_tlast           => rx_axis_mac_tlast,
      rx_axis_mac_tuser           => rx_axis_mac_tuser);

end architecture;