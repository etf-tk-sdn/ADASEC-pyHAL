# SPDX-FileCopyrightText: 2026 Enio Kaljic
# SPDX-License-Identifier: CERN-OHL-S-2.0

WORD_BYTES = 4
POLL_LIMIT = 100_000


def _ethernet_frame(length, seed):
    if length < 14:
        raise ValueError("An Ethernet frame must contain a 14-byte header")

    header = bytes.fromhex("02000000000102000000000288b5")
    payload = bytes(((seed + 37 * index) & 0xFF) for index in range(length - 14))
    return header + payload


def _wait_for_value(field, expected, description):
    for _ in range(POLL_LIMIT):
        if field.read() == expected:
            return
    raise TimeoutError(f"Timed out waiting for {description}")


def _send_frame(csr, frame):
    source = csr.avalon_st_if.source
    _wait_for_value(source.status.ready, 1, "Avalon-ST source ready")

    for offset in range(0, len(frame), WORD_BYTES):
        chunk = frame[offset:offset + WORD_BYTES]
        empty = WORD_BYTES - len(chunk)
        word = int.from_bytes(chunk.ljust(WORD_BYTES, b"\0"), "little")
        sop = offset == 0
        eop = offset + WORD_BYTES >= len(frame)

        source.data.word.write(word)
        source.control.write(
            1 | (int(sop) << 8) | (int(eop) << 16) | (empty << 24)
        )


def _receive_frame(csr):
    sink = csr.avalon_st_if.sink
    result = bytearray()
    first_word = True

    while True:
        for _ in range(POLL_LIMIT):
            status = sink.status.read()
            if status & 1:
                break
        else:
            raise TimeoutError("Timed out waiting for Avalon-ST sink valid")
        sop = bool(status & (1 << 8))
        eop = bool(status & (1 << 16))
        empty = (status >> 24) & 0x3
        word = sink.data.word.read()

        if sop != first_word:
            raise AssertionError(
                f"Unexpected SOP={int(sop)} while receiving an Ethernet frame"
            )
        if empty and not eop:
            raise AssertionError("Avalon-ST empty is non-zero before EOP")

        valid_bytes = WORD_BYTES - empty if eop else WORD_BYTES
        result.extend(word.to_bytes(WORD_BYTES, "little")[:valid_bytes])

        sink.control.ready.write(1)

        if eop:
            return bytes(result)
        first_word = False


def _assert_loopback(csr, transmitted):
    received = _receive_frame(csr)
    assert received == transmitted, (
        f"Ethernet loopback mismatch: sent {len(transmitted)} bytes, "
        f"received {len(received)} bytes"
    )
    return received


def test1(csr):
    value = 0xAA55_AA55
    csr.test_output.word.write(value)
    looped_back = csr.test_input.word.read()
    assert (looped_back >> 28) == (value >> 28), (
        f"test_output/test_input loopback mismatch: wrote 0x{value:X}, "
        f"read 0x{looped_back:X}"
    )


def test2(csr):
    transmitted = _ethernet_frame(64, seed=0x11)
    _send_frame(csr, transmitted)
    received = _assert_loopback(csr, transmitted)
    print(f"TX frame: {transmitted.hex()}")
    print(f"RX frame: {received.hex()}")


def test3(csr):
    transmitted = (
        _ethernet_frame(64, seed=0x23),
        _ethernet_frame(64, seed=0x91),
    )
    for frame in transmitted:
        _send_frame(csr, frame)
    for frame in transmitted:
        _assert_loopback(csr, frame)


def test4(csr):
    transmitted = _ethernet_frame(1500, seed=0x5A)
    _send_frame(csr, transmitted)
    _assert_loopback(csr, transmitted)
