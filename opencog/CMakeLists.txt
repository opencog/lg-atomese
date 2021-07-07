
# The atom_types.h file is written to the build directory
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})

DECLARE_GUILE_CONFIG_TARGET(SCM_CONFIG "opencog lg-config" "OPENCOG_TEST")

ADD_SUBDIRECTORY (nlp)

WRITE_GUILE_CONFIG(${GUILE_BIN_DIR}/opencog/lg-config.scm SCM_CONFIG TRUE)

WRITE_GUILE_CONFIG(${GUILE_BIN_DIR}/opencog/lg-config-installable.scm SCM_CONFIG FALSE)
INSTALL(FILES ${GUILE_BIN_DIR}/opencog/lg-config-installable.scm DESTINATION ${GUILE_SITE_DIR}/opencog RENAME lg-config.scm)
