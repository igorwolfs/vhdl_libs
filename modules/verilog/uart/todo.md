# TODO
- Separate the RX and TX output clock from the baud generator, the TX clock doesn't need the subsampling as the RX does
- Write down in comment how much time the data_rdy_in should be asserted for sending.

# Questions
- Do we reall need the tx_busy AND the tx_done? Why do we need it? Can't we just only use the tx_done_out?
    - You need it for interrupts and stuff like that

# Notes
## Asynchronous reset
- asynchronous reset is required in this code. The reset might not always last longer than a single clock edge, the UART TX / RX peripherals are driven by a single clock edge. 
