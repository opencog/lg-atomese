
INCLUDE_DIRECTORIES (
	${CMAKE_BINARY_DIR}           # for the NLP atom types
)

ADD_LIBRARY (lg-conn SHARED
	LGConnExpand.cc
	LGConnSCM.cc
)

ADD_DEPENDENCIES (lg-conn nlp_atom_types)

TARGET_LINK_LIBRARIES (lg-conn
	nlp-types
	${ATOMSPACE_smob_LIBRARY}
	${ATOMSPACE_LIBRARIES}
)

INSTALL (TARGETS lg-conn
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

ADD_GUILE_MODULE (FILES
	lg-conn.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/nlp/lg-conn"
)

ADD_GUILE_EXTENSION(SCM_CONFIG lg-conn "opencog-ext-path-lg-conn")

INSTALL (FILES
	LGConnExpand.h
	DESTINATION "include/opencog/nlp/lg-conn"
)
