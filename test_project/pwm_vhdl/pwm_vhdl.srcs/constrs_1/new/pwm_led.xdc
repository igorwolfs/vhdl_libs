

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