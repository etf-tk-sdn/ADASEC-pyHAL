# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.task import bridge
from cocotb.triggers import RisingEdge

from csr.lib import NormalCallbackSet
from csr.reg_model.csr import csr_cls

from rtl_simulator import RTLSimulator
import tests as shared_tests


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
async def test_1_csr_loopback(dut):
    await run_reg_test(dut, shared_tests.test_1_csr_loopback)


@cocotb.test()
async def test_2_partial_rx_recovery(dut):
    await run_reg_test(dut, shared_tests.test_2_partial_rx_recovery)


@cocotb.test()
async def test_3_single_frame(dut):
    await run_reg_test(dut, shared_tests.test_3_single_frame)


@cocotb.test()
async def test_4_back_to_back_frames(dut):
    await run_reg_test(dut, shared_tests.test_4_back_to_back_frames)


@cocotb.test()
async def test_5_maximum_frame(dut):
    await run_reg_test(dut, shared_tests.test_5_maximum_frame)
