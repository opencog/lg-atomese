
# Need to use -fno-strict-aliasing when compiling cython code, in order
# to avoid nasty compiler warnings about aliasing.  Cython explicitly
# performs aliasing, in order to emulate python object inheritance.
# See, for example,
# https://groups.google.com/forum/#!topic/cython-users/JV1-KvIUeIg
#
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing")

INCLUDE_DIRECTORIES(
	${ATOMSPACE_INCLUDE_DIR}
	${Python3_INCLUDE_DIRS}
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_BINARY_DIR}
)

SET(CYTHON_FLAGS "-3" "-f" "-Wextra" # "-Werror"
	"-I" "${ATOMSPACE_INCLUDE_DIR}/opencog/cython"
	"-I" "${ATOMSPACE_INCLUDE_DIR}/opencog/cython/opencog")

# Use this as a guide:
# https://github.com/OpenKinect/libfreenect/blob/master/wrappers/python/CMakeLists.txt

##################### LG Types ##################

CYTHON_ADD_MODULE_PYX(lg_types
	"lg_types.pyx"
)

list(APPEND ADDITIONAL_MAKE_CLEAN_FILES "lg_types.cpp")

# opencog.lg_types Python bindings
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})

ADD_LIBRARY(lg_types_cython SHARED
	lg_types.cpp
)

ADD_DEPENDENCIES(lg_types_cython lg-types)

TARGET_LINK_LIBRARIES(lg_types_cython
	lg-types
	${ATOMSPACE_LIBRARIES}
	${Python3_LIBRARIES}
)

SET_TARGET_PROPERTIES(lg_types_cython PROPERTIES
	PREFIX ""
	OUTPUT_NAME lg_types)

INSTALL (TARGETS lg_types_cython
	DESTINATION "${PYTHON_DEST}")
