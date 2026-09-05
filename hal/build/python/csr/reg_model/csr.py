


"""
Python Wrapper for the csr register model

This code was generated from the PeakRDL-python package version 3.1.2

"""












from typing import Iterator
from typing import Optional
from typing import Union
from typing import Type
from typing import overload
from typing import Literal
from typing import Any
from typing import NoReturn
import warnings



from ..lib import Node, NodeArray, Base
from ..lib import UDPStruct

from ..lib  import AddressMapArray, RegFileArray
from ..lib import Memory, MemoryArray
from ..lib import AddressMap
from ..lib import RegFile
from ..lib  import AddressMapArray
from ..lib  import RegFileArray
from ..lib import MemoryReadOnly, MemoryWriteOnly, MemoryReadWrite
from ..lib import MemoryReadOnlyArray, MemoryWriteOnlyArray, MemoryReadWriteArray
from ..lib import Reg, RegArray
from ..lib import RegReadOnly, RegWriteOnly, RegReadWrite
from ..lib import RegReadOnlyArray, RegWriteOnlyArray, RegReadWriteArray
from ..lib import FieldReadOnly, FieldWriteOnly, FieldReadWrite, Field

from ..lib import ReadableRegister, WritableRegister
from ..lib import ReadableMemory, WritableMemory
from ..lib import ReadableRegisterArray, WriteableRegisterArray



from ..lib import NormalCallbackSet, NormalCallbackSetLegacy





from ._registers import csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls
from ._registers import csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls
from ._registers import csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls
from ._registers import csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls
from ._registers import csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls
from ._registers import csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls
from ._registers import csr_test_input_0x39e1a6f11c300fe7_cls
from ._registers import csr_test_output_neg_0x34731a59caa5f5e_cls


# addrmap, regfile, memor and register definitions
    
    
class csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls(RegFile):
    """
    Class to represent a register file in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.sink                                                  |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Register file for the Avalon-ST sink interface.</p>             |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__data', '__control', '__status']

    def __init__(self,
                 address: int,
                 logger_handle:str,
                 inst_name:str,
                 parent:Union[AddressMap,RegFile]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # instance of objects within the class
        
            
        self.__data:csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls = csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls(
                                                                     address=self.address+0,
                                                                     logger_handle=logger_handle+'.data',
                                                                     inst_name='data', parent=self)
        
            
        self.__control:csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls = csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls(
                                                                     address=self.address+4,
                                                                     logger_handle=logger_handle+'.control',
                                                                     inst_name='control', parent=self)
        
            
        self.__status:csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls = csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls(
                                                                     address=self.address+8,
                                                                     logger_handle=logger_handle+'.status',
                                                                     inst_name='status', parent=self)
        

    @property
    def size(self) -> int:
        return 12

    # properties for Register and RegisterFiles
    @property
    def data(self) -> 'csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls':
        """
        Property to access data 

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
        return self.__data
    
    @property
    def control(self) -> 'csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls':
        """
        Property to access control 

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
        return self.__control
    
    @property
    def status(self) -> 'csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls':
        """
        Property to access status 

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
        return self.__status
    

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'data':'data','control':'control','status':'status',
            }

    
    
    
    
    
    
    # nodes:3
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["data"]) -> 'csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["control"]) -> 'csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["status"]) -> 'csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_sink_data_neg_0xb8439acc7179d95_cls', 'csr_avalon_st_if_sink_control_neg_0x4115412b542aff6e_cls', 'csr_avalon_st_if_sink_status_neg_0x3a04078d8a65b080_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink"
    @property
    def rdl_desc(self) -> str:
        return "Register file for the Avalon-ST sink interface."
    
    

    
    def __iter__(self) -> Iterator[Union[Node, NodeArray]]:
        
        
        yield self.data
        yield self.control
        yield self.status
        
        
    

    
    
