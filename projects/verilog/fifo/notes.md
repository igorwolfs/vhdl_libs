# Asynchronous fifo

## Grayscale values
Grayscale bit-codes are bit-codes that change only 1 bit per number, you can calculate the binary from the grayscale value through:

```verilog
grayscale_value = (binary_value >> 1) ^ binary_value;
// BINARY -> GRAY
assign binary_number = gray_number ^ (gray_number >> 1) ^ (gray_number >> 2) ^ (gray_number >> 3)^ (gray_number >> 4) ^ (gray_number >> 5);

```
The gray to binary conversion is somewhat more complicated: https://www.chipverify.com/verilog/verilog-binary-to-gray

e.g.:
- 


# Questions
### Question: Why not simply use a store and read signal instead of a clock, and simply write/read on a rising edge of that signal?
- You might get noise issues / metastability issues.
- It's harder to perform timing analysis.
- You need a way to synchronize the signals when you're dealing with 2 clock domains. (e.g.: when read and write are happening at the same time)
