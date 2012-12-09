--------------------------------------------------------------------------------
--     (c) Copyright 1995 - 2010 Xilinx, Inc. All rights reserved.            --
--                                                                            --
--     This file contains confidential and proprietary information            --
--     of Xilinx, Inc. and is protected under U.S. and                        --
--     international copyright and other intellectual property                --
--     laws.                                                                  --
--                                                                            --
--     DISCLAIMER                                                             --
--     This disclaimer is not a license and does not grant any                --
--     rights to the materials distributed herewith. Except as                --
--     otherwise provided in a valid license issued to you by                 --
--     Xilinx, and to the maximum extent permitted by applicable              --
--     law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND                --
--     WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES            --
--     AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING              --
--     BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-                 --
--     INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and               --
--     (2) Xilinx shall not be liable (whether in contract or tort,           --
--     including negligence, or under any other theory of                     --
--     liability) for any loss or damage of any kind or nature                --
--     related to, arising under or in connection with these                  --
--     materials, including for any direct, or any indirect,                  --
--     special, incidental, or consequential loss or damage                   --
--     (including loss of data, profits, goodwill, or any type of             --
--     loss or damage suffered as a result of any action brought              --
--     by a third party) even if such damage or loss was                      --
--     reasonably foreseeable or Xilinx had been advised of the               --
--     possibility of the same.                                               --
--                                                                            --
--     CRITICAL APPLICATIONS                                                  --
--     Xilinx products are not designed or intended to be fail-               --
--     safe, or for use in any application requiring fail-safe                --
--     performance, such as life-support or safety devices or                 --
--     systems, Class III medical devices, nuclear facilities,                --
--     applications related to the deployment of airbags, or any              --
--     other applications that could lead to death, personal                  --
--     injury, or severe property or environmental damage                     --
--     (individually and collectively, "Critical                              --
--     Applications"). Customer assumes the sole risk and                     --
--     liability of any use of Xilinx products in Critical                    --
--     Applications, subject only to applicable laws and                      --
--     regulations governing limitations on product liability.                --
--                                                                            --
--     THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS               --
--     PART OF THIS FILE AT ALL TIMES.                                        --
--------------------------------------------------------------------------------
-- You must compile the wrapper file ethFifo.vhd when simulating
-- the core, ethFifo. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
Library XilinxCoreLib;
-- synthesis translate_on
ENTITY ethFifo IS
	port (
	rst: in std_logic;
	wr_clk: in std_logic;
	rd_clk: in std_logic;
	din: in std_logic_vector(31 downto 0);
	wr_en: in std_logic;
	rd_en: in std_logic;
	dout: out std_logic_vector(7 downto 0);
	full: out std_logic;
	empty: out std_logic);
END ethFifo;

ARCHITECTURE ethFifo_a OF ethFifo IS
-- synthesis translate_off
component wrapped_ethFifo
	port (
	rst: in std_logic;
	wr_clk: in std_logic;
	rd_clk: in std_logic;
	din: in std_logic_vector(31 downto 0);
	wr_en: in std_logic;
	rd_en: in std_logic;
	dout: out std_logic_vector(7 downto 0);
	full: out std_logic;
	empty: out std_logic);
end component;

-- Configuration specification 
	for all : wrapped_ethFifo use entity XilinxCoreLib.fifo_generator_v7_2(behavioral)
		generic map(
			c_wach_type => 0,
			c_has_data_counts_wrch => 0,
			c_has_almost_empty => 0,
			c_has_valid => 0,
			c_implementation_type_rach => 1,
			c_axi_buser_width => 1,
			c_has_data_counts_rdch => 0,
			c_axi_aruser_width => 1,
			c_prog_empty_type_wrch => 5,
			c_has_overflow => 0,
			c_full_flags_rst_val => 1,
			c_axi_id_width => 4,
			c_has_almost_full => 0,
			c_error_injection_type_wrch => 0,
			c_wrch_type => 0,
			c_prog_empty_type_rdch => 5,
			c_has_backup => 0,
			c_has_rd_rst => 0,
			c_implementation_type => 2,
			c_has_axi_buser => 0,
			c_application_type_wrch => 0,
			c_implementation_type_wach => 1,
			c_implementation_type_axis => 1,
			c_use_ecc_wrch => 0,
			c_error_injection_type_rdch => 0,
			c_has_data_counts_wdch => 0,
			c_reg_slice_mode_rach => 0,
			c_application_type_rdch => 0,
			c_use_ecc_rdch => 0,
			c_prog_empty_type_wdch => 5,
			c_prog_full_type_wrch => 5,
			c_has_axi_wuser => 0,
			c_error_injection_type_wdch => 0,
			c_memory_type => 1,
			c_has_master_ce => 0,
			c_reg_slice_mode_wach => 0,
			c_prog_full_thresh_assert_val_wrch => 1023,
			c_prog_full_type_rdch => 5,
			c_reg_slice_mode_axis => 0,
			c_prog_empty_thresh_assert_val_wrch => 1022,
			c_din_width_wrch => 2,
			c_rdch_type => 0,
			c_prim_fifo_type => "1kx36",
			c_use_ecc => 0,
			c_application_type_wdch => 0,
			c_axi_ruser_width => 1,
			c_use_ecc_wdch => 0,
			c_rd_depth => 4096,
			c_has_underflow => 0,
			c_prog_full_thresh_assert_val_rdch => 1023,
			c_has_prog_flags_wrch => 0,
			c_prog_empty_thresh_assert_val_rdch => 1022,
			c_has_axis_tkeep => 0,
			c_din_width_rdch => 64,
			c_rd_pntr_width => 12,
			c_prog_full_type_wdch => 5,
			c_has_prog_flags_rdch => 0,
			c_wr_freq => 1,
			c_has_axis_tuser => 0,
			c_use_common_overflow => 0,
			c_wr_depth_wrch => 16,
			c_mif_file_name => "BlankString",
			c_prog_full_thresh_assert_val_wdch => 1023,
			c_wr_data_count_width => 10,
			c_axi_addr_width => 32,
			c_has_axis_tstrb => 0,
			c_prog_empty_thresh_assert_val_wdch => 1022,
			c_wr_pntr_width_rach => 4,
			c_din_width_wdch => 64,
			c_wr_depth_rdch => 1024,
			c_error_injection_type => 0,
			c_dout_width => 8,
			c_wr_pntr_width => 10,
			c_rach_type => 0,
			c_has_axis_tlast => 0,
			c_has_prog_flags_wdch => 0,
			c_axis_tdest_width => 4,
			c_overflow_low => 0,
			c_axi_awuser_width => 1,
			c_axis_type => 0,
			c_use_fifo16_flags => 0,
			c_has_wr_ack => 0,
			c_prog_empty_thresh_negate_val => 3,
			c_dout_rst_val => "0",
			c_wr_pntr_width_wach => 4,
			c_wr_depth_wdch => 1024,
			c_axis_tuser_width => 4,
			c_wr_pntr_width_axis => 10,
			c_prog_empty_type => 0,
			c_has_wr_rst => 0,
			c_has_axis_tid => 0,
			c_valid_low => 0,
			c_implementation_type_wrch => 1,
			c_use_default_settings => 0,
			c_has_axi_awuser => 0,
			c_implementation_type_rdch => 1,
			c_enable_rst_sync => 1,
			c_wr_depth => 1024,
			c_prog_empty_thresh_assert_val => 2,
			c_reg_slice_mode_wrch => 0,
			c_prog_full_thresh_negate_val => 1020,
			c_has_data_counts_rach => 0,
			c_wr_ack_low => 0,
			c_implementation_type_wdch => 1,
			c_prog_full_thresh_assert_val => 1021,
			c_has_axi_ruser => 0,
			c_preload_latency => 1,
			c_reg_slice_mode_rdch => 0,
			c_wr_response_latency => 1,
			c_axi_wuser_width => 1,
			c_has_axis_tdest => 0,
			c_family => "virtex6",
			c_has_axis_tdata => 0,
			c_has_data_count => 0,
			c_prog_empty_type_rach => 5,
			c_init_wr_pntr_val => 0,
			c_error_injection_type_rach => 0,
			c_has_data_counts_wach => 0,
			c_has_data_counts_axis => 0,
			c_has_rd_data_count => 0,
			c_data_count_width => 10,
			c_count_type => 0,
			c_has_axi_rd_channel => 0,
			c_application_type_rach => 0,
			c_reg_slice_mode_wdch => 0,
			c_use_ecc_rach => 0,
			c_default_value => "BlankString",
			c_prog_empty_type_wach => 5,
			c_enable_rlocs => 0,
			c_prog_empty_type_axis => 5,
			c_rd_data_count_width => 12,
			c_interface_type => 0,
			c_has_axi_wr_channel => 0,
			c_axi_type => 0,
			c_error_injection_type_wach => 0,
			c_error_injection_type_axis => 0,
			c_prog_full_type_rach => 5,
			c_has_slave_ce => 0,
			c_has_wr_data_count => 0,
			c_axis_tid_width => 8,
			c_use_dout_rst => 1,
			c_application_type_wach => 0,
			c_axis_tdata_width => 64,
			c_use_ecc_wach => 0,
			c_application_type_axis => 0,
			c_msgon_val => 1,
			c_preload_regs => 0,
			c_use_ecc_axis => 0,
			c_wr_pntr_width_wrch => 4,
			c_prog_full_thresh_assert_val_rach => 1023,
			c_common_clock => 0,
			c_rd_freq => 1,
			c_use_embedded_reg => 0,
			c_prog_empty_thresh_assert_val_rach => 1022,
			c_din_width_rach => 32,
			c_has_meminit_file => 0,
			c_add_ngc_constraint => 0,
			c_prog_full_type => 0,
			c_optimization_mode => 0,
			c_wr_pntr_width_rdch => 10,
			c_prog_full_type_wach => 5,
			c_has_prog_flags_rach => 0,
			c_prog_full_type_axis => 5,
			c_din_width => 32,
			c_has_axis_tready => 1,
			c_use_common_underflow => 0,
			c_axis_tstrb_width => 4,
			c_prog_full_thresh_assert_val_wach => 1023,
			c_prog_full_thresh_assert_val_axis => 1023,
			c_prog_empty_thresh_assert_val_wach => 1022,
			c_din_width_wach => 32,
			c_wr_depth_rach => 16,
			c_axi_data_width => 64,
			c_prog_empty_thresh_assert_val_axis => 1022,
			c_din_width_axis => 1,
			c_has_axi_aruser => 0,
			c_use_fwft_data_count => 0,
			c_wr_pntr_width_wdch => 10,
			c_has_prog_flags_wach => 0,
			c_axis_tkeep_width => 4,
			c_has_prog_flags_axis => 0,
			c_wdch_type => 0,
			c_underflow_low => 0,
			c_has_srst => 0,
			c_has_rst => 1,
			c_has_int_clk => 0,
			c_wr_depth_wach => 16,
			c_wr_depth_axis => 1024);
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_ethFifo
		port map (
			rst => rst,
			wr_clk => wr_clk,
			rd_clk => rd_clk,
			din => din,
			wr_en => wr_en,
			rd_en => rd_en,
			dout => dout,
			full => full,
			empty => empty);
-- synthesis translate_on

END ethFifo_a;

