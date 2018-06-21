cmake_minimum_required(VERSION 2.8.12)
project(SuctionCup)

set(HEADER_FILES
"component/mapping/VolumeMapping.h"
"component/constraint/SuctionConstraint.h"
"component/collision/SuctionContact.h"
"component/engine/CavityVolumeEngine.h"
"component/forcefield/AtmosphericPressureForceField.h"
"component/forcefield/CavityPressureForceField.h"
"initSuctionCup.h"
)

set(SOURCE_FILES
"component/mapping/VolumeMapping.cpp"
"component/constraint/SuctionConstraint.cpp"
"component/collision/SuctionContact.cpp"
"component/engine/CavityVolumeEngine.cpp"
"component/forcefield/AtmosphericPressureForceField.cpp"
"component/forcefield/CavityPressureForceField.cpp"
"initSuctionCup.cpp"
)

find_package(SofaFramework REQUIRED)

add_library(${PROJECT_NAME} SHARED ${HEADER_FILES} ${SOURCE_FILES})
target_link_libraries(${PROJECT_NAME} SofaCore SofaBaseVisual SofaBoundaryCondition SofaBaseTopology SofaBaseCollision SofaMeshCollision SofaConstraint)
set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "-DSOFA_BUILD_SUCTIONCUP")

install(TARGETS SuctionCup
RUNTIME DESTINATION bin
LIBRARY DESTINATION lib
ARCHIVE DESTINATION lib)
