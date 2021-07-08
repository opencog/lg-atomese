
# Build C++ code in assorted NLP subdirectories

ADD_SUBDIRECTORY (types)

ADD_SUBDIRECTORY (lg-dict)
ADD_SUBDIRECTORY (lg-parse)

IF (HAVE_CYTHON)
	ADD_SUBDIRECTORY (cython)
ENDIF (HAVE_CYTHON)
ADD_SUBDIRECTORY (scm)
