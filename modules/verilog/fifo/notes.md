# Asynchronous fifo
## Circular buffer
Inside of the fifo, data is kept track of using a circular buffer
- read_ptr
- write_ptr

They both increment. The read pointer increments until it reaches the write_ptr. The write_ptr increments until it reaches the end of the buffer.
When both read_ptr and write_ptr reach the end of the buffer, 

## Grayscale values
Grayscale bit-codes are bit-codes that change only 1 bit per number, you can calculate the binary from the grayscale value through:

```verilog
grayscale_value = (binary_value >> 1) ^ binary_value;
// BINARY -> GRAY
assign binary_number = gray_number ^ (gray_number >> 1) ^ (gray_number >> 2) ^ (gray_number >> 3)^ (gray_number >> 4) ^ (gray_number >> 5);
```

Check module "encoder/bin2gray"

### Necessity of grayscale values
They prevent glitches when transferring across clock domains.

The binary values are used to index the buffer.
The gray values are used when transferring the pointers from one clock domain to the other.

BECAUSE
If you have a read pointer that gets incremented by one 
e.g.: 
```verilog
4'b0111 + 4'b0001 = 4'b1000
```
You now have 3 bit-changes. These bits change at different times, since the routing time of the setting circuit for each bit is different.
This error can be "prevented" by using gray code which would make only a single bit change on increase. 

So the only mistake that could be made is that the old value is sampled instead of the new one.

## can_read / can_write
### can_read
```verilog
If the read_ptr != write_ptr then reading can happen.
```

### can_write
```verilog
If write_ptr != {~read_ptr_grey_w[BUFFER_ADDR_WIDTH:BUFFER_ADDR_WIDTH-1], read_ptr_grey_w[BUFFER_ADDR_WIDTH-2:0] };
```

Wrap around is used here to see whether the buffer is empty or full.


# Questions
### Question: Why not simply use a store and read signal instead of a clock, and simply write/read on a rising edge of that signal?
- You might get noise issues / metastability issues.
- It's harder to perform timing analysis.
- You need a way to synchronize the signals when you're dealing with 2 clock domains. (e.g.: when read and write are happening at the same time)
