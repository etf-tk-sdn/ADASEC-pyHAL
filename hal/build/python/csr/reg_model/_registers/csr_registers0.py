

"""
Python Wrapper for the csr register model

This code was generated from the PeakRDL-python package version 3.1.2

"""










from typing import Iterator
from typing import Union
from typing import overload
from typing import Literal
from typing import Any
from typing import NoReturn
from typing import Type

from ...lib import Node, NodeArray, Base
from ...lib import UDPStruct

from ...lib import Memory
from ...lib import AddressMap
from ...lib import RegFile
from ...lib import MemoryReadOnly, MemoryWriteOnly, MemoryReadWrite
from ...lib import Reg, RegArray
from ...lib import RegReadOnly, RegWriteOnly, RegReadWrite
from ...lib import RegReadOnlyArray, RegWriteOnlyArray, RegReadWriteArray
from ...lib import ReadableMemory, WritableMemory
from ...lib import FieldReadOnly, FieldWriteOnly, FieldReadWrite, Field

from ...lib import FieldSizeProps, FieldMiscProps






from .fields import csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls
from .fields import csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls
from .fields import csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls
from .fields import csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls
from .fields import csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls
from .fields import csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls
from .fields import csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls
from .fields import csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls
from .fields import csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls
from .fields import csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls
from .fields import csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls
from .fields import csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls

# register definitions
    
    
class csr_avalon_st_if_source_data_0x3660f5397353c16d_cls(RegReadWrite):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.source.data                                           |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Data register for the Avalon-ST source interface.</p>           |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__word']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,MemoryReadWrite]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__word:csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls = csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=32,
                lsb=0, msb=31,
                low=0, high=31),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.word',
            inst_name='word',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def word(self) -> csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls:
        """
        Property to access word field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.data.word[31:0]                                |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>32-bit data value for the Avalon-ST source interface.</p>       |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__word

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'word':'word',
            }

    
    
    
    
    
    
                
    def get_child_by_system_rdl_name(self, name: Any) -> 'csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls':
        return super().get_child_by_system_rdl_name(name)
                
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.data"
    @property
    def rdl_desc(self) -> str:
        return "Data register for the Avalon-ST source interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.word
        
        
    

    
    
class csr_avalon_st_if_source_control_neg_0x6e7d3d01fcd4aeff_cls(RegReadWrite):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.source.control                                        |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Control register for the Avalon-ST source interface.</p>        |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__valid', '__sop', '__eop', '__empty']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,MemoryReadWrite]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__valid:csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls = csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=0, msb=0,
                low=0, high=0),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.valid',
            inst_name='valid',
            field_type=int)
        self.__sop:csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls = csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=8, msb=8,
                low=8, high=8),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.sop',
            inst_name='sop',
            field_type=int)
        self.__eop:csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls = csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=16, msb=16,
                low=16, high=16),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.eop',
            inst_name='eop',
            field_type=int)
        self.__empty:csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls = csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=2,
                lsb=24, msb=25,
                low=24, high=25),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.empty',
            inst_name='empty',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def valid(self) -> csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls:
        """
        Property to access valid field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.control.valid                                  |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates that the Avalon-ST source interface has valid data to |
        |              |      send. Once asserted by software, the field remains asserted until  |
        |              |      the transfer is accepted by the destination.</p>                   |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__valid
    @property
    def sop(self) -> csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls:
        """
        Property to access sop field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.control.sop                                    |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the start of a frame on the Avalon-ST source          |
        |              |      interface.</p>                                                     |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__sop
    @property
    def eop(self) -> csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls:
        """
        Property to access eop field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.control.eop                                    |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the end of a frame on the Avalon-ST source            |
        |              |      interface.</p>                                                     |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__eop
    @property
    def empty(self) -> csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls:
        """
        Property to access empty field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.control.empty[1:0]                             |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the number of empty bytes in the last word of the     |
        |              |      current frame on the Avalon-ST source interface.</p>               |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__empty

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'valid':'valid','sop':'sop','eop':'eop','empty':'empty',
            }

    
    
    
    
    
    
    # nodes:4
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["valid"]) -> 'csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["sop"]) -> 'csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["eop"]) -> 'csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["empty"]) -> 'csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls', 'csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls', 'csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls', 'csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.control"
    @property
    def rdl_desc(self) -> str:
        return "Control register for the Avalon-ST source interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.valid
        yield self.sop
        yield self.eop
        yield self.empty
        
        
    

    
    
class csr_avalon_st_if_source_status_0x2d383fb58e0f1cb1_cls(RegReadOnly):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.source.status                                         |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Status register for the Avalon-ST source interface.</p>         |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__ready']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,ReadableMemory]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__ready:csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls = csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=0, msb=0,
                low=0, high=0),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=True),
            logger_handle=logger_handle+'.ready',
            inst_name='ready',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def ready(self) -> csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls:
        """
        Property to access ready field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source.status.ready                                   |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates that the destination Avalon-ST interface is ready to  |
        |              |      receive data.</p>                                                  |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__ready

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'ready':'ready',
            }

    
    
    
    
    
    
                
    def get_child_by_system_rdl_name(self, name: Any) -> 'csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls':
        return super().get_child_by_system_rdl_name(name)
                
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.status"
    @property
    def rdl_desc(self) -> str:
        return "Status register for the Avalon-ST source interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.ready
        
        
    

    
    
