# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: AGPL-3.0-or-later

from csr.lib import NormalCallbackSet
from csr.reg_model.csr import csr_cls
from hardware_interface import HardwareInterface
from tests import (
    test_1_csr_loopback,
    test_2_partial_rx_recovery,
    test_3_single_frame,
    test_4_back_to_back_frames,
    test_5_maximum_frame,
)


TESTS = (
    test_1_csr_loopback,
    test_2_partial_rx_recovery,
    test_3_single_frame,
    test_4_back_to_back_frames,
    test_5_maximum_frame,
)

if __name__ == '__main__':
    with HardwareInterface(address=0) as hw:
        csr = csr_cls(
            callbacks=NormalCallbackSet(
                read_callback=hw.read,
                write_callback=hw.write,
            )
        )
        for test in TESTS:
            print(f"Running {test.__name__}...", flush=True)
            test(csr)
            print(f"{test.__name__}: PASS", flush=True)
