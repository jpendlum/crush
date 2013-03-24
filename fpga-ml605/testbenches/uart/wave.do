onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /uart_tb/clk
add wave -noupdate /uart_tb/reset
add wave -noupdate /uart_tb/tx_busy
add wave -noupdate /uart_tb/tx_data_stb
add wave -noupdate /uart_tb/tx_data
add wave -noupdate /uart_tb/rx_busy
add wave -noupdate /uart_tb/rx_data_stb
add wave -noupdate /uart_tb/rx_data
add wave -noupdate /uart_tb/rx_error
add wave -noupdate /uart_tb/tx
add wave -noupdate /uart_tb/rx
add wave -noupdate /uart_tb/rx_test_data
add wave -noupdate -divider DUT
add wave -noupdate /uart_tb/dut/tx_busy
add wave -noupdate /uart_tb/dut/tx_data_stb
add wave -noupdate /uart_tb/dut/tx_data
add wave -noupdate /uart_tb/dut/rx_busy
add wave -noupdate /uart_tb/dut/rx_data_stb
add wave -noupdate /uart_tb/dut/rx_data
add wave -noupdate /uart_tb/dut/rx_error
add wave -noupdate /uart_tb/dut/tx
add wave -noupdate /uart_tb/dut/rx
add wave -noupdate /uart_tb/dut/rx_state
add wave -noupdate /uart_tb/dut/tx_state
add wave -noupdate /uart_tb/dut/rx_meta
add wave -noupdate /uart_tb/dut/rx_sync
add wave -noupdate /uart_tb/dut/rx_sync_dly1
add wave -noupdate /uart_tb/dut/rx_start_bit
add wave -noupdate /uart_tb/dut/rx_stop_bit
add wave -noupdate /uart_tb/dut/rx_parity
add wave -noupdate /uart_tb/dut/rx_parity_calc
add wave -noupdate /uart_tb/dut/rx_parity_local
add wave -noupdate /uart_tb/dut/rx_data_int
add wave -noupdate /uart_tb/dut/rx_bit_cnt
add wave -noupdate /uart_tb/dut/rx_bit_period_cnt
add wave -noupdate /uart_tb/dut/tx_int
add wave -noupdate /uart_tb/dut/tx_data_int
add wave -noupdate /uart_tb/dut/tx_parity
add wave -noupdate /uart_tb/dut/tx_parity_calc
add wave -noupdate /uart_tb/dut/tx_bit_cnt
add wave -noupdate /uart_tb/dut/tx_bit_period_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28822278 ps} 0} {{Cursor 2} {109828047 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 182
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {318865408 ps}