class csr_avalon_st_if_sink_data_0x275ca516767c3381_cls(RegReadOnly):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.sink.data                                             |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Data register for the Avalon-ST sink interface.</p>             |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__word']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,ReadableMemory]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__word:csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls = csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=32,
                lsb=0, msb=31,
                low=0, high=31),
            misc_props=FieldMiscProps(
                default=None,
                is_volatile=True),
            logger_handle=logger_handle+'.word',
            inst_name='word',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def word(self) -> csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls:
        """
        Property to access word field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.data.word[31:0]                                  |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>32-bit data value for the Avalon-ST sink interface.</p>         |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__word

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'word':'word',
            }

    
    
    
    
    
    
                
    def get_child_by_system_rdl_name(self, name: Any) -> 'csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls':
        return super().get_child_by_system_rdl_name(name)
                
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.data"
    @property
    def rdl_desc(self) -> str:
        return "Data register for the Avalon-ST sink interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.word
        
        
    

    
    
class csr_avalon_st_if_sink_control_neg_0x308341273de07a1_cls(RegReadWrite):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.sink.control                                          |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Control register for the Avalon-ST sink interface.</p>          |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__ready']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,MemoryReadWrite]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__ready:csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls = csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=0, msb=0,
                low=0, high=0),
            misc_props=FieldMiscProps(
                default=0,
                is_volatile=False),
            logger_handle=logger_handle+'.ready',
            inst_name='ready',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def ready(self) -> csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls:
        """
        Property to access ready field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.control.ready                                    |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates that the Avalon-ST sink interface is ready to accept  |
        |              |      a data transfer. Once asserted by software, the field remains      |
        |              |      asserted until a transfer occurs.</p>                              |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__ready

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'ready':'ready',
            }

    
    
    
    
    
    
                
    def get_child_by_system_rdl_name(self, name: Any) -> 'csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls':
        return super().get_child_by_system_rdl_name(name)
                
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.control"
    @property
    def rdl_desc(self) -> str:
        return "Control register for the Avalon-ST sink interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.ready
        
        
    

    
    
class csr_avalon_st_if_sink_status_0x650eaf5a7ac3db5_cls(RegReadOnly):
    """
    Class to represent a register in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.sink.status                                           |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Status register for the Avalon-ST sink interface.</p>           |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__valid', '__sop', '__eop', '__empty']

    def __init__(self,
                 address: int,
                 logger_handle: str,
                 inst_name: str,
                 parent: Union[AddressMap,RegFile,ReadableMemory]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # build the field attributes
        
        self.__valid:csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls = csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=0, msb=0,
                low=0, high=0),
            misc_props=FieldMiscProps(
                default=None,
                is_volatile=True),
            logger_handle=logger_handle+'.valid',
            inst_name='valid',
            field_type=int)
        self.__sop:csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls = csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=8, msb=8,
                low=8, high=8),
            misc_props=FieldMiscProps(
                default=None,
                is_volatile=True),
            logger_handle=logger_handle+'.sop',
            inst_name='sop',
            field_type=int)
        self.__eop:csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls = csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=1,
                lsb=16, msb=16,
                low=16, high=16),
            misc_props=FieldMiscProps(
                default=None,
                is_volatile=True),
            logger_handle=logger_handle+'.eop',
            inst_name='eop',
            field_type=int)
        self.__empty:csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls = csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls(
            parent_register=self,
            size_props=FieldSizeProps(
                width=2,
                lsb=24, msb=25,
                low=24, high=25),
            misc_props=FieldMiscProps(
                default=None,
                is_volatile=True),
            logger_handle=logger_handle+'.empty',
            inst_name='empty',
            field_type=int)

    @property
    def width(self) -> int:
        return 32

    @property
    def accesswidth(self) -> int:
        return 32

    

    # build the properties for the fields
    
    @property
    def valid(self) -> csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls:
        """
        Property to access valid field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.status.valid                                     |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates that the Avalon-ST sink interface has valid data to   |
        |              |      receive.</p>                                                       |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__valid
    @property
    def sop(self) -> csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls:
        """
        Property to access sop field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.status.sop                                       |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the start of a frame on the Avalon-ST sink            |
        |              |      interface.</p>                                                     |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__sop
    @property
    def eop(self) -> csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls:
        """
        Property to access eop field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.status.eop                                       |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the end of a frame on the Avalon-ST sink              |
        |              |      interface.</p>                                                     |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__eop
    @property
    def empty(self) -> csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls:
        """
        Property to access empty field of the register

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink.status.empty[1:0]                                |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Indicates the number of empty bytes in the last word of the     |
        |              |      current frame on the Avalon-ST sink interface.</p>                 |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__empty

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'valid':'valid','sop':'sop','eop':'eop','empty':'empty',
            }

    
    
    
    
    
    
    # nodes:4
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["valid"]) -> 'csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["sop"]) -> 'csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["eop"]) -> 'csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["empty"]) -> 'csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls', 'csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls', 'csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls', 'csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.status"
    @property
    def rdl_desc(self) -> str:
        return "Status register for the Avalon-ST sink interface."
    
    

    
    def __iter__(self) -> Iterator[Union[FieldReadOnly,FieldWriteOnly,FieldReadWrite]]:
        
        
        yield self.valid
        yield self.sop
        yield self.eop
        yield self.empty
        
        
    


if __name__ == '__main__':
    pass