# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.task import bridge
from cocotb.triggers import RisingEdge

from csr.lib import NormalCallbackSet
from csr.reg_model.csr import csr_cls

from rtl_simulator import RTLSimulator
from tests import test1, test2, test3, test4


async def create_csr(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.avalon_read.value = 0
    dut.avalon_write.value = 0
    dut.avalon_address.value = 0
    dut.avalon_writedata.value = 0
    dut.avalon_byteenable.value = 0xF
    dut.rst.value = 1
    for _ in range(10):
        await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    hw = RTLSimulator(dut)

    return csr_cls(
        callbacks=NormalCallbackSet(
            read_callback=hw.read,
            write_callback=hw.write,
        )
    )


async def run_reg_test(dut, test_func):
    csr = await create_csr(dut)
    await bridge(test_func)(csr)


@cocotb.test()
async def test_1(dut):
    await run_reg_test(dut, test1)


@cocotb.test()
async def test_2(dut):
    await run_reg_test(dut, test2)


@cocotb.test()
async def test_3(dut):
    await run_reg_test(dut, test3)


@cocotb.test()
async def test_4(dut):
    await run_reg_test(dut, test4)
