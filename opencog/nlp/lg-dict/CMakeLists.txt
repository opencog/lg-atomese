
INCLUDE_DIRECTORIES (
	${LINK_GRAMMAR_INCLUDE_DIRS}	# for LinkGrammar dictionary
	${CMAKE_BINARY_DIR}           # for the NLP atom types
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

ADD_DEPENDENCIES (lg-dict-entry nlp_atom_types)

TARGET_LINK_LIBRARIES (lg-dict-entry
	nlp-types
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

ADD_GUILE_MODULE (FILES
	lg-dict.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/nlp/lg-dict"
)

ADD_GUILE_EXTENSION(SCM_CONFIG lg-dict "opencog-ext-path-lg-dict")

INSTALL (FILES
	LGDictEntry.h
	LGDictNode.h
	LGDictUtils.h
	DESTINATION "include/${PROJECT_NAME}/nlp/lg-dict"
)
