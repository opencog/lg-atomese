
include(CMakePackageConfigHelpers)

#export(EXPORT LGAtomeseTargets
#	FILE "${CMAKE_CURRENT_BINARY_DIR}/LGAtomese/LGAtomeseTargets.cmake"
#)

set(ConfigPackageLocation lib/cmake/LGAtomese)

install(EXPORT LGAtomeseTargets
	FILE LGAtomeseTargets.cmake
	DESTINATION ${ConfigPackageLocation}
)

configure_package_config_file(LGAtomeseConfig.cmake.in
	${CMAKE_CURRENT_BINARY_DIR}/LGAtomeseConfig.cmake
	INSTALL_DESTINATION ${ConfigPackageLocation}
	PATH_VARS CMAKE_INSTALL_PREFIX
)

write_basic_package_version_file(
	"${CMAKE_CURRENT_BINARY_DIR}/LGAtomeseConfigVersion.cmake"
	VERSION ${PROJECT_VERSION}
	COMPATIBILITY SameMajorVersion
)

INSTALL(FILES
	${CMAKE_CURRENT_BINARY_DIR}/LGAtomeseConfigVersion.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LGAtomeseConfig.cmake
	DESTINATION ${ConfigPackageLocation}
)
