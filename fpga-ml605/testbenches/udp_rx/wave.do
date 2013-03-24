onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /udp_tx_tb/clk_100MHz
add wave -noupdate /udp_tx_tb/clk_125MHz
add wave -noupdate /udp_tx_tb/reset
add wave -noupdate /udp_tx_tb/reset_n
add wave -noupdate -radix hexadecimal /udp_tx_tb/mac_addr_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/mac_addr_dest
add wave -noupdate -radix hexadecimal /udp_tx_tb/ip_addr_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/ip_addr_dest
add wave -noupdate -radix hexadecimal /udp_tx_tb/port_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/port_dest
add wave -noupdate /udp_tx_tb/start_stb
add wave -noupdate /udp_tx_tb/busy
add wave -noupdate -radix unsigned /udp_tx_tb/payload_size
add wave -noupdate -radix hexadecimal /udp_tx_tb/payload_data
add wave -noupdate /udp_tx_tb/payload_data_wr_en
add wave -noupdate /udp_tx_tb/payload_almost_full
add wave -noupdate /udp_tx_tb/tx_mac_aclk
add wave -noupdate /udp_tx_tb/tx_reset
add wave -noupdate -radix hexadecimal /udp_tx_tb/tx_axis_mac_tdata
add wave -noupdate /udp_tx_tb/tx_axis_mac_tvalid
add wave -noupdate /udp_tx_tb/tx_axis_mac_tlast
add wave -noupdate /udp_tx_tb/tx_axis_mac_tuser
add wave -noupdate /udp_tx_tb/tx_axis_mac_tready
add wave -noupdate -divider DUT
add wave -noupdate /udp_tx_tb/dut/clk
add wave -noupdate /udp_tx_tb/dut/reset
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/mac_addr_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/mac_addr_dest
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_addr_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_addr_dest
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/port_src
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/port_dest
add wave -noupdate /udp_tx_tb/dut/start_stb
add wave -noupdate /udp_tx_tb/dut/busy
add wave -noupdate -radix unsigned /udp_tx_tb/dut/payload_size
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/payload_data
add wave -noupdate /udp_tx_tb/dut/payload_data_wr_en
add wave -noupdate /udp_tx_tb/dut/payload_almost_full
add wave -noupdate /udp_tx_tb/dut/tx_mac_aclk
add wave -noupdate /udp_tx_tb/dut/tx_reset
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/tx_axis_mac_tdata
add wave -noupdate /udp_tx_tb/dut/tx_axis_mac_tvalid
add wave -noupdate /udp_tx_tb/dut/tx_axis_mac_tlast
add wave -noupdate /udp_tx_tb/dut/tx_axis_mac_tuser
add wave -noupdate /udp_tx_tb/dut/tx_axis_mac_tready
add wave -noupdate /udp_tx_tb/dut/state
add wave -noupdate /udp_tx_tb/dut/reset_sync
add wave -noupdate /udp_tx_tb/dut/reset_meta
add wave -noupdate /udp_tx_tb/dut/start_stb_sync
add wave -noupdate /udp_tx_tb/dut/start_stb_meta
add wave -noupdate /udp_tx_tb/dut/busy_meta
add wave -noupdate /udp_tx_tb/dut/busy_tx
add wave -noupdate /udp_tx_tb/dut/counter
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/header_data
add wave -noupdate /udp_tx_tb/dut/payload_data_rd_en
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/payload_data_out
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_header_sum_1
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_header_sum_2
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_header_sum_3
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_header_sum
add wave -noupdate -radix hexadecimal /udp_tx_tb/dut/ip_checksum
add wave -noupdate -radix unsigned /udp_tx_tb/dut/rdcount
add wave -noupdate -radix unsigned /udp_tx_tb/dut/wrcount
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 200
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
WaveRestoreZoom {0 ps} {954 ps}
