set_property SRC_FILE_INFO {cfile:/home/iwolfs/Work/Projects/fpga_project/xilinx/xilinx-experiments/UART_TX_RX_VER/UART_TX_RX_VER.srcs/constrs_1/imports/constraints/Arty-S7-25-Master.xdc rfile:../../../UART_TX_RX_VER.srcs/constrs_1/imports/constraints/Arty-S7-25-Master.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:9 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports clk_i];
set_property src_info {type:XDC file:1 line:15 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {button_i[0]}];
set_property src_info {type:XDC file:1 line:16 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {button_i[1]}];
set_property src_info {type:XDC file:1 line:17 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {button_i[2]}];
set_property src_info {type:XDC file:1 line:18 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS33} [get_ports {button_i[3]}];
set_property src_info {type:XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { rst_n_i }]; #IO_L4P_T0_D04_14 Sch=ja_p[1]
set_property src_info {type:XDC file:1 line:23 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_data_o }]; #IO_L4N_T0_D05_14 Sch=ja_n[1]
set_property src_info {type:XDC file:1 line:24 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_active_o }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]
set_property src_info {type:XDC file:1 line:25 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_done_o }]; #IO_L5N_T0_D07_14 Sch=ja_n[2]
