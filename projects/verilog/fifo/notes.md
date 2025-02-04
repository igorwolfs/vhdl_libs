# Asynchronous fifo
### Question: Why not simply use a store and read signal instead of a clock, and simply write/read on a rising edge of that signal?
- You might get noise issues / metastability issues.
- It's harder to perform timing analysis.
- You need a way to synchronize the signals when you're dealing with 2 clock domains. (e.g.: when read and write are happening at the same time)