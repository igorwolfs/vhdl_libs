# UART RX
For some reason the RX peripheral isn't receiving anything.
My guess is something is wrong with the RX pin I defined.


- uart_rx_serial_in
- set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_serial_in }]; #IO_L5P_T0_D06_14 Sch=ja_p[2]

Let's check if the actual pin is correct.
