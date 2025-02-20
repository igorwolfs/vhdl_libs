
import os
import random
import sys
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer
from bin2gray import bin2gray, gray2bin

# cocotb decorator
@cocotb.test()
async def bin2gray_test(dut):
    for i in range(10):
        bin = random.randint(0, 255)
        dut.bin_in.value = bin

        await Timer(2, units="ns")

        assert dut.gray_out.value == bin2gray(
            bin
        ), f"bin_gen {dut.gray.value} bin_sim {bin}"


def run_sim():
    sim = os.getenv("SIM", "verilator")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "rtl"))
    sys.path.append(str(proj_path / "tests"))

    verilog_sources = [proj_path / "rtl" / "bin2gray.v"]
    top = "bin2gray"
    runner = get_runner(sim)

    runner.build(
        verilog_sources=verilog_sources,
        vhdl_sources=[],
        hdl_toplevel=top,
        always=True,
    )
    extra_args="--trace --trace-structs"

    WaveformOptionVcd = f"--vcd={top}.vcd"
    # WaveformOptionVcd = f"--vcd={top}.vcd"
    runner.test(hdl_toplevel=top, test_module="bin2gray_test", extra_args = extra_args) # plusargs=[extra_args, WaveformOptionVcd])

if __name__ == "__main__":
    run_sim()