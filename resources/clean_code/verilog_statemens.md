### parallel_case
Used in verilog to indicate a mutual exclusivity between statements in a switch-case. It helps the synthesiser.

### always @(*)
Used in verilog to imply a combinatorial loop.
- Make sure however to have an assignment for ALL possivble cases, otherwise latches might be inferred.

### full_case
Makes sure no latches are inferred in the always-statement
- Presence of a default case eliminates the need for this statement.
