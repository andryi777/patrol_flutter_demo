@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

// Required defines for Patrol 4.x
// CLEAR_PERMISSIONS: Reset permissions between tests
// FULL_ISOLATION: Run each test in a fresh simulator (causes multiple simulators)
#define CLEAR_PERMISSIONS NO
#define FULL_ISOLATION NO

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
