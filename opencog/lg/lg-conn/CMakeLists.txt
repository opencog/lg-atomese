
INCLUDE_DIRECTORIES (
	${CMAKE_BINARY_DIR}           # for the LG atom types
)

ADD_LIBRARY (lg-conn SHARED
	LGConnExpand.cc
)

ADD_DEPENDENCIES (lg-conn lg_atom_types)

TARGET_LINK_LIBRARIES (lg-conn
	lg-types
	${ATOMSPACE_smob_LIBRARY}
	${ATOMSPACE_LIBRARIES}
)

INSTALL (TARGETS lg-conn
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

INSTALL (FILES
	LGConnExpand.h
	DESTINATION "include/opencog/lg/lg-conn"
)
