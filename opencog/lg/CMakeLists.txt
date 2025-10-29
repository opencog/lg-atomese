
# Build C++ code in assorted LG subdirectories

ADD_SUBDIRECTORY (types)

ADD_SUBDIRECTORY (lg-conn)
ADD_SUBDIRECTORY (lg-dict)
IF (HAVE_UUID)
	ADD_SUBDIRECTORY (lg-parse)
ENDIF (HAVE_UUID)

IF (HAVE_CYTHON)
	ADD_SUBDIRECTORY (cython)
ENDIF (HAVE_CYTHON)
ADD_SUBDIRECTORY (scm)

# Create a symlink from include/opencog/nlp to include/opencog/lg
# This is only needed for link-grammar versions 5.0 through 5.12
# Link-grammar 5.13+ will use include/opencog/lg directly
IF (LG_VERSION_MAJOR EQUAL 5 AND LG_VERSION_MINOR LESS 13)
	INSTALL(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink \
		lg \
		\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/include/opencog/nlp)")
ENDIF ()
