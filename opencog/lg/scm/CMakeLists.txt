# Build unified lg library that links to all subsystems
ADD_LIBRARY (lg SHARED
	lg-init.cc
)

TARGET_LINK_LIBRARIES (lg
	${NO_AS_NEEDED}
	lg-types
	lg-conn
	lg-dict
	lg-parse
	${ATOMSPACE_LIBRARIES}
)

INSTALL (TARGETS lg
	EXPORT LGAtomeseTargets
	DESTINATION "lib${LIB_DIR_SUFFIX}/opencog"
)

ADD_GUILE_EXTENSION(SCM_CONFIG lg "opencog-ext-path-lg")

ADD_GUILE_MODULE (FILES
	lg.scm
	MODULE_DESTINATION "${GUILE_SITE_DIR}/opencog/lg"
)