class csr_avalon_st_if_source_0x2fbdb55987056386_cls(RegFile):
    """
    Class to represent a register file in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if.source                                                |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Register file for the Avalon-ST source interface.</p>           |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__data', '__control', '__status']

    def __init__(self,
                 address: int,
                 logger_handle:str,
                 inst_name:str,
                 parent:Union[AddressMap,RegFile]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # instance of objects within the class
        
            
        self.__data:csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls = csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls(
                                                                     address=self.address+0,
                                                                     logger_handle=logger_handle+'.data',
                                                                     inst_name='data', parent=self)
        
            
        self.__control:csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls = csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls(
                                                                     address=self.address+4,
                                                                     logger_handle=logger_handle+'.control',
                                                                     inst_name='control', parent=self)
        
            
        self.__status:csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls = csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls(
                                                                     address=self.address+8,
                                                                     logger_handle=logger_handle+'.status',
                                                                     inst_name='status', parent=self)
        

    @property
    def size(self) -> int:
        return 12

    # properties for Register and RegisterFiles
    @property
    def data(self) -> 'csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls':
        """
        Property to access data 

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
        return self.__data
    
    @property
    def control(self) -> 'csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls':
        """
        Property to access control 

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
        return self.__control
    
    @property
    def status(self) -> 'csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls':
        """
        Property to access status 

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
        return self.__status
    

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'data':'data','control':'control','status':'status',
            }

    
    
    
    
    
    
    # nodes:3
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["data"]) -> 'csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["control"]) -> 'csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["status"]) -> 'csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_source_data_neg_0x6d3a98415923896a_cls', 'csr_avalon_st_if_source_control_0x65accd498ad5f34d_cls', 'csr_avalon_st_if_source_status_0x1e7df78c8ecf08a7_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source"
    @property
    def rdl_desc(self) -> str:
        return "Register file for the Avalon-ST source interface."
    
    

    
    def __iter__(self) -> Iterator[Union[Node, NodeArray]]:
        
        
        yield self.data
        yield self.control
        yield self.status
        
        
    

    
    
