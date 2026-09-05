# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

import queue
import threading

from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge, Timer


class RTLSimulator:
    """Synchronous PeakRDL callbacks backed by the DUT Avalon-MM port."""

    def __init__(self, dut):
        self.dut = dut
        self.req_queue = queue.Queue()

    async def worker(self):
        while True:
            if self.req_queue.empty():
                await Timer(1, unit="ns")
                continue

            request = self.req_queue.get()
            try:
                if request["type"] == "read":
                    request["result"] = await self._read(request["addr"])
                else:
                    await self._write(request["addr"], request["data"])
            except BaseException as exc:
                request["exception"] = exc
            finally:
                request["event"].set()

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

    @staticmethod
    def _wait_for_request(request):
        if not request["event"].wait(timeout=30):
            raise TimeoutError("Timed out waiting for the RTL Avalon-MM transaction")
        if request["exception"] is not None:
            raise request["exception"]

    def read(self, addr, width=32, accesswidth=32):
        del width, accesswidth
        request = {
            "type": "read",
            "addr": addr,
            "event": threading.Event(),
            "result": None,
            "exception": None,
        }
        self.req_queue.put(request)
        self._wait_for_request(request)
        return request["result"]

    def write(self, addr, data, width=32, accesswidth=32):
        del width, accesswidth
        request = {
            "type": "write",
            "addr": addr,
            "data": data,
            "event": threading.Event(),
            "exception": None,
        }
        self.req_queue.put(request)
        self._wait_for_request(request)
