

# CLOCK (UCLK, external 100 MHz input clock)
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports clk]

# Waveform {0, 5} Indicates rising and falling edge times over 1 clock cycle (so out of 10 ns rise at 0 ns, fall at 5 ns.)
create_clock -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# LED0_R
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
# LED0_G
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
# LED0_B
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
# LED1_R
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

# ARRAY [1][2]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_serial_in }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]

# NRST_IN
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { nrst_in }]; #IO_L20N_T3_A19_15 Sch=sw[0]
