## This file is a general .xdc for the Arty-S7 Rev. C
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
#create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];
set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports sysclk];
# create 10 MHz waveform
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports sysclk];


## BUSY
# ARR[1][1]
# set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { uart_data_rdy_out }]; #IO_L4N_T0_D05_14 Sch=ja_n[1]


# LED0_R
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {led_out[0]}]
# LED0_G
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {led_out[1]}]
# LED0_B
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {led_out[2]}]
# LED1_R
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {led_out[3]}]

## PMOD Header JA ARR[2][6]
# ARR[1][2]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_serial_in }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]

##Configuration options, can be used for all designs
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]