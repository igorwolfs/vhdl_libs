# Resources
- xadc: https://community.element14.com/technologies/fpga-group/b/blog/posts/try-the-digilent-xadc-demo

# Conventions:
- (Systemverilog) https://docs.google.com/document/d/1xA5XUzBtz_D6aSyIBQUwFk_kSUdckrfxa2uzGjMgmCU/edit?tab=t.0


# GENERAL RULES
- external signals: use UPPERCASE
- internal signals: user lowercase

## State machine
- Combinatorial block: lines up the next state
	- Write simple statements outside of the combinatorial block
	- Write complicated related switch statements inside a combinatorial block (like switch-case statements)
		- Make sure to do your instruction decoding inside a combinatorial block
- Register block: registers next state from combinatorial block