class csr_avalon_st_if_0x146190104d980fe7_cls(RegFile):
    """
    Class to represent a register file in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      avalon_st_if                                                       |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Register file for the Avalon-ST source and sink interfaces.</p> |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__source', '__sink']

    def __init__(self,
                 address: int,
                 logger_handle:str,
                 inst_name:str,
                 parent:Union[AddressMap,RegFile]):

        super().__init__(address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        # instance of objects within the class
        self.__source:csr_avalon_st_if_source_0x2fbdb55987056386_cls = csr_avalon_st_if_source_0x2fbdb55987056386_cls(
                                                                                address=self.address+0,
                                                                                logger_handle=logger_handle+'.source',
                                                                                inst_name='source',
                                                                                parent=self)
        self.__sink:csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls = csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls(
                                                                                address=self.address+16,
                                                                                logger_handle=logger_handle+'.sink',
                                                                                inst_name='sink',
                                                                                parent=self)
        

    @property
    def size(self) -> int:
        return 28

    # properties for Register and RegisterFiles
    @property
    def source(self) -> 'csr_avalon_st_if_source_0x2fbdb55987056386_cls':
        """
        Property to access source 

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.source                                                |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Register file for the Avalon-ST source interface.</p>           |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__source
    
    @property
    def sink(self) -> 'csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls':
        """
        Property to access sink 

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if.sink                                                  |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Register file for the Avalon-ST sink interface.</p>             |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__sink
    

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'source':'source','sink':'sink',
            }

    
    
    
    
    
    
    # nodes:2
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["source"]) -> 'csr_avalon_st_if_source_0x2fbdb55987056386_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["sink"]) -> 'csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_source_0x2fbdb55987056386_cls', 'csr_avalon_st_if_sink_neg_0x41d0d564d4f8fc85_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if"
    @property
    def rdl_desc(self) -> str:
        return "Register file for the Avalon-ST source and sink interfaces."
    
    

    
    def __iter__(self) -> Iterator[Union[Node, NodeArray]]:
        
        
        yield self.source
        yield self.sink
        
        
    

    
    
class csr_neg_0x5b9c0098762e9493_cls(AddressMap):
    """
    Class to represent a address map in the register model

    +--------------+-------------------------------------------------------------------------+
    | SystemRDL    | Value                                                                   |
    | Field        |                                                                         |
    +==============+=========================================================================+
    | Name         | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      CSR                                                                |
    +--------------+-------------------------------------------------------------------------+
    | Description  | .. raw:: html                                                           |
    |              |                                                                         |
    |              |      <p>Control and status registers for ADASEC-SDN.</p>                |
    +--------------+-------------------------------------------------------------------------+
    """

    __slots__ : list[str] = ['__avalon_st_if', '__test_input', '__test_output']

    def __init__(self, *,
                 address:int=0,
                 logger_handle:str='reg_model.csr',
                 inst_name:str='csr',
                 callbacks: Optional[Union[NormalCallbackSet, NormalCallbackSetLegacy]]=None,
                 parent:Optional[AddressMap]=None):

        if callbacks is not None:
            if not isinstance(callbacks, (NormalCallbackSet, NormalCallbackSetLegacy)):
                raise TypeError(f'callbacks should be NormalCallbackSet, NormalCallbackSetLegacy got {type(callbacks)}')

        super().__init__(callbacks=callbacks,
                         address=address,
                         logger_handle=logger_handle,
                         inst_name=inst_name,
                         parent=parent)

        self.__avalon_st_if:csr_avalon_st_if_0x146190104d980fe7_cls = csr_avalon_st_if_0x146190104d980fe7_cls(
                                                                                address=self.address+0,
                                                                                logger_handle=logger_handle+'.avalon_st_if',
                                                                                inst_name='avalon_st_if',
                                                                                parent=self)
        
            
        self.__test_input:csr_test_input_0x39e1a6f11c300fe7_cls = csr_test_input_0x39e1a6f11c300fe7_cls(
                                                                     address=self.address+28,
                                                                     logger_handle=logger_handle+'.test_input',
                                                                     inst_name='test_input', parent=self)
        
            
        self.__test_output:csr_test_output_neg_0x34731a59caa5f5e_cls = csr_test_output_neg_0x34731a59caa5f5e_cls(
                                                                     address=self.address+32,
                                                                     logger_handle=logger_handle+'.test_output',
                                                                     inst_name='test_output', parent=self)
        

    @property
    def size(self) -> int:
        return 36
    @property
    def avalon_st_if(self) -> 'csr_avalon_st_if_0x146190104d980fe7_cls':
        """
        Property to access avalon_st_if 

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      avalon_st_if                                                       |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Register file for the Avalon-ST source and sink interfaces.</p> |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__avalon_st_if
        
    @property
    def test_input(self) -> 'csr_test_input_0x39e1a6f11c300fe7_cls':
        """
        Property to access test_input 

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      test_input                                                         |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Test input register for ADASEC-SDN.</p>                         |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__test_input
        
    @property
    def test_output(self) -> 'csr_test_output_neg_0x34731a59caa5f5e_cls':
        """
        Property to access test_output 

        +--------------+-------------------------------------------------------------------------+
        | SystemRDL    | Value                                                                   |
        | Field        |                                                                         |
        +==============+=========================================================================+
        | Name         | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      test_output                                                        |
        +--------------+-------------------------------------------------------------------------+
        | Description  | .. raw:: html                                                           |
        |              |                                                                         |
        |              |      <p>Test output register for ADASEC-SDN.</p>                        |
        +--------------+-------------------------------------------------------------------------+
        """
        return self.__test_output
        

    
    @property
    def systemrdl_python_child_name_map(self) -> dict[str, str]:
        return {'avalon_st_if':'avalon_st_if','test_input':'test_input','test_output':'test_output',
            }

    
    
    
    
    
    
    # nodes:3
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["avalon_st_if"]) -> 'csr_avalon_st_if_0x146190104d980fe7_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["test_input"]) -> 'csr_test_input_0x39e1a6f11c300fe7_cls': ...
                
                
    @overload
    def get_child_by_system_rdl_name(self, name: Literal["test_output"]) -> 'csr_test_output_neg_0x34731a59caa5f5e_cls': ...
                

    @overload
    def get_child_by_system_rdl_name(self, name: str) -> Union['csr_avalon_st_if_0x146190104d980fe7_cls', 'csr_test_input_0x39e1a6f11c300fe7_cls', 'csr_test_output_neg_0x34731a59caa5f5e_cls', ]: ...

    def get_child_by_system_rdl_name(self, name: Any) -> Any:
        return super().get_child_by_system_rdl_name(name)
    


    

    
    

    @property
    def rdl_name(self) -> str:
        return "CSR"
    @property
    def rdl_desc(self) -> str:
        return "Control and status registers for ADASEC-SDN."
    
    

    
    def __iter__(self) -> Iterator[Union[Node, NodeArray]]:
        
        
        yield self.avalon_st_if
        yield self.test_input
        yield self.test_output
        
        
    


csr_cls = csr_neg_0x5b9c0098762e9493_cls

if __name__ == '__main__':
    # dummy functions to demonstrate the class
    def read_addr_space(addr: int, width: int, accesswidth: int) -> int:
        """
        Callback to simulate the operation of the package, everytime the read is called, it will
        request the user input the value to be read back.

        Args:
            addr: Address to write to
            width: Width of the register in bits
            accesswidth: Minimum access width of the register in bits

        Returns:
            value inputted by the used
        """
        assert isinstance(addr, int)
        assert isinstance(width, int)
        assert isinstance(accesswidth, int)
        return int(input('value to read from address:0x%X'%addr))

    def write_addr_space(addr: int, width: int, accesswidth: int, data: int) -> None:
        """
        Callback to simulate the operation of the package, everytime the read is called, it will
        request the user input the value to be read back.

        Args:
            addr: Address to write to
            width: Width of the register in bits
            accesswidth: Minimum access width of the register in bits
            data: value to be written to the register

        Returns:
            None
        """
        assert isinstance(addr, int)
        assert isinstance(width, int)
        assert isinstance(accesswidth, int)
        assert isinstance(data, int)
        print('write data:0x%X to address:0x%X'%(data, addr))

    # create an instance of the class
    csr = csr_cls(callbacks = NormalCallbackSet(read_callback=read_addr_space,
                                                                                                     write_callback=write_addr_space))