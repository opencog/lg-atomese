#SET_DIRECTORY_PROPERTIES(PROPERTIES CLEAN_NO_CUSTOM true)
OPENCOG_ADD_ATOM_TYPES(
	atom_types.script
	atom_types.h
	atom_types.definitions
	atom_types.inheritance
	lg_types.scm
	lg_types.pyx
)
ADD_CUSTOM_TARGET(lg_atom_types DEPENDS atom_types.h)

# The atom_types.h file is written to the build directory
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})

ADD_LIBRARY (lg-types SHARED
	atom_types.h
	LGTypes.cc
)

TARGET_LINK_LIBRARIES(lg-types
	${ATOMSPACE_atomtypes_LIBRARY}
)

# Without this, parallel make will race and crap up the generated files.
ADD_DEPENDENCIES(lg-types lg_atom_types)

INSTALL (TARGETS lg-types
	EXPORT LGAtomeseTargets
	LIBRARY DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

# Create a symlink so the library can also be found as libnlp-types.so
# This is needed temporarily, for backward compatibility with link-grammar
# which currently expects libnlp-types.so in it's configure.ac
INSTALL(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink \
	liblg-types.so \
	\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/lib${LIB_DIR_SUFFIX}/opencog/libnlp-types.so)")

INSTALL (FILES
	${CMAKE_CURRENT_BINARY_DIR}/atom_types.h
	DESTINATION "include/opencog/lg/types"
)

ADD_GUILE_MODULE (FILES
	${CMAKE_CURRENT_BINARY_DIR}/lg_types.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/lg/types"
	DEPENDS lg_atom_types
)

ADD_GUILE_EXTENSION(SCM_CONFIG lg-types "opencog-ext-path-lg-types")
