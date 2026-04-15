#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

TIME_UNIT = "ns"
CLOCK_PERIOD = 10

SEQ = [
    0xDEADBEEF,
    0xCAFEBABE,
    0xCAFEBABE,
    0x1337C0DE,
    0x1337C0DE,
    0xDEADBEEF,
    0xDEADBEEF,
]


@cocotb.test()
async def main_test(dut):
    """Try accessing the design."""

    dut._log.info("Running test...")

    # Start clock
    dut._log.info("Starting clock with period %d %s..." % (CLOCK_PERIOD, TIME_UNIT))
    cocotb.start_soon(Clock(dut.mclk, CLOCK_PERIOD, unit=TIME_UNIT).start())

    for i in SEQ:
        await RisingEdge(dut.mclk)
        dut.bus_in.value = i

    await Timer(4 * CLOCK_PERIOD, unit=TIME_UNIT)

    dut._log.info("Running test...done")
