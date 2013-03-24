onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /user_block_tb/reset
add wave -noupdate /user_block_tb/reset_n
add wave -noupdate /user_block_tb/clk_100MHz
add wave -noupdate /user_block_tb/clk_125MHz
add wave -noupdate /user_block_tb/phase_inc
add wave -noupdate /user_block_tb/phase_inc_stb
add wave -noupdate /user_block_tb/phase_dec
add wave -noupdate /user_block_tb/phase_dec_stb
add wave -noupdate /user_block_tb/phase_cnt
add wave -noupdate -radix hexadecimal /user_block_tb/rx_data
add wave -noupdate -radix hexadecimal /user_block_tb/rx_data_ddr
add wave -noupdate /user_block_tb/rx_data_clk_ddr
add wave -noupdate /user_block_tb/rx_data_clk
add wave -noupdate /user_block_tb/rx_data_clk_locked
add wave -noupdate /user_block_tb/reset_rx_data_clk
add wave -noupdate -radix decimal /user_block_tb/adc_data_i
add wave -noupdate -radix decimal /user_block_tb/adc_data_q
add wave -noupdate -radix hexadecimal /user_block_tb/rx_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/rx_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/rx_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/rx_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/rx_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/rx_port_dest
add wave -noupdate /user_block_tb/rx_done_stb
add wave -noupdate /user_block_tb/rx_busy
add wave -noupdate /user_block_tb/rx_frame_error
add wave -noupdate -radix unsigned /user_block_tb/rx_payload_size
add wave -noupdate -radix hexadecimal /user_block_tb/rx_payload_data
add wave -noupdate /user_block_tb/rx_payload_data_rd_en
add wave -noupdate /user_block_tb/rx_payload_almost_empty
add wave -noupdate /user_block_tb/rx_mac_aclk
add wave -noupdate /user_block_tb/rx_reset
add wave -noupdate -radix hexadecimal /user_block_tb/rx_axis_mac_tdata
add wave -noupdate /user_block_tb/rx_axis_mac_tvalid
add wave -noupdate /user_block_tb/rx_axis_mac_tlast
add wave -noupdate /user_block_tb/rx_axis_mac_tuser
add wave -noupdate -radix hexadecimal /user_block_tb/tx_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/tx_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/tx_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/tx_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/tx_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/tx_port_dest
add wave -noupdate /user_block_tb/tx_start_stb
add wave -noupdate /user_block_tb/tx_busy
add wave -noupdate -radix unsigned /user_block_tb/tx_payload_size
add wave -noupdate -radix hexadecimal /user_block_tb/tx_payload_data
add wave -noupdate /user_block_tb/tx_payload_data_wr_en
add wave -noupdate /user_block_tb/tx_payload_almost_full
add wave -noupdate /user_block_tb/tx_mac_aclk
add wave -noupdate /user_block_tb/tx_reset
add wave -noupdate -radix hexadecimal /user_block_tb/tx_axis_mac_tdata
add wave -noupdate /user_block_tb/tx_axis_mac_tvalid
add wave -noupdate /user_block_tb/tx_axis_mac_tlast
add wave -noupdate /user_block_tb/tx_axis_mac_tuser
add wave -noupdate /user_block_tb/tx_axis_mac_tready
add wave -noupdate /user_block_tb/spec_sense_start_stb
add wave -noupdate /user_block_tb/spec_sense_busy
add wave -noupdate /user_block_tb/spec_sense_done_stb
add wave -noupdate -radix unsigned /user_block_tb/fft_size
add wave -noupdate /user_block_tb/xk_valid
add wave -noupdate -radix decimal /user_block_tb/xk_real
add wave -noupdate -radix decimal /user_block_tb/xk_imag
add wave -noupdate -radix unsigned /user_block_tb/xk_index
add wave -noupdate -radix unsigned /user_block_tb/xk_magnitude_squared
add wave -noupdate -radix unsigned /user_block_tb/threshold
add wave -noupdate /user_block_tb/threshold_exceeded
add wave -noupdate -radix hexadecimal /user_block_tb/user_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/user_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/user_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/user_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/user_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/user_port_dest
add wave -noupdate -radix unsigned /user_block_tb/user_payload_size
add wave -noupdate /user_block_tb/override_network_ctrl
add wave -noupdate /user_block_tb/man_spec_sense_start_stb
add wave -noupdate /user_block_tb/man_send_fft_data
add wave -noupdate /user_block_tb/man_send_mag_squared
add wave -noupdate /user_block_tb/man_send_threshold
add wave -noupdate /user_block_tb/man_fft_size
add wave -noupdate /user_block_tb/man_threshold
add wave -noupdate -divider ddr_to_sdr
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/reset
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_mmcm_ps
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/phase_inc_stb
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/phase_dec_stb
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/phase_cnt
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/ddr_data_clk
add wave -noupdate -radix hexadecimal /user_block_tb/inst_ddr_to_sdr/ddr_data
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_locked
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_sdr
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/sdr_data_vld
add wave -noupdate -radix hexadecimal /user_block_tb/inst_ddr_to_sdr/sdr_data
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/state
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_int
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/ddr_data_clk_bufr
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_locked_int
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_locked_meta1
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_locked_meta2
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/clk_ddr_locked_n
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/psen
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/psincdec
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/psdone
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/phase_cnt_int
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/phase_init
add wave -noupdate -radix decimal /user_block_tb/inst_ddr_to_sdr/ddr_data_rising
add wave -noupdate -radix decimal /user_block_tb/inst_ddr_to_sdr/ddr_data_falling
add wave -noupdate -radix decimal /user_block_tb/inst_ddr_to_sdr/ddr_data_concatenated
add wave -noupdate -radix decimal /user_block_tb/inst_ddr_to_sdr/ddr_data_fifo
add wave -noupdate -radix decimal /user_block_tb/inst_ddr_to_sdr/sdr_data_fifo
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/ddr_data_fifo_wr_en
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/ddr_data_fifo_rd_en
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/almost_empty
add wave -noupdate /user_block_tb/inst_ddr_to_sdr/almost_full
add wave -noupdate -divider udp_tx
add wave -noupdate /user_block_tb/inst_udp_tx/clk
add wave -noupdate /user_block_tb/inst_udp_tx/reset
add wave -noupdate /user_block_tb/inst_udp_tx/tx_reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/port_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/port_dest
add wave -noupdate /user_block_tb/inst_udp_tx/start_stb
add wave -noupdate /user_block_tb/inst_udp_tx/start_sync
add wave -noupdate /user_block_tb/inst_udp_tx/busy
add wave -noupdate -radix unsigned /user_block_tb/inst_udp_tx/payload_size
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/payload_data
add wave -noupdate /user_block_tb/inst_udp_tx/payload_data_wr_en
add wave -noupdate /user_block_tb/inst_udp_tx/payload_data_count
add wave -noupdate -radix unsigned /user_block_tb/inst_udp_tx/payload_rd_data_count
add wave -noupdate /user_block_tb/inst_udp_tx/payload_almost_full
add wave -noupdate /user_block_tb/inst_udp_tx/payload_almost_empty
add wave -noupdate /user_block_tb/inst_udp_tx/payload_underflow
add wave -noupdate /user_block_tb/inst_udp_tx/tx_mac_aclk
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/tx_axis_mac_tdata
add wave -noupdate /user_block_tb/inst_udp_tx/tx_axis_mac_tvalid
add wave -noupdate /user_block_tb/inst_udp_tx/tx_axis_mac_tlast
add wave -noupdate /user_block_tb/inst_udp_tx/tx_axis_mac_tuser
add wave -noupdate /user_block_tb/inst_udp_tx/tx_axis_mac_tready
add wave -noupdate /user_block_tb/inst_udp_tx/state
add wave -noupdate /user_block_tb/inst_udp_tx/busy_meta
add wave -noupdate /user_block_tb/inst_udp_tx/counter
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/header_data
add wave -noupdate /user_block_tb/inst_udp_tx/payload_data_rd_en
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/payload_data_out
add wave -noupdate -radix unsigned /user_block_tb/inst_udp_tx/payload_size_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_header_sum_1
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_header_sum_2
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_header_sum_3
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_header_sum
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_tx/ip_checksum
add wave -noupdate -divider udp_rx
add wave -noupdate /user_block_tb/inst_udp_rx/clk
add wave -noupdate /user_block_tb/inst_udp_rx/reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/port_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/port_dest
add wave -noupdate /user_block_tb/inst_udp_rx/done_stb
add wave -noupdate /user_block_tb/inst_udp_rx/busy
add wave -noupdate /user_block_tb/inst_udp_rx/frame_error
add wave -noupdate -radix unsigned /user_block_tb/inst_udp_rx/payload_size
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/payload_data
add wave -noupdate /user_block_tb/inst_udp_rx/payload_data_rd_en
add wave -noupdate /user_block_tb/inst_udp_rx/payload_almost_empty
add wave -noupdate /user_block_tb/inst_udp_rx/rx_mac_aclk
add wave -noupdate /user_block_tb/inst_udp_rx/rx_reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/rx_axis_mac_tdata
add wave -noupdate /user_block_tb/inst_udp_rx/rx_axis_mac_tvalid
add wave -noupdate /user_block_tb/inst_udp_rx/rx_axis_mac_tlast
add wave -noupdate /user_block_tb/inst_udp_rx/rx_axis_mac_tuser
add wave -noupdate /user_block_tb/inst_udp_rx/state
add wave -noupdate /user_block_tb/inst_udp_rx/counter
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/header_data
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/payload_data_in
add wave -noupdate /user_block_tb/inst_udp_rx/payload_data_wr_en
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/mac_addr_src_rx
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/mac_addr_dest_rx
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_addr_src_rx
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_addr_dest_rx
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/port_src_rx
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/port_dest_rx
add wave -noupdate -radix unsigned /user_block_tb/inst_udp_rx/payload_size_rx
add wave -noupdate /user_block_tb/inst_udp_rx/header_valid
add wave -noupdate /user_block_tb/inst_udp_rx/mac_addr_src_valid
add wave -noupdate /user_block_tb/inst_udp_rx/mac_addr_dest_valid
add wave -noupdate /user_block_tb/inst_udp_rx/ip_checksum_valid
add wave -noupdate /user_block_tb/inst_udp_rx/ip_addr_src_valid
add wave -noupdate /user_block_tb/inst_udp_rx/ip_addr_dest_valid
add wave -noupdate /user_block_tb/inst_udp_rx/port_src_valid
add wave -noupdate /user_block_tb/inst_udp_rx/port_dest_valid
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_header_sum_1
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_header_sum_2
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_header_sum_3
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_header_sum_4
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_header_sum
add wave -noupdate -radix hexadecimal /user_block_tb/inst_udp_rx/ip_checksum
add wave -noupdate -divider spectrum_sense
add wave -noupdate /user_block_tb/inst_spectrum_sense/clk
add wave -noupdate /user_block_tb/inst_spectrum_sense/reset
add wave -noupdate /user_block_tb/inst_spectrum_sense/start_stb
add wave -noupdate /user_block_tb/inst_spectrum_sense/busy
add wave -noupdate /user_block_tb/inst_spectrum_sense/done_stb
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/fft_size
add wave -noupdate -clampanalog 1 -format Analog-Step -height 48 -max 9000.0 -min -9000.0 -radix decimal /user_block_tb/inst_spectrum_sense/xn_real
add wave -noupdate -clampanalog 1 -format Analog-Step -height 48 -max 9000.0 -min -9000.0 -radix decimal /user_block_tb/inst_spectrum_sense/xn_imag
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_index
add wave -noupdate /user_block_tb/inst_spectrum_sense/xk_valid
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_real
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_imag
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_magnitude_squared
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_real_squared
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_imag_squared
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/threshold
add wave -noupdate /user_block_tb/inst_spectrum_sense/threshold_exceeded
add wave -noupdate /user_block_tb/inst_spectrum_sense/state
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_start
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_rfd
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_busy
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_edone
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_done
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_unload
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/fft_size_reg
add wave -noupdate /user_block_tb/inst_spectrum_sense/fft_size_stb
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_magnitude_squared_int
add wave -noupdate /user_block_tb/inst_spectrum_sense/xk_valid_int
add wave -noupdate /user_block_tb/inst_spectrum_sense/xk_valid_dly1
add wave -noupdate /user_block_tb/inst_spectrum_sense/xk_valid_dly2
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_real_int
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_imag_int
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_real_dly1
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_imag_dly1
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_real_dly2
add wave -noupdate -radix decimal /user_block_tb/inst_spectrum_sense/xk_imag_dly2
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_index_int
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_index_dly1
add wave -noupdate -radix unsigned /user_block_tb/inst_spectrum_sense/xk_index_dly2
add wave -noupdate -divider user_block_ctrl
add wave -noupdate /user_block_tb/inst_user_block_ctrl/clk
add wave -noupdate /user_block_tb/inst_user_block_ctrl/reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/user_port_dest
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/user_payload_size
add wave -noupdate /user_block_tb/inst_user_block_ctrl/override_network_ctrl
add wave -noupdate /user_block_tb/inst_user_block_ctrl/man_spec_sense_start_stb
add wave -noupdate /user_block_tb/inst_user_block_ctrl/man_send_fft_data
add wave -noupdate /user_block_tb/inst_user_block_ctrl/man_send_mag_squared
add wave -noupdate /user_block_tb/inst_user_block_ctrl/man_send_threshold
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/man_fft_size
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/man_threshold
add wave -noupdate /user_block_tb/inst_user_block_ctrl/spec_sense_start_stb
add wave -noupdate /user_block_tb/inst_user_block_ctrl/spec_sense_busy
add wave -noupdate /user_block_tb/inst_user_block_ctrl/spec_sense_done_stb
add wave -noupdate /user_block_tb/inst_user_block_ctrl/fft_size
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_valid
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_real
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_imag
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/xk_index
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/xk_magnitude_squared
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/threshold
add wave -noupdate /user_block_tb/inst_user_block_ctrl/threshold_exceeded
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_port_dest
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_busy
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_frame_error
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/rx_payload_size
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/rx_payload_data
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_done_stb
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_payload_data_rd_en
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_payload_almost_empty
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_mac_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_mac_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_ip_addr_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_ip_addr_dest
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_port_src
add wave -noupdate -radix hexadecimal /user_block_tb/inst_user_block_ctrl/tx_port_dest
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_start_stb
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_busy
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/tx_payload_size
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/tx_payload_data
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_payload_data_wr_en
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_payload_almost_full
add wave -noupdate /user_block_tb/inst_user_block_ctrl/ctrl_state
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_counter
add wave -noupdate /user_block_tb/inst_user_block_ctrl/rx_byte_counter
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/rx_payload_size_reg
add wave -noupdate /user_block_tb/inst_user_block_ctrl/spec_sense_start_stb_int
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/fft_size_int
add wave -noupdate /user_block_tb/inst_user_block_ctrl/ctrl_spec_sense_start_stb
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/ctrl_fft_size
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/ctrl_threshold
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/ctrl_config_word
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/config_word
add wave -noupdate /user_block_tb/inst_user_block_ctrl/send_mag_squared
add wave -noupdate /user_block_tb/inst_user_block_ctrl/send_fft
add wave -noupdate /user_block_tb/inst_user_block_ctrl/send_threshold
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_state
add wave -noupdate /user_block_tb/inst_user_block_ctrl/tx_byte_counter
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_real_fifo_almost_empty
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_real_fifo_out
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_real_fifo_rd_en
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_real_ext
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_real_valid
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_imag_fifo_almost_empty
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_imag_fifo_out
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_imag_fifo_rd_en
add wave -noupdate -radix decimal /user_block_tb/inst_user_block_ctrl/xk_imag_ext
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_imag_valid
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_mag_sq_fifo_almost_empty
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/xk_mag_sq_fifo_out
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_mag_sq_fifo_rd_en
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/xk_mag_sq_ext
add wave -noupdate /user_block_tb/inst_user_block_ctrl/xk_mag_sq_valid
add wave -noupdate /user_block_tb/inst_user_block_ctrl/threshold_fifo_almost_empty
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/threshold_fifo_out
add wave -noupdate /user_block_tb/inst_user_block_ctrl/threshold_fifo_rd_en
add wave -noupdate -radix unsigned /user_block_tb/inst_user_block_ctrl/xk_index_ext
add wave -noupdate /user_block_tb/inst_user_block_ctrl/threshold_fifo_wr_en
add wave -noupdate /user_block_tb/inst_user_block_ctrl/threshold_fifo_wr_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {324856963 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
configure wave -valuecolwidth 219
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {972210260 ps} {972792004 ps}
