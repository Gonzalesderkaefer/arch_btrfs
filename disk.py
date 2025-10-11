# Partition
import part


#! Drive that is installed in 
class BlkDev:
    name: str
    removable: bool
    size: float
    read_only: bool
    type: str
    children: list[part.Part]

    def __init__(self, name, rm, size, ro, type, parts):
        self.name = name
        self.removable = rm
        self.size = size
        self.read_only = ro
        self.type = type
        self.children = parts



