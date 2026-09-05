# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

from csr.lib import NormalCallbackSet
from csr.reg_model.csr import csr_cls
from hardware_interface import HardwareInterface
from tests import test1, test2, test3, test4

if __name__ == '__main__':
    with HardwareInterface(address=0) as hw:
        csr = csr_cls(
            callbacks=NormalCallbackSet(
                read_callback=hw.read,
                write_callback=hw.write,
            )
        )
        for test in (test1, test2, test3, test4):
            print(f"Running {test.__name__}...", flush=True)
            test(csr)
            print(f"{test.__name__}: PASS", flush=True)
