#SET_DIRECTORY_PROPERTIES(PROPERTIES CLEAN_NO_CUSTOM true)
OPENCOG_ADD_ATOM_TYPES(
	atom_types.script
	atom_types.h
	atom_types.definitions
	atom_types.inheritance
	nlp_types.scm
	nlp_types.pyx
)
ADD_CUSTOM_TARGET(nlp_atom_types DEPENDS atom_types.h)

# The atom_types.h file is written to the build directory
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})

ADD_LIBRARY (nlp-types SHARED
	atom_types.h
	NLPTypes.cc
)

TARGET_LINK_LIBRARIES(nlp-types
	${ATOMSPACE_atomtypes_LIBRARY}
)

# Without this, parallel make will race and crap up the generated files.
ADD_DEPENDENCIES(nlp-types nlp_atom_types)

INSTALL (TARGETS nlp-types
	EXPORT LGAtomeseTargets
	LIBRARY DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

INSTALL (FILES
	${CMAKE_CURRENT_BINARY_DIR}/atom_types.h
	DESTINATION "include/${PROJECT_NAME}/nlp/types"
)

ADD_GUILE_MODULE (FILES
	${CMAKE_CURRENT_BINARY_DIR}/nlp_types.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/nlp/types"
	DEPENDS nlp_atom_types
)

ADD_GUILE_EXTENSION(SCM_CONFIG nlp-types "opencog-ext-path-nlp-types")
