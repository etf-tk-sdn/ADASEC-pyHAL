


"""
Unit Tests for the csr register model Python Wrapper

This code was generated from the PeakRDL-python package version 3.1.2
"""






from typing import Union,Iterable
from array import array as Array

import unittest
from unittest.mock import patch, call

import random
from itertools import combinations, chain
import math


from ..lib import UnsupportedWidthError

from ..reg_model import RegModel
from ..reg_model.csr_property_enums import *


from ..lib import FieldReadOnly, FieldWriteOnly, FieldReadWrite
from ..lib import RegReadWrite, RegReadOnly, RegWriteOnly
from ..lib import RegReadWriteArray, RegReadOnlyArray, RegWriteOnlyArray
from ..lib import MemoryReadOnly, MemoryWriteOnly, MemoryReadWrite
from ..lib import MemoryReadOnlyArray, MemoryWriteOnlyArray, MemoryReadWriteArray
from ..lib import AddressMap, RegFile
from ..lib import AddressMapArray, RegFileArray
from ..lib import Memory


from ..lib import NodeArray
from ..lib import Field
from ..lib import Reg

from ..lib import SystemRDLEnum, SystemRDLEnumEntry

from ..lib_test import reverse_bits
from ..lib_test import NodeIterators

from ._csr_test_base import csr_TestCase, csr_TestCase_BlockAccess, csr_TestCase_AltBlockAccess
from ._csr_test_base import __name__ as base_name
from ._csr_test_base import random_enum_reg_value




