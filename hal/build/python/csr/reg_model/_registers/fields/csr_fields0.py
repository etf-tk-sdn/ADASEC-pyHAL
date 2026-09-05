

"""
Python Wrapper for the csr register model

This code was generated from the PeakRDL-python package version 3.1.2

"""









from ....lib import UDPStruct
from ....lib import FieldReadOnly, FieldWriteOnly, FieldReadWrite, Field


# field definitions
    
    
class csr_avalon_st_if_source_data_word_neg_0x55074116f9209c24_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.data.word[31:0]"
    @property
    def rdl_desc(self) -> str:
        return "32-bit data value for the Avalon-ST source interface."
    
    
    

    
    
class csr_avalon_st_if_source_control_valid_0x593791e23ae3d4b3_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.control.valid"
    @property
    def rdl_desc(self) -> str:
        return "Indicates that the Avalon-ST source interface has valid data to send. Once asserted by software, the field remains asserted until the transfer is accepted by the destination."
    
    
    

    
    
class csr_avalon_st_if_source_control_sop_0x570ed007765679b0_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.control.sop"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the start of a frame on the Avalon-ST source interface."
    
    
    

    
    
class csr_avalon_st_if_source_control_eop_neg_0x78f9c145ae8fe48e_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.control.eop"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the end of a frame on the Avalon-ST source interface."
    
    
    

    
    
class csr_avalon_st_if_source_control_empty_neg_0x582af1ddd8bfcbc6_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.control.empty[1:0]"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST source interface."
    
    
    

    
    
class csr_avalon_st_if_source_status_ready_0x548f35ffaedff6e0_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.source.status.ready"
    @property
    def rdl_desc(self) -> str:
        return "Indicates that the destination Avalon-ST interface is ready to receive data."
    
    
    

    
    
class csr_avalon_st_if_sink_data_word_0xfceb3744e631d53_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.data.word[31:0]"
    @property
    def rdl_desc(self) -> str:
        return "32-bit data value for the Avalon-ST sink interface."
    
    
    

    
    
class csr_avalon_st_if_sink_control_ready_neg_0x32324d59367c0f61_cls(FieldReadWrite):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.control.ready"
    @property
    def rdl_desc(self) -> str:
        return "Indicates that the Avalon-ST sink interface is ready to accept a data transfer. Once asserted by software, the field remains asserted until a transfer occurs."
    
    
    

    
    
class csr_avalon_st_if_sink_status_valid_0x5356746a877d69f2_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.status.valid"
    @property
    def rdl_desc(self) -> str:
        return "Indicates that the Avalon-ST sink interface has valid data to receive."
    
    
    

    
    
class csr_avalon_st_if_sink_status_sop_0x1b8927812cfb0bda_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.status.sop"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the start of a frame on the Avalon-ST sink interface."
    
    
    

    
    
class csr_avalon_st_if_sink_status_eop_neg_0x6bcbbed0cc3e1ba5_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.status.eop"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the end of a frame on the Avalon-ST sink interface."
    
    
    

    
    
class csr_avalon_st_if_sink_status_empty_0x147033c0cdbbba49_cls(FieldReadOnly):
    """
    Class to represent a register field in the register model

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
    __slots__ : list[str] = []

    

    
    

    @property
    def rdl_name(self) -> str:
        return "avalon_st_if.sink.status.empty[1:0]"
    @property
    def rdl_desc(self) -> str:
        return "Indicates the number of empty bytes in the last word of the current frame on the Avalon-ST sink interface."
    
    
    


if __name__ == '__main__':
    pass