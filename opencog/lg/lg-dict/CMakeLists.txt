
INCLUDE_DIRECTORIES (
	${LINK_GRAMMAR_INCLUDE_DIRS}	# for LinkGrammar dictionary
	${CMAKE_BINARY_DIR}           # for the LG atom types
)

ADD_LIBRARY (lg-dict-entry SHARED
	LGDictExpContainer.cc
	LGDictReader.cc
	LGDictUtils.cc
	LGDictNode.cc
	LGDictEntry.cc
)

ADD_LIBRARY (lg-dict SHARED
	LGDictSCM.cc
)

ADD_DEPENDENCIES (lg-dict-entry lg_atom_types)

TARGET_LINK_LIBRARIES (lg-dict-entry
	lg-types
	${ATOMSPACE_smob_LIBRARY}
	${LINK_GRAMMAR_LIBRARY}
)

TARGET_LINK_LIBRARIES (lg-dict
	lg-dict-entry
	${ATOMSPACE_smob_LIBRARY}
)

INSTALL (TARGETS lg-dict-entry
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)
INSTALL (TARGETS lg-dict
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

INSTALL (FILES
	LGDictEntry.h
	LGDictNode.h
	LGDictUtils.h
	DESTINATION "include/opencog/lg/lg-dict"
)
