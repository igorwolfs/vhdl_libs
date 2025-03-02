# AHB specification
AMBA family includes
- AHB
	- AHB lite (single master, no arbitration)
	- AHB2
	- AHB5 (split transactions, retry, atomic operations)
- ASB (deprecated)
- APB (low power peripheral bus)
- AXI
	- AXI full
	- AXI lite
- ACE (extension for multi-core systems)

## Multiple masters vs single master
### Multiple amsteres are needed
- In case of DMA
	- Memory reads and writes need to happen here without CPU intervention. So it needs to have master-control over the memory bus.
	- Often used in high-speed peripherals.
- In case of GPU, VPU, APU (separate processing units)
- Debug and Trace units


# Sources
- AXI stream: https://www.youtube.com/watch?v=GyYmSZZor1s&t=494s&ab_channel=FPGAsforBeginners
- AXI introduction: https://www.youtube.com/watch?v=p5RIVEuxUds&ab_channel=FPGAsforBeginners
- https://zipcpu.com/blog/2020/03/23/wbm2axisp.html
- https://www.logic-fruit.com/blog/digital-interfaces/axi-full-axi-lite-interfaces/?srsltid=AfmBOorKPvldSIH5TJ-2Vwoh0vb5MNIirXm0bgMbGsXBbNGeibpnNZil
- https://zipcpu.com/blog/2020/03/23/wbm2axisp.html
