from opencog.atomspace import get_refreshed_types
from opencog.utilities import add_node, add_link

cdef extern :
    void lg_types_init()

lg_types_init()
types = get_refreshed_types()

include "opencog/lg/types/lg_types.pyx"
