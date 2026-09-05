


"""
Python Wrapper for the csr register model

This code was generated from the PeakRDL-python package version 3.1.2

"""





from typing import Union

from ..sim_lib.register import Register, MemoryRegister
from ..sim_lib.memory import Memory
from ..sim_lib.simulator import MemoryEntry
from ..sim_lib.field import FieldDefinition, FieldType

from ..sim_lib.simulator import Simulator

class csr_simulator_cls(Simulator):

    def _build_registers(self) -> dict[int, Union[list[Union[MemoryRegister, Register]], Union[MemoryRegister, Register]]]:
        return {
            0 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.source.data', readable=True, writable=True,
                                         fields=[FieldDefinition(high=31, low=0, msb=31, lsb=0, inst_name='word', field_type=FieldType.READWRITE),
                                                ]),
            4 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.source.control', readable=True, writable=True,
                                         fields=[FieldDefinition(high=0, low=0, msb=0, lsb=0, inst_name='valid', field_type=FieldType.READWRITE),FieldDefinition(high=8, low=8, msb=8, lsb=8, inst_name='sop', field_type=FieldType.READWRITE),FieldDefinition(high=16, low=16, msb=16, lsb=16, inst_name='eop', field_type=FieldType.READWRITE),FieldDefinition(high=25, low=24, msb=25, lsb=24, inst_name='empty', field_type=FieldType.READWRITE),
                                                ]),
            8 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.source.status', readable=True, writable=False,
                                         fields=[FieldDefinition(high=0, low=0, msb=0, lsb=0, inst_name='ready', field_type=FieldType.READONLY),
                                                ]),
            16 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.sink.data', readable=True, writable=False,
                                         fields=[FieldDefinition(high=31, low=0, msb=31, lsb=0, inst_name='word', field_type=FieldType.READONLY),
                                                ]),
            20 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.sink.control', readable=True, writable=True,
                                         fields=[FieldDefinition(high=0, low=0, msb=0, lsb=0, inst_name='ready', field_type=FieldType.READWRITE),
                                                ]),
            24 : 
    Register(width=32, full_inst_name='csr.avalon_st_if.sink.status', readable=True, writable=False,
                                         fields=[FieldDefinition(high=0, low=0, msb=0, lsb=0, inst_name='valid', field_type=FieldType.READONLY),FieldDefinition(high=8, low=8, msb=8, lsb=8, inst_name='sop', field_type=FieldType.READONLY),FieldDefinition(high=16, low=16, msb=16, lsb=16, inst_name='eop', field_type=FieldType.READONLY),FieldDefinition(high=25, low=24, msb=25, lsb=24, inst_name='empty', field_type=FieldType.READONLY),
                                                ]),
        }

    def _build_memories(self) -> list[MemoryEntry]:
        return [
        ]

if __name__ == '__main__':
    pass
