# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

from collections import deque
from pathlib import Path
import glob
import os
import queue
import shutil
import subprocess
import threading


class HardwareInterface:
    """PeakRDL callback backend for an Altera JTAG-to-Avalon master."""

    def __init__(
        self,
        address=0,
        system_console=None,
        tcl_script=None,
        master_selector=None,
        timeout=30,
    ):
        self.base_address = address
        self.timeout = timeout
        self._command_lock = threading.Lock()
        self._lines = queue.Queue()
        self._diagnostics = deque(maxlen=40)
        self._closed = False
        self._transaction_count = 0

        executable = self._find_system_console(system_console)
        script = Path(tcl_script or Path(__file__).with_name("avalon_bridge.tcl"))
        if not script.is_file():
            raise FileNotFoundError(f"System Console Tcl script not found: {script}")

        environment = os.environ.copy()
        if master_selector:
            environment["ADASEC_MASTER_SELECTOR"] = master_selector

        self._process = subprocess.Popen(
            [
                str(executable),
                "-cli",
                "-disable_readline",
                f"--script={script}",
            ],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            env=environment,
        )
        self._reader = threading.Thread(target=self._read_output, daemon=True)
        self._reader.start()

        try:
            response = self._protocol_response()
        except BaseException:
            self.close(force=True)
            raise
        if not response.startswith("@READY"):
            self.close(force=True)
            raise RuntimeError(f"JTAG-to-Avalon initialization failed: {response}")

    @staticmethod
    def _find_system_console(requested):
        candidates = []
        if requested:
            candidates.append(Path(requested).expanduser())
        if os.environ.get("SYSTEM_CONSOLE"):
            candidates.append(Path(os.environ["SYSTEM_CONSOLE"]).expanduser())
        if discovered := shutil.which("system-console"):
            candidates.append(Path(discovered))

        search_patterns = (
            "/tools/altera*/*/qprogrammer/sopc_builder/bin/system-console",
            "/tools/altera*/*/quartus/sopc_builder/bin/system-console",
            "/opt/intelFPGA*/*/qprogrammer/sopc_builder/bin/system-console",
            "/opt/intelFPGA*/*/quartus/sopc_builder/bin/system-console",
            "/opt/altera*/*/qprogrammer/sopc_builder/bin/system-console",
            "/opt/altera*/*/quartus/sopc_builder/bin/system-console",
        )
        for pattern in search_patterns:
            candidates.extend(
                Path(path) for path in sorted(glob.glob(pattern), reverse=True)
            )

        for candidate in candidates:
            if candidate.is_file() and os.access(candidate, os.X_OK):
                return candidate.resolve()

        raise FileNotFoundError(
            "system-console was not found; pass system_console=... or set SYSTEM_CONSOLE"
        )

    def _read_output(self):
        assert self._process.stdout is not None
        for line in self._process.stdout:
            stripped = line.strip()
            marker = stripped.find("@")
            if marker >= 0:
                if marker:
                    self._diagnostics.append(stripped[:marker].strip())
                self._lines.put(stripped[marker:])
            elif stripped:
                self._diagnostics.append(stripped)
        self._lines.put(None)

    def _protocol_response(self):
        try:
            response = self._lines.get(timeout=self.timeout)
        except queue.Empty as exc:
            details = " | ".join(self._diagnostics)
            raise TimeoutError(
                f"Timed out waiting for System Console response. {details}"
            ) from exc

        if response is None:
            details = " | ".join(self._diagnostics)
            raise RuntimeError(
                f"System Console terminated unexpectedly (exit "
                f"{self._process.poll()}). {details}"
            )
        if response.startswith("@ERR"):
            raise RuntimeError(response)
        return response

    def _command(self, command):
        with self._command_lock:
            if self._closed or self._process.poll() is not None:
                raise RuntimeError("System Console connection is closed")
            assert self._process.stdin is not None
            self._transaction_count += 1
            self._process.stdin.write(command + "\n")
            self._process.stdin.flush()
            try:
                return self._protocol_response()
            except TimeoutError as exc:
                self.close(force=True)
                raise TimeoutError(
                    f"{exc} (command #{self._transaction_count}: {command})"
                ) from exc
            except RuntimeError as exc:
                raise type(exc)(
                    f"{exc} (command #{self._transaction_count}: {command})"
                ) from exc

    @staticmethod
    def _validate_word(address, value=None):
        if not 0 <= address <= 0xFFFF_FFFF:
            raise ValueError("Address must be an unsigned 32-bit value")
        if address & 0x3:
            raise ValueError("32-bit accesses require a 4-byte-aligned address")
        if value is not None and not 0 <= value <= 0xFFFF_FFFF:
            raise ValueError("Data must be an unsigned 32-bit value")

    def read32(self, address):
        self._validate_word(address)
        response = self._command(f"READ32 0x{address:08X}")
        if not response.startswith("@DATA "):
            raise RuntimeError(f"Unexpected System Console response: {response}")
        return int(response.split()[1], 16)

    def write32(self, address, value):
        self._validate_word(address, value)
        response = self._command(f"WRITE32 0x{address:08X} 0x{value:08X}")
        if response != "@OK":
            raise RuntimeError(f"Unexpected System Console response: {response}")

    def read(self, addr, width=32, accesswidth=32):
        if width != 32 or accesswidth != 32:
            raise ValueError("HardwareInterface supports only 32-bit CSR accesses")
        return self.read32(self.base_address + addr)

    def write(self, addr, data, width=32, accesswidth=32):
        if width != 32 or accesswidth != 32:
            raise ValueError("HardwareInterface supports only 32-bit CSR accesses")
        self.write32(self.base_address + addr, data)

    def close(self, force=False):
        if self._closed:
            return
        self._closed = True

        if self._process.poll() is None and not force:
            try:
                assert self._process.stdin is not None
                self._process.stdin.write("QUIT\n")
                self._process.stdin.flush()
                self._protocol_response()
                self._process.wait(timeout=5)
            except (BrokenPipeError, RuntimeError, TimeoutError, subprocess.TimeoutExpired):
                force = True

        if self._process.poll() is None:
            self._process.terminate()
            try:
                self._process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self._process.kill()
                self._process.wait(timeout=5)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    def __del__(self):
        process = getattr(self, "_process", None)
        if process is not None and process.poll() is None:
            process.terminate()
