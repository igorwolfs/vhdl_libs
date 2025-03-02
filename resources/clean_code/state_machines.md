# Combinatorial state machine + register next state + state counter
## State machine structure
- A combinatorial block determining the next sate
- A register block setting the current state to the next state / or resetting the state
- A counter that registers how long you've been in a state.

## Reason for using state machines
- You have all your state logic in one place
- You link your module output simply to your states
	- e.g.: you set your data-out in case of the DATA state
- You can detect state transitions (e.g.: when going from START->DATA you can already perform the data-load operation if necessary).

# Paper overview
## 1 Always Block FSM coding style
- Has a single always_ff procedure
- assigns the next_state

PRO: typically better synthesis results
CON: verbose

## 2 Always-block FSM coding style - combinatorial outputs

- one always_ff state register
- One combinatorial block to calculate the next state
	- Contains all the state logic
- (Optional) additional combinatorial block producing the output logic based on the state.

## 3 always block FSM coding style
- always_ff state register
- always_comb to calculate the next state
- always_ff to calculate the (next) outputs


## 4 always block FSM coding style
Creating 4-always blocks
- always_comb calcualting the next out values
- 

# Resources
- http://www.sunburst-design.com/papers/CummingsSNUG2019SV_FSM1.pdf
- https://www.youtube.com/watch?v=JXT-4ghebfI&ab_channel=FPGAsforBeginners
