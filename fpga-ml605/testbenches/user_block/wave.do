onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {DDR Interface}
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/user_ddr_intf_mode
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/user_ddr_intf_mode_stb
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/UART_TX
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/RX_DATA_CLK_N
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/RX_DATA_CLK_P
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/RX_DATA_N
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/RX_DATA_P
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/TX_DATA_N
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/TX_DATA_P
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_2x
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_locked
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/clk_ddr_phase
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_rx_fifo
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_fifo_data_i
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_fifo_data_q
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_rd_en
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_underflow
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_almost_empty
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_tx_fifo
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_reset
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_fifo_data_i
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_fifo_data_q
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_wr_en
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_overflow
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_almost_full
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/state
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_int
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_2x_int
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/ddr_data_clk
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/ddr_data_clk_bufr
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_locked_int
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/clk_ddr_locked_n
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/psen
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/psincdec
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/psdone
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_busy
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/ddr_data_stall_stb
add wave -noupdate -radix hexadecimal -childformat {{/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(7) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(6) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(5) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(4) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(3) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(2) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(1) -radix hexadecimal} {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(0) -radix hexadecimal}} -expand -subitemconfig {/user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(7) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(6) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(5) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(4) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(3) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(2) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(1) {-height 22 -radix hexadecimal} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode(0) {-height 22 -radix hexadecimal}} /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/ddr_intf_mode_stb
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/phase_inc_stb
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/phase_init
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/best_phase
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/mmcm_phase
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/error_cnt
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/best_phase_error_cnt
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/word_cnt
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/align_a_cnt
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/align_b_cnt
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_data_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_data_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_data_2x_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_data_2x_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_data_2x_ddr
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_almost_full
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/rx_fifo_almost_full_n
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_fifo_din
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/rx_fifo_dout
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/ping_pong
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_data_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_data_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_data_2x_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_data_2x_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_data_2x_ddr
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_almost_empty
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/tx_fifo_almost_empty_n
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_fifo_din
add wave -noupdate -radix hexadecimal /user_block_tb/inst_usrp_ddr_intf/tx_fifo_dout
add wave -noupdate -divider {CRUSH Interface}
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/clk
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/reset
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/RX_DATA_CLK_N
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/RX_DATA_CLK_P
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/RX_DATA_N
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/RX_DATA_P
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/TX_DATA_N
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/TX_DATA_P
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/UART_RX
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_busy
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_error
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_start_bit
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_stop_bit
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_parity
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_parity_local
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/inst_uart/tx_parity
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/inst_uart/tx_data
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/inst_uart/tx_data_int
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/inst_uart/rx_state
add wave -noupdate /user_block_tb/inst_usrp_ddr_intf/inst_uart/tx_state
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/adc_channel_a
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/adc_channel_b
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/adc_i
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/adc_q
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_channel_a_in
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_channel_b_in
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_i_in
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_q_in
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_channel_a
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_channel_b
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_i
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dac_q
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/clk_2x
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/clk_2x_180
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/clk_2x_dcm
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/clk_2x_180_dcm
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/dcm_locked
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/fifo_reset
add wave -noupdate -radix hexadecimal -childformat {{/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(7) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(6) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(5) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(4) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(3) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(2) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(1) -radix hexadecimal} {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(0) -radix hexadecimal}} -subitemconfig {/user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(7) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(6) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(5) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(4) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(3) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(2) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(1) {-height 22 -radix hexadecimal} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode(0) {-height 22 -radix hexadecimal}} /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/ddr_intf_mode_stb
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/ddr_intf_rx_mode_reg
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/ddr_intf_tx_mode_reg
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_channel_a_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_channel_b_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_i_reg
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_q_reg
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_i_trunc
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_q_trunc
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_i_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/adc_q_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/dac_channel_a_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/dac_channel_b_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/dac_i_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/dac_q_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_data_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_data_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_data_2x_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_data_2x_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_data_2x_ddr
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_data_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_data_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_data_2x_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_data_2x_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_data_2x_ddr
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/rx_data_clk_2x_ddr
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/test_pattern_cnt
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/test_pattern_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/test_pattern_b
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/sine_pattern_cnt
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/sine_pattern_a
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/sine_pattern_b
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_fifo_din
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/tx_fifo_almost_full_n
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/tx_fifo_almost_empty_n
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/tx_fifo_dout
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/tx_fifo_almost_full
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/tx_fifo_almost_empty
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_fifo_din
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/rx_fifo_almost_full_n
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/rx_fifo_almost_empty_n
add wave -noupdate -radix hexadecimal /user_block_tb/inst_crush_ddr_intf/rx_fifo_dout
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/rx_fifo_almost_full
add wave -noupdate /user_block_tb/inst_crush_ddr_intf/rx_fifo_almost_empty
add wave -noupdate -divider {BPSK Gen}
add wave -noupdate /user_block_tb/inst_bpsk_tx/clk
add wave -noupdate /user_block_tb/inst_bpsk_tx/reset
add wave -noupdate /user_block_tb/inst_bpsk_tx/mode
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/freq
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/data_freq
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/i
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/q
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/mode_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/freq_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/data_freq_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/i_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/q_int
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/phase_accum
add wave -noupdate /user_block_tb/inst_bpsk_tx/lfsr
add wave -noupdate -radix hexadecimal /user_block_tb/inst_bpsk_tx/lfsr_counter
add wave -noupdate /user_block_tb/inst_bpsk_tx/lfsr_shift
add wave -noupdate /user_block_tb/inst_bpsk_tx/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26601100 ps} 0} {{Cursor 2} {43961100 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 298
configure wave -valuecolwidth 135
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
WaveRestoreZoom {0 ps} {187658240 ps}
