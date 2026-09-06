# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: AGPL-3.0-or-later

from cocotb.task import resume
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge


class RTLSimulator:
    """Synchronous PeakRDL callbacks backed by the DUT Avalon-MM port."""

    def __init__(self, dut):
        self.dut = dut

    async def _read(self, byte_address):
        await FallingEdge(self.dut.clk)
        self.dut.avalon_address.value = byte_address >> 2
        self.dut.avalon_read.value = 1

        await RisingEdge(self.dut.clk)
        await ReadOnly()
        if int(self.dut.avalon_waitrequest.value):
            raise RuntimeError("Avalon-MM read was unexpectedly stalled")
        if not int(self.dut.avalon_readdatavalid.value):
            raise RuntimeError("Avalon-MM read completed without readdatavalid")
        if int(self.dut.avalon_response.value) != 0:
            raise RuntimeError(
                f"Avalon-MM read returned response {int(self.dut.avalon_response.value)}"
            )
        value = int(self.dut.avalon_readdata.value)

        await FallingEdge(self.dut.clk)
        self.dut.avalon_read.value = 0
        return value

    async def _write(self, byte_address, data):
        await FallingEdge(self.dut.clk)
        self.dut.avalon_address.value = byte_address >> 2
        self.dut.avalon_writedata.value = data
        self.dut.avalon_byteenable.value = 0xF
        self.dut.avalon_write.value = 1

        await RisingEdge(self.dut.clk)
        await ReadOnly()
        if int(self.dut.avalon_waitrequest.value):
            raise RuntimeError("Avalon-MM write was unexpectedly stalled")
        if not int(self.dut.avalon_writeresponsevalid.value):
            raise RuntimeError("Avalon-MM write completed without writeresponsevalid")
        if int(self.dut.avalon_response.value) != 0:
            raise RuntimeError(
                f"Avalon-MM write returned response {int(self.dut.avalon_response.value)}"
            )

        await FallingEdge(self.dut.clk)
        self.dut.avalon_write.value = 0

    @resume
    async def read(self, addr, width=32, accesswidth=32):
        del width, accesswidth
        return await self._read(addr)

    @resume
    async def write(self, addr, data, width=32, accesswidth=32):
        del width, accesswidth
        await self._write(addr, data)
