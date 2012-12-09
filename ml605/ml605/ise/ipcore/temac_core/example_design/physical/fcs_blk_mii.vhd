--------------------------------------------------------------------------------
-- Title      : FCS Block for the MII Physical Interface
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
-- File       : fcs_blk_mii.vhd
-- Version    : 1.4
-------------------------------------------------------------------------------
--
-- (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--------------------------------------------------------------------------------
-- Description: This file assures proper frame transmission by suppressing
--              duplicate FCS bytes should they occur.
--              This file operates with the MII or GMII Tri-speed physical
--              interface, and the Clock Enable advanced clocking scheme only.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity fcs_blk_mii is
  port(
    -- Global signals
    reset               : in  std_logic;

    -- PHY-side input signals
    tx_phy_clk          : in  std_logic;
    txd_from_mac        : in  std_logic_vector(7 downto 0);
    tx_en_from_mac      : in  std_logic;
    tx_er_from_mac      : in  std_logic;

    -- Client-side signals
    tx_client_clk       : in  std_logic;
    tx_stats_byte_valid : in  std_logic;
    tx_collision        : in  std_logic;
    speed_is_10_100     : in  std_logic;

    -- PHY outputs
    txd                 : out std_logic_vector(7 downto 0);
    tx_en               : out std_logic;
    tx_er               : out std_logic
  );
end fcs_blk_mii;

architecture rtl of fcs_blk_mii is

  -- Pipeline registers
  signal txd_r1                : std_logic_vector(7 downto 0);
  signal txd_r2                : std_logic_vector(7 downto 0);
  signal tx_en_r1              : std_logic;
  signal tx_en_r2              : std_logic;
  signal tx_er_r1              : std_logic;
  signal tx_er_r2              : std_logic;

  -- For detecting frame end
  signal tx_stats_byte_valid_r : std_logic;

  -- Counters
  signal tx_en_count           : unsigned(2 downto 0);
  signal tx_byte_count         : unsigned(1 downto 0);
  signal tx_byte_count_r       : unsigned(1 downto 0);

  -- Suppression control signals
  signal collision_r           : std_logic;
  signal tx_en_suppress        : std_logic;
  signal tx_en_suppress_r      : std_logic;
  signal speed_is_10_100_r     : std_logic;

  attribute async_reg : string;
  attribute async_reg of collision_r       : signal is "true";
  attribute async_reg of speed_is_10_100_r : signal is "true";

begin

  -- Create a two-stage pipeline of PHY output signals in preparation for extra
  -- FCS byte determination and TX_EN suppression if one is present.
  pipegen : process(tx_phy_clk, reset)
  begin
    if reset = '1' then
      txd_r1   <= X"00";
      txd_r2   <= X"00";
      tx_en_r1 <= '0';
      tx_en_r2 <= '0';
      tx_er_r1 <= '0';
      tx_er_r2 <= '0';
    elsif tx_phy_clk'event and tx_phy_clk = '1' then
      txd_r1   <= txd_from_mac;
      txd_r2   <= txd_r1;
      tx_en_r1 <= tx_en_from_mac;
      tx_en_r2 <= tx_en_r1;
      tx_er_r1 <= tx_er_from_mac;
      tx_er_r2 <= tx_er_r1;
    end if;
  end process pipegen;

  -- On the PHY-side clock, count the number of cycles that TX_EN remains
  -- asserted for. Only 3 bits are needed for comparison.
  phycountgen : process(tx_phy_clk)
  begin
    if tx_phy_clk'event and tx_phy_clk = '1' then
      if tx_en_from_mac = '1' then
        tx_en_count <= tx_en_count + 1;
      else
        tx_en_count <= (others => '0');
      end if;
    end if;
  end process phycountgen;

  -- On the client-side clock, count the number of cycles that the stats byte
  -- valid signal remains asserted for. Only 2 bits are needed for comparison.
  clientcountgen : process(tx_client_clk)
  begin
    if tx_client_clk'event and tx_client_clk = '1' then
      tx_stats_byte_valid_r <= tx_stats_byte_valid;
      speed_is_10_100_r     <= speed_is_10_100;
      if tx_stats_byte_valid = '1' then
        tx_byte_count <= tx_byte_count + 1;
      else
        tx_byte_count <= (others => '0');
      end if;
    end if;
  end process clientcountgen;

  -- Capture the final stats byte valid count for the frame.
  clientcapgen : process(tx_client_clk)
  begin
    if tx_client_clk'event and tx_client_clk = '1' then
      if tx_stats_byte_valid_r = '1' and tx_stats_byte_valid = '0' then
        tx_byte_count_r <= tx_byte_count;
      end if;
    end if;
  end process clientcapgen;

  -- Generate a signal to suppress TX_EN if the two counts don't match.
  -- (Both counters will be stable when this comparison happens, so clock
  -- domain crossing is not a concern.)
  -- Since the Clock Enable scheme is in use, PHY and client clocks are the same
  -- frequency, so the lower two bits of each counter are compared.
  tx_en_suppress <= '1' when ((tx_en_from_mac = '0' and tx_en_r1 = '1')
                          and (tx_en_count(1 downto 0) /= tx_byte_count_r))
                        else '0';

  -- Register the signal as TX_EN needs to be suppressed over two nibbles. Also
  -- register tx_collision for use in the suppression logic.
  txsuppressgen : process(tx_phy_clk)
  begin
    if tx_phy_clk'event and tx_phy_clk = '1' then
      tx_en_suppress_r <= tx_en_suppress;
      if tx_collision = '1' then
        collision_r <= '1';
      elsif tx_en_r2 = '0' then
        collision_r <= '0';
      end if;
    end if;
  end process txsuppressgen;

  -- Multiplex output signals. When operating at 1 Gbps, bypass this logic
  -- entirely. Otherwise, assign TXD and TX_ER to their pipelined outputs.
  -- If a collision has occurred, assign TX_EN directly so as to maintain a
  -- jam sequence of 32 bits. Suppress TX_EN if an extra FCS byte is present.
  txd   <= txd_from_mac   when  speed_is_10_100_r = '0' else txd_r2;
  tx_er <= tx_er_from_mac when  speed_is_10_100_r = '0' else tx_er_r2;
  tx_en <= tx_en_from_mac when (speed_is_10_100_r = '0' or collision_r = '1')
           else tx_en_r2 and not (tx_en_suppress or tx_en_suppress_r);

end rtl;

