<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: csr
  - /home/enio/Projects/etf-tk-sdn/ADASEC-pyHAL/hal/src/csr.rdl
-->

## csr address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x1C

<p>Control and status registers for ADASEC-SDN.</p>

|Offset| Identifier |    Name    |
|------|------------|------------|
|  0x0 |avalon_st_if|avalon_st_if|

## avalon_st_if register file

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x1C

<p>Register file for the Avalon-ST source and sink interfaces.</p>

|Offset|Identifier|        Name       |
|------|----------|-------------------|
| 0x00 |  source  |avalon_st_if.source|
| 0x10 |   sink   | avalon_st_if.sink |

## source register file

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0xC

<p>Register file for the Avalon-ST source interface.</p>

|Offset|Identifier|            Name           |
|------|----------|---------------------------|
|  0x0 |   data   |  avalon_st_if.source.data |
|  0x4 |  control |avalon_st_if.source.control|
|  0x8 |  status  | avalon_st_if.source.status|

### data register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x4

<p>Data register for the Avalon-ST source interface.</p>

|Bits|Identifier|Access|Reset|                Name               |
|----|----------|------|-----|-----------------------------------|
|31:0|   word   |  rw  | 0x0 |avalon_st_if.source.data.word[31:0]|

#### word field

<p>32-bit data value for the Avalon-ST source interface.</p>

### control register

- Absolute Address: 0x4
- Base Offset: 0x4
- Size: 0x4

<p>Control register for the Avalon-ST source interface.</p>

| Bits|Identifier|Access|Reset|                 Name                 |
|-----|----------|------|-----|--------------------------------------|
|  0  |   valid  |  rw  | 0x0 |   avalon_st_if.source.control.valid  |
|  8  |    sop   |  rw  | 0x0 |    avalon_st_if.source.control.sop   |
|  16 |    eop   |  rw  | 0x0 |    avalon_st_if.source.control.eop   |
|25:24|   empty  |  rw  | 0x0 |avalon_st_if.source.control.empty[1:0]|

#### valid field

<p>Indicates that the Avalon-ST source interface has valid data to send. Once asserted by software, the field remains asserted until the transfer is accepted by the destination.</p>

#### sop field

<p>Indicates the start of a frame on the Avalon-ST source interface.</p>

#### eop field

<p>Indicates the end of a frame on the Avalon-ST source interface.</p>

#### empty field

<p>Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST source interface.</p>

### status register

- Absolute Address: 0x8
- Base Offset: 0x8
- Size: 0x4

<p>Status register for the Avalon-ST source interface.</p>

|Bits|Identifier|Access|Reset|              Name              |
|----|----------|------|-----|--------------------------------|
|  0 |   ready  |   r  | 0x0 |avalon_st_if.source.status.ready|

#### ready field

<p>Indicates that the destination Avalon-ST interface is ready to receive data.</p>

## sink register file

- Absolute Address: 0x10
- Base Offset: 0x10
- Size: 0xC

<p>Register file for the Avalon-ST sink interface.</p>

|Offset|Identifier|           Name          |
|------|----------|-------------------------|
|  0x0 |   data   |  avalon_st_if.sink.data |
|  0x4 |  control |avalon_st_if.sink.control|
|  0x8 |  status  | avalon_st_if.sink.status|

### data register

- Absolute Address: 0x10
- Base Offset: 0x0
- Size: 0x4

<p>Data register for the Avalon-ST sink interface.</p>

|Bits|Identifier|Access|Reset|               Name              |
|----|----------|------|-----|---------------------------------|
|31:0|   word   |   r  |  —  |avalon_st_if.sink.data.word[31:0]|

#### word field

<p>32-bit data value for the Avalon-ST sink interface.</p>

### control register

- Absolute Address: 0x14
- Base Offset: 0x4
- Size: 0x4

<p>Control register for the Avalon-ST sink interface.</p>

|Bits|Identifier|Access|Reset|              Name             |
|----|----------|------|-----|-------------------------------|
|  0 |   ready  |  rw  | 0x0 |avalon_st_if.sink.control.ready|

#### ready field

<p>Indicates that the Avalon-ST sink interface is ready to accept a data transfer. Once asserted by software, the field remains asserted until a transfer occurs.</p>

### status register

- Absolute Address: 0x18
- Base Offset: 0x8
- Size: 0x4

<p>Status register for the Avalon-ST sink interface.</p>

| Bits|Identifier|Access|Reset|                Name               |
|-----|----------|------|-----|-----------------------------------|
|  0  |   valid  |   r  |  —  |   avalon_st_if.sink.status.valid  |
|  8  |    sop   |   r  |  —  |    avalon_st_if.sink.status.sop   |
|  16 |    eop   |   r  |  —  |    avalon_st_if.sink.status.eop   |
|25:24|   empty  |   r  |  —  |avalon_st_if.sink.status.empty[1:0]|

#### valid field

<p>Indicates that the Avalon-ST sink interface has valid data to receive.</p>

#### sop field

<p>Indicates the start of a frame on the Avalon-ST sink interface.</p>

#### eop field

<p>Indicates the end of a frame on the Avalon-ST sink interface.</p>

#### empty field

<p>Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST sink interface.</p>
