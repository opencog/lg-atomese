
INCLUDE_DIRECTORIES (
	${LINK_GRAMMAR_INCLUDE_DIRS}	# for LinkGrammar dictionary
	${UUID_INCLUDE_DIRS}
	${CMAKE_BINARY_DIR}           # for the LG atom types
)

ADD_LIBRARY (lg-parse SHARED
	LGParseLink.cc
)

ADD_DEPENDENCIES (lg-parse lg_atom_types)

TARGET_LINK_LIBRARIES (lg-parse
	lg-dict-entry
	lg-types
	${ATOMSPACE_STORAGE_LIBRARIES}
	${ATOMSPACE_LIBRARIES}
	${LINK_GRAMMAR_LIBRARY}
	${UUID_LIBRARIES}
)

INSTALL (TARGETS lg-parse
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

INSTALL (FILES
	LGParseLink.h
	DESTINATION "include/opencog/lg/lg-parse"
)