class csr_single_access(csr_TestCase): # type: ignore[valid-type,misc]



    def test_user_defined_properties(self)  -> None:
        """
        Walk the address map and check user defined properties are correctly pulled up
        """
        with self.subTest(msg='register: csr.avalon_st_if'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.data'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.data.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.control'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.control.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.status'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.status.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.data'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.data.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.control'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.control.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.status'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.status.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.data.word'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.data.word.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.control.valid'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.control.valid.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.control.sop'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.control.sop.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.control.eop'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.control.eop.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.control.empty'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.control.empty.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.source.status.ready'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.source.status.ready.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.data.word'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.data.word.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.control.ready'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.control.ready.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.status.valid'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.status.valid.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.status.sop'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.status.sop.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.status.eop'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.status.eop.udp,{})
            
        with self.subTest(msg='register: csr.avalon_st_if.sink.status.empty'):
            
            
            self.assertDictEqual(self.dut.avalon_st_if.sink.status.empty.udp,{})
            
        

     

    def test_register(self) -> None:
        """
        Walk the registers in the register map and check:
        - the properties
        - it can be read and written to correctly
        """
        with self.subTest(msg='register: csr.avalon_st_if.source.data'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.source.data, address=0, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.source.data",
                                                rdl_desc="Data register for the Avalon-ST source interface.",
                                                inst_name='data',
                                                parent_full_inst_name='csr.avalon_st_if.source')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.source.data, has_sw_readable=True, has_sw_writable=True,
                                                                                          readable_fields=set(['word', ]),
                                                                                          writeable_fields=set(['word', ]) )
        with self.subTest(msg='register: csr.avalon_st_if.source.control'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.source.control, address=4, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.source.control",
                                                rdl_desc="Control register for the Avalon-ST source interface.",
                                                inst_name='control',
                                                parent_full_inst_name='csr.avalon_st_if.source')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.source.control, has_sw_readable=True, has_sw_writable=True,
                                                                                          readable_fields=set(['valid','sop','eop','empty', ]),
                                                                                          writeable_fields=set(['valid','sop','eop','empty', ]) )
        with self.subTest(msg='register: csr.avalon_st_if.source.status'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.source.status, address=8, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.source.status",
                                                rdl_desc="Status register for the Avalon-ST source interface.",
                                                inst_name='status',
                                                parent_full_inst_name='csr.avalon_st_if.source')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.source.status, has_sw_readable=True, has_sw_writable=False,
                                                                                          readable_fields=set(['ready', ]),
                                                                                          writeable_fields=set([ ]) )
        with self.subTest(msg='register: csr.avalon_st_if.sink.data'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.sink.data, address=16, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.sink.data",
                                                rdl_desc="Data register for the Avalon-ST sink interface.",
                                                inst_name='data',
                                                parent_full_inst_name='csr.avalon_st_if.sink')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.sink.data, has_sw_readable=True, has_sw_writable=False,
                                                                                          readable_fields=set(['word', ]),
                                                                                          writeable_fields=set([ ]) )
        with self.subTest(msg='register: csr.avalon_st_if.sink.control'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.sink.control, address=20, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.sink.control",
                                                rdl_desc="Control register for the Avalon-ST sink interface.",
                                                inst_name='control',
                                                parent_full_inst_name='csr.avalon_st_if.sink')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.sink.control, has_sw_readable=True, has_sw_writable=True,
                                                                                          readable_fields=set(['ready', ]),
                                                                                          writeable_fields=set(['ready', ]) )
        with self.subTest(msg='register: csr.avalon_st_if.sink.status'):
            self._single_register_property_test(rut=self.dut.avalon_st_if.sink.status, address=24, width=32, accesswidth=32, size=4,
                                                rdl_name="avalon_st_if.sink.status",
                                                rdl_desc="Status register for the Avalon-ST sink interface.",
                                                inst_name='status',
                                                parent_full_inst_name='csr.avalon_st_if.sink')
            self._single_register_read_and_write_test(rut=self.dut.avalon_st_if.sink.status, has_sw_readable=True, has_sw_writable=False,
                                                                                          readable_fields=set(['valid','sop','eop','empty', ]),
                                                                                          writeable_fields=set([ ]) )
        

    def test_field(self) -> None:
        """
        Check the properties and function (read and write) on the fields both integer and enum
        """
        
        with self.subTest(msg='field: csr.avalon_st_if.source.data.word'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.data.word, lsb=0, msb=31, low=0, high=31, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.source.data.word[31:0]",
                                             rdl_desc="32-bit data value for the Avalon-ST source interface.",
                                             inst_name='word',
                                             parent_full_inst_name='csr.avalon_st_if.source.data')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.data.word, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.source.control.valid'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.control.valid, lsb=0, msb=0, low=0, high=0, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.source.control.valid",
                                             rdl_desc="Indicates that the Avalon-ST source interface has valid data to send. Once asserted by software, the field remains asserted until the transfer is accepted by the destination.",
                                             inst_name='valid',
                                             parent_full_inst_name='csr.avalon_st_if.source.control')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.control.valid, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.source.control.sop'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.control.sop, lsb=8, msb=8, low=8, high=8, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.source.control.sop",
                                             rdl_desc="Indicates the start of a frame on the Avalon-ST source interface.",
                                             inst_name='sop',
                                             parent_full_inst_name='csr.avalon_st_if.source.control')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.control.sop, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.source.control.eop'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.control.eop, lsb=16, msb=16, low=16, high=16, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.source.control.eop",
                                             rdl_desc="Indicates the end of a frame on the Avalon-ST source interface.",
                                             inst_name='eop',
                                             parent_full_inst_name='csr.avalon_st_if.source.control')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.control.eop, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.source.control.empty'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.control.empty, lsb=24, msb=25, low=24, high=25, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.source.control.empty[1:0]",
                                             rdl_desc="Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST source interface.",
                                             inst_name='empty',
                                             parent_full_inst_name='csr.avalon_st_if.source.control')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.control.empty, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.source.status.ready'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.source.status.ready, lsb=0, msb=0, low=0, high=0, is_volatile=True, default=0,
                                             rdl_name="avalon_st_if.source.status.ready",
                                             rdl_desc="Indicates that the destination Avalon-ST interface is ready to receive data.",
                                             inst_name='ready',
                                             parent_full_inst_name='csr.avalon_st_if.source.status')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.source.status.ready, is_sw_readable=True, is_sw_writable=False)
        with self.subTest(msg='field: csr.avalon_st_if.sink.data.word'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.data.word, lsb=0, msb=31, low=0, high=31, is_volatile=True, default=None,
                                             rdl_name="avalon_st_if.sink.data.word[31:0]",
                                             rdl_desc="32-bit data value for the Avalon-ST sink interface.",
                                             inst_name='word',
                                             parent_full_inst_name='csr.avalon_st_if.sink.data')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.data.word, is_sw_readable=True, is_sw_writable=False)
        with self.subTest(msg='field: csr.avalon_st_if.sink.control.ready'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.control.ready, lsb=0, msb=0, low=0, high=0, is_volatile=False, default=0,
                                             rdl_name="avalon_st_if.sink.control.ready",
                                             rdl_desc="Indicates that the Avalon-ST sink interface is ready to accept a data transfer. Once asserted by software, the field remains asserted until a transfer occurs.",
                                             inst_name='ready',
                                             parent_full_inst_name='csr.avalon_st_if.sink.control')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.control.ready, is_sw_readable=True, is_sw_writable=True)
        with self.subTest(msg='field: csr.avalon_st_if.sink.status.valid'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.status.valid, lsb=0, msb=0, low=0, high=0, is_volatile=True, default=None,
                                             rdl_name="avalon_st_if.sink.status.valid",
                                             rdl_desc="Indicates that the Avalon-ST sink interface has valid data to receive.",
                                             inst_name='valid',
                                             parent_full_inst_name='csr.avalon_st_if.sink.status')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.status.valid, is_sw_readable=True, is_sw_writable=False)
        with self.subTest(msg='field: csr.avalon_st_if.sink.status.sop'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.status.sop, lsb=8, msb=8, low=8, high=8, is_volatile=True, default=None,
                                             rdl_name="avalon_st_if.sink.status.sop",
                                             rdl_desc="Indicates the start of a frame on the Avalon-ST sink interface.",
                                             inst_name='sop',
                                             parent_full_inst_name='csr.avalon_st_if.sink.status')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.status.sop, is_sw_readable=True, is_sw_writable=False)
        with self.subTest(msg='field: csr.avalon_st_if.sink.status.eop'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.status.eop, lsb=16, msb=16, low=16, high=16, is_volatile=True, default=None,
                                             rdl_name="avalon_st_if.sink.status.eop",
                                             rdl_desc="Indicates the end of a frame on the Avalon-ST sink interface.",
                                             inst_name='eop',
                                             parent_full_inst_name='csr.avalon_st_if.sink.status')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.status.eop, is_sw_readable=True, is_sw_writable=False)
        with self.subTest(msg='field: csr.avalon_st_if.sink.status.empty'):
            self._single_field_property_test(fut=self.dut.avalon_st_if.sink.status.empty, lsb=24, msb=25, low=24, high=25, is_volatile=True, default=None,
                                             rdl_name="avalon_st_if.sink.status.empty[1:0]",
                                             rdl_desc="Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST sink interface.",
                                             inst_name='empty',
                                             parent_full_inst_name='csr.avalon_st_if.sink.status')
            self._single_int_field_read_and_write_test(fut=self.dut.avalon_st_if.sink.status.empty, is_sw_readable=True, is_sw_writable=False)

    def test_addrmap(self) -> None:
        """
        Check the properties on the addrmaps files
        """

        
        with self.subTest(msg='addrmap: top_node'):
            self._single_addrmap_property_test(dut=self.dut,
                                               size=28,
                                               rdl_name="CSR",
                                               rdl_desc="Control and status registers for ADASEC-SDN.",
                                               inst_name='csr',
                                               parent_full_inst_name=None)
            self._test_addrmap_iterators(dut=self.dut,
                                         writeable_registers=NodeIterators(),
                                         readable_registers=NodeIterators(),
                                         sections=NodeIterators('avalon_st_if',),
                                         memories=NodeIterators())
        


        # test all the address maps
        

    def test_regfile(self) -> None:
        """
        Check the properties on the register files
        """

        # test all the register files
        with self.subTest(msg='regfile: csr.avalon_st_if'):
            self._single_regfile_property_test(dut=self.dut.avalon_st_if,
                                               size=28,
                                               rdl_name="avalon_st_if",
                                               rdl_desc="Register file for the Avalon-ST source and sink interfaces.",
                                               inst_name='avalon_st_if',
                                               parent_full_inst_name='csr')
            self._test_regfile_iterators(dut=self.dut.avalon_st_if,
                                         writeable_registers=NodeIterators(),
                                         readable_registers=NodeIterators(),
                                         sections=NodeIterators('source','sink',))
        with self.subTest(msg='regfile: csr.avalon_st_if.source'):
            self._single_regfile_property_test(dut=self.dut.avalon_st_if.source,
                                               size=12,
                                               rdl_name="avalon_st_if.source",
                                               rdl_desc="Register file for the Avalon-ST source interface.",
                                               inst_name='source',
                                               parent_full_inst_name='csr.avalon_st_if')
            self._test_regfile_iterators(dut=self.dut.avalon_st_if.source,
                                         writeable_registers=NodeIterators('data','control',),
                                         readable_registers=NodeIterators('data','control','status',),
                                         sections=NodeIterators())
        with self.subTest(msg='regfile: csr.avalon_st_if.sink'):
            self._single_regfile_property_test(dut=self.dut.avalon_st_if.sink,
                                               size=12,
                                               rdl_name="avalon_st_if.sink",
                                               rdl_desc="Register file for the Avalon-ST sink interface.",
                                               inst_name='sink',
                                               parent_full_inst_name='csr.avalon_st_if')
            self._test_regfile_iterators(dut=self.dut.avalon_st_if.sink,
                                         writeable_registers=NodeIterators('control',),
                                         readable_registers=NodeIterators('data','control','status',),
                                         sections=NodeIterators())
        

    

    def test_array_slicing(self) -> None:
        """
        Check slicing into array
        """
        full_slice:NodeArray
        



class csr_block_access(csr_TestCase_BlockAccess): # type: ignore[valid-type,misc]
    """
    tests for all the block access methods
    """

    

    def test_register_array_context_manager(self) -> None:
        """
        Walk the register map and check that register map context managers work correctly
        """
        

class csr_alt_block_access(csr_TestCase_AltBlockAccess): # type: ignore[valid-type,misc]
    """
    tests for all the block access methods with the alternative callbacks, this is a simpler
    version of the tests above
    """
    

    def test_register_array_context_manager(self) -> None:
        """
        Walk the register map and check that register map context managers work correctly
        """
        


if __name__ == '__main__':

    unittest.main()