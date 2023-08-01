/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE // For RTLD_DEFAULT
#endif

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>

// Sanity check for ARM to avoid puzzling runtime crashes
#ifdef __arm__
# if defined __thumb__ && ! defined __THUMB_INTERWORK__
#   error "ARM trampolines need -mthumb-interwork to work in Thumb mode"
# endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(cond, fmt, ...) do { \
    if(!(cond)) { \
      fprintf(stderr, "implib-gen: libchipmunk.so.7: " fmt "\n", ##__VA_ARGS__); \
      assert(0 && "Assertion in generated code"); \
      abort(); \
    } \
  } while(0)

#define HAS_DLOPEN_CALLBACK 0
#define HAS_DLSYM_CALLBACK 0
#define NO_DLOPEN 0
#define LAZY_LOAD 1

static void *lib_handle;
static int do_dlclose;
static int is_lib_loading;

#if ! NO_DLOPEN
static void *load_library() {
  if(lib_handle)
    return lib_handle;

  is_lib_loading = 1;

#if HAS_DLOPEN_CALLBACK
  extern void *(const char *lib_name);
  lib_handle = ("libchipmunk.so.7");
  CHECK(lib_handle, "failed to load library 'libchipmunk.so.7' via callback ''");
#else
  lib_handle = dlopen("libchipmunk.so.7", RTLD_LAZY | RTLD_GLOBAL);
  CHECK(lib_handle, "failed to load library 'libchipmunk.so.7' via dlopen: %s", dlerror());
#endif

  do_dlclose = 1;
  is_lib_loading = 0;

  return lib_handle;
}

static void __attribute__((destructor)) unload_lib() {
  if(do_dlclose && lib_handle)
    dlclose(lib_handle);
}
#endif

#if ! NO_DLOPEN && ! LAZY_LOAD
static void __attribute__((constructor)) load_lib() {
  load_library();
}
#endif

// TODO: convert to single 0-separated string
static const char *const sym_names[] = {
  "cpArbiterApplyCachedImpulse",
  "cpArbiterApplyImpulse",
  "cpArbiterCallWildcardBeginA",
  "cpArbiterCallWildcardBeginB",
  "cpArbiterCallWildcardPostSolveA",
  "cpArbiterCallWildcardPostSolveB",
  "cpArbiterCallWildcardPreSolveA",
  "cpArbiterCallWildcardPreSolveB",
  "cpArbiterCallWildcardSeparateA",
  "cpArbiterCallWildcardSeparateB",
  "cpArbiterGetBodies",
  "cpArbiterGetContactPointSet",
  "cpArbiterGetCount",
  "cpArbiterGetDepth",
  "cpArbiterGetFriction",
  "cpArbiterGetNormal",
  "cpArbiterGetPointA",
  "cpArbiterGetPointB",
  "cpArbiterGetRestitution",
  "cpArbiterGetShapes",
  "cpArbiterGetSurfaceVelocity",
  "cpArbiterGetUserData",
  "cpArbiterIgnore",
  "cpArbiterInit",
  "cpArbiterIsFirstContact",
  "cpArbiterIsRemoval",
  "cpArbiterPreStep",
  "cpArbiterSetContactPointSet",
  "cpArbiterSetFriction",
  "cpArbiterSetRestitution",
  "cpArbiterSetSurfaceVelocity",
  "cpArbiterSetUserData",
  "cpArbiterTotalImpulse",
  "cpArbiterTotalKE",
  "cpArbiterUnthread",
  "cpArbiterUpdate",
  "cpAreaForCircle",
  "cpAreaForPoly",
  "cpAreaForSegment",
  "cpArrayContains",
  "cpArrayDeleteObj",
  "cpArrayFree",
  "cpArrayFreeEach",
  "cpArrayNew",
  "cpArrayPop",
  "cpArrayPush",
  "cpBBTreeAlloc",
  "cpBBTreeInit",
  "cpBBTreeNew",
  "cpBBTreeOptimize",
  "cpBBTreeSetVelocityFunc",
  "cpBodyAccumulateMassFromShapes",
  "cpBodyActivate",
  "cpBodyActivateStatic",
  "cpBodyAddShape",
  "cpBodyAlloc",
  "cpBodyApplyForceAtLocalPoint",
  "cpBodyApplyForceAtWorldPoint",
  "cpBodyApplyImpulseAtLocalPoint",
  "cpBodyApplyImpulseAtWorldPoint",
  "cpBodyDestroy",
  "cpBodyEachArbiter",
  "cpBodyEachConstraint",
  "cpBodyEachShape",
  "cpBodyFree",
  "cpBodyGetAngle",
  "cpBodyGetAngularVelocity",
  "cpBodyGetCenterOfGravity",
  "cpBodyGetForce",
  "cpBodyGetMass",
  "cpBodyGetMoment",
  "cpBodyGetPosition",
  "cpBodyGetRotation",
  "cpBodyGetSpace",
  "cpBodyGetTorque",
  "cpBodyGetType",
  "cpBodyGetUserData",
  "cpBodyGetVelocity",
  "cpBodyGetVelocityAtLocalPoint",
  "cpBodyGetVelocityAtWorldPoint",
  "cpBodyInit",
  "cpBodyIsSleeping",
  "cpBodyKineticEnergy",
  "cpBodyLocalToWorld",
  "cpBodyNew",
  "cpBodyNewKinematic",
  "cpBodyNewStatic",
  "cpBodyRemoveConstraint",
  "cpBodyRemoveShape",
  "cpBodySetAngle",
  "cpBodySetAngularVelocity",
  "cpBodySetCenterOfGravity",
  "cpBodySetForce",
  "cpBodySetMass",
  "cpBodySetMoment",
  "cpBodySetPosition",
  "cpBodySetPositionUpdateFunc",
  "cpBodySetTorque",
  "cpBodySetType",
  "cpBodySetUserData",
  "cpBodySetVelocity",
  "cpBodySetVelocityUpdateFunc",
  "cpBodySleep",
  "cpBodySleepWithGroup",
  "cpBodyUpdatePosition",
  "cpBodyUpdateVelocity",
  "cpBodyWorldToLocal",
  "cpBoxShapeInit",
  "cpBoxShapeInit2",
  "cpBoxShapeNew",
  "cpBoxShapeNew2",
  "cpCentroidForPoly",
  "cpCheckAxis",
  "cpCheckPointGreater",
  "cpCircleShapeAlloc",
  "cpCircleShapeGetOffset",
  "cpCircleShapeGetRadius",
  "cpCircleShapeInit",
  "cpCircleShapeNew",
  "cpCircleShapeSetOffset",
  "cpCircleShapeSetRadius",
  "cpCollide",
  "cpConstraintDestroy",
  "cpConstraintFree",
  "cpConstraintGetBodyA",
  "cpConstraintGetBodyB",
  "cpConstraintGetCollideBodies",
  "cpConstraintGetErrorBias",
  "cpConstraintGetImpulse",
  "cpConstraintGetMaxBias",
  "cpConstraintGetMaxForce",
  "cpConstraintGetPostSolveFunc",
  "cpConstraintGetPreSolveFunc",
  "cpConstraintGetSpace",
  "cpConstraintGetUserData",
  "cpConstraintInit",
  "cpConstraintIsDampedRotarySpring",
  "cpConstraintIsDampedSpring",
  "cpConstraintIsGearJoint",
  "cpConstraintIsGrooveJoint",
  "cpConstraintIsPinJoint",
  "cpConstraintIsPivotJoint",
  "cpConstraintIsRatchetJoint",
  "cpConstraintIsRotaryLimitJoint",
  "cpConstraintIsSimpleMotor",
  "cpConstraintIsSlideJoint",
  "cpConstraintSetCollideBodies",
  "cpConstraintSetErrorBias",
  "cpConstraintSetMaxBias",
  "cpConstraintSetMaxForce",
  "cpConstraintSetPostSolveFunc",
  "cpConstraintSetPreSolveFunc",
  "cpConstraintSetUserData",
  "cpContactBufferGetArray",
  "cpConvexHull",
  "cpDampedRotarySpringAlloc",
  "cpDampedRotarySpringGetDamping",
  "cpDampedRotarySpringGetRestAngle",
  "cpDampedRotarySpringGetSpringTorqueFunc",
  "cpDampedRotarySpringGetStiffness",
  "cpDampedRotarySpringInit",
  "cpDampedRotarySpringNew",
  "cpDampedRotarySpringSetDamping",
  "cpDampedRotarySpringSetRestAngle",
  "cpDampedRotarySpringSetSpringTorqueFunc",
  "cpDampedRotarySpringSetStiffness",
  "cpDampedSpringAlloc",
  "cpDampedSpringGetAnchorA",
  "cpDampedSpringGetAnchorB",
  "cpDampedSpringGetDamping",
  "cpDampedSpringGetRestLength",
  "cpDampedSpringGetSpringForceFunc",
  "cpDampedSpringGetStiffness",
  "cpDampedSpringInit",
  "cpDampedSpringNew",
  "cpDampedSpringSetAnchorA",
  "cpDampedSpringSetAnchorB",
  "cpDampedSpringSetDamping",
  "cpDampedSpringSetRestLength",
  "cpDampedSpringSetSpringForceFunc",
  "cpDampedSpringSetStiffness",
  "cpGearJointAlloc",
  "cpGearJointGetPhase",
  "cpGearJointGetRatio",
  "cpGearJointInit",
  "cpGearJointNew",
  "cpGearJointSetPhase",
  "cpGearJointSetRatio",
  "cpGrooveJointAlloc",
  "cpGrooveJointGetAnchorB",
  "cpGrooveJointGetGrooveA",
  "cpGrooveJointGetGrooveB",
  "cpGrooveJointInit",
  "cpGrooveJointNew",
  "cpGrooveJointSetAnchorB",
  "cpGrooveJointSetGrooveA",
  "cpGrooveJointSetGrooveB",
  "cpHashSetCount",
  "cpHashSetEach",
  "cpHashSetFilter",
  "cpHashSetFind",
  "cpHashSetFree",
  "cpHashSetInsert",
  "cpHashSetNew",
  "cpHashSetRemove",
  "cpHashSetSetDefaultValue",
  "cpHastySpaceFree",
  "cpHastySpaceGetThreads",
  "cpHastySpaceNew",
  "cpHastySpaceSetThreads",
  "cpHastySpaceStep",
  "cpLoopIndexes",
  "cpMarchHard",
  "cpMarchSoft",
  "cpMessage",
  "cpMomentForBox",
  "cpMomentForBox2",
  "cpMomentForCircle",
  "cpMomentForPoly",
  "cpMomentForSegment",
  "cpPinJointAlloc",
  "cpPinJointGetAnchorA",
  "cpPinJointGetAnchorB",
  "cpPinJointGetDist",
  "cpPinJointInit",
  "cpPinJointNew",
  "cpPinJointSetAnchorA",
  "cpPinJointSetAnchorB",
  "cpPinJointSetDist",
  "cpPivotJointAlloc",
  "cpPivotJointGetAnchorA",
  "cpPivotJointGetAnchorB",
  "cpPivotJointInit",
  "cpPivotJointNew",
  "cpPivotJointNew2",
  "cpPivotJointSetAnchorA",
  "cpPivotJointSetAnchorB",
  "cpPolyShapeAlloc",
  "cpPolyShapeGetCount",
  "cpPolyShapeGetRadius",
  "cpPolyShapeGetVert",
  "cpPolyShapeInit",
  "cpPolyShapeInitRaw",
  "cpPolyShapeNew",
  "cpPolyShapeNewRaw",
  "cpPolyShapeSetRadius",
  "cpPolyShapeSetVerts",
  "cpPolyShapeSetVertsRaw",
  "cpPolylineConvexDecomposition",
  "cpPolylineFree",
  "cpPolylineIsClosed",
  "cpPolylineSetAlloc",
  "cpPolylineSetCollectSegment",
  "cpPolylineSetDestroy",
  "cpPolylineSetFree",
  "cpPolylineSetInit",
  "cpPolylineSetNew",
  "cpPolylineSimplifyCurves",
  "cpPolylineSimplifyVertexes",
  "cpPolylineToConvexHull",
  "cpRatchetJointAlloc",
  "cpRatchetJointGetAngle",
  "cpRatchetJointGetPhase",
  "cpRatchetJointGetRatchet",
  "cpRatchetJointInit",
  "cpRatchetJointNew",
  "cpRatchetJointSetAngle",
  "cpRatchetJointSetPhase",
  "cpRatchetJointSetRatchet",
  "cpRotaryLimitJointAlloc",
  "cpRotaryLimitJointGetMax",
  "cpRotaryLimitJointGetMin",
  "cpRotaryLimitJointInit",
  "cpRotaryLimitJointNew",
  "cpRotaryLimitJointSetMax",
  "cpRotaryLimitJointSetMin",
  "cpSegmentShapeAlloc",
  "cpSegmentShapeGetA",
  "cpSegmentShapeGetB",
  "cpSegmentShapeGetNormal",
  "cpSegmentShapeGetRadius",
  "cpSegmentShapeInit",
  "cpSegmentShapeNew",
  "cpSegmentShapeSetEndpoints",
  "cpSegmentShapeSetNeighbors",
  "cpSegmentShapeSetRadius",
  "cpShapeCacheBB",
  "cpShapeDestroy",
  "cpShapeFree",
  "cpShapeGetArea",
  "cpShapeGetBB",
  "cpShapeGetBody",
  "cpShapeGetCenterOfGravity",
  "cpShapeGetCollisionType",
  "cpShapeGetDensity",
  "cpShapeGetElasticity",
  "cpShapeGetFilter",
  "cpShapeGetFriction",
  "cpShapeGetMass",
  "cpShapeGetMoment",
  "cpShapeGetSensor",
  "cpShapeGetSpace",
  "cpShapeGetSurfaceVelocity",
  "cpShapeGetUserData",
  "cpShapeInit",
  "cpShapePointQuery",
  "cpShapeSegmentQuery",
  "cpShapeSetBody",
  "cpShapeSetCollisionType",
  "cpShapeSetDensity",
  "cpShapeSetElasticity",
  "cpShapeSetFilter",
  "cpShapeSetFriction",
  "cpShapeSetMass",
  "cpShapeSetSensor",
  "cpShapeSetSurfaceVelocity",
  "cpShapeSetUserData",
  "cpShapeUpdate",
  "cpShapeUpdateFunc",
  "cpShapesCollide",
  "cpSimpleMotorAlloc",
  "cpSimpleMotorGetRate",
  "cpSimpleMotorInit",
  "cpSimpleMotorNew",
  "cpSimpleMotorSetRate",
  "cpSlideJointAlloc",
  "cpSlideJointGetAnchorA",
  "cpSlideJointGetAnchorB",
  "cpSlideJointGetMax",
  "cpSlideJointGetMin",
  "cpSlideJointInit",
  "cpSlideJointNew",
  "cpSlideJointSetAnchorA",
  "cpSlideJointSetAnchorB",
  "cpSlideJointSetMax",
  "cpSlideJointSetMin",
  "cpSpaceActivateBody",
  "cpSpaceAddBody",
  "cpSpaceAddCollisionHandler",
  "cpSpaceAddConstraint",
  "cpSpaceAddDefaultCollisionHandler",
  "cpSpaceAddPostStepCallback",
  "cpSpaceAddShape",
  "cpSpaceAddWildcardHandler",
  "cpSpaceAlloc",
  "cpSpaceArbiterSetFilter",
  "cpSpaceBBQuery",
  "cpSpaceCollideShapes",
  "cpSpaceContainsBody",
  "cpSpaceContainsConstraint",
  "cpSpaceContainsShape",
  "cpSpaceDebugDraw",
  "cpSpaceDestroy",
  "cpSpaceEachBody",
  "cpSpaceEachConstraint",
  "cpSpaceEachShape",
  "cpSpaceFilterArbiters",
  "cpSpaceFree",
  "cpSpaceGetCollisionBias",
  "cpSpaceGetCollisionPersistence",
  "cpSpaceGetCollisionSlop",
  "cpSpaceGetCurrentTimeStep",
  "cpSpaceGetDamping",
  "cpSpaceGetGravity",
  "cpSpaceGetIdleSpeedThreshold",
  "cpSpaceGetIterations",
  "cpSpaceGetPostStepCallback",
  "cpSpaceGetSleepTimeThreshold",
  "cpSpaceGetStaticBody",
  "cpSpaceGetUserData",
  "cpSpaceHashAlloc",
  "cpSpaceHashInit",
  "cpSpaceHashNew",
  "cpSpaceHashResize",
  "cpSpaceInit",
  "cpSpaceIsLocked",
  "cpSpaceLock",
  "cpSpaceNew",
  "cpSpacePointQuery",
  "cpSpacePointQueryNearest",
  "cpSpaceProcessComponents",
  "cpSpacePushContacts",
  "cpSpacePushFreshContactBuffer",
  "cpSpaceReindexShape",
  "cpSpaceReindexShapesForBody",
  "cpSpaceReindexStatic",
  "cpSpaceRemoveBody",
  "cpSpaceRemoveConstraint",
  "cpSpaceRemoveShape",
  "cpSpaceSegmentQuery",
  "cpSpaceSegmentQueryFirst",
  "cpSpaceSetCollisionBias",
  "cpSpaceSetCollisionPersistence",
  "cpSpaceSetCollisionSlop",
  "cpSpaceSetDamping",
  "cpSpaceSetGravity",
  "cpSpaceSetIdleSpeedThreshold",
  "cpSpaceSetIterations",
  "cpSpaceSetSleepTimeThreshold",
  "cpSpaceSetStaticBody",
  "cpSpaceSetUserData",
  "cpSpaceShapeQuery",
  "cpSpaceStep",
  "cpSpaceUnlock",
  "cpSpaceUseSpatialHash",
  "cpSpatialIndexCollideStatic",
  "cpSpatialIndexFree",
  "cpSpatialIndexInit",
  "cpSweep1DAlloc",
  "cpSweep1DInit",
  "cpSweep1DNew",
  0
};

#define SYM_COUNT (sizeof(sym_names)/sizeof(sym_names[0]) - 1)

extern void *_libchipmunk_so_tramp_table[];

// Can be sped up by manually parsing library symtab...
void _libchipmunk_so_tramp_resolve(int i) {
  assert((unsigned)i < SYM_COUNT);

  CHECK(!is_lib_loading, "library function '%s' called during library load", sym_names[i]);

  void *h = 0;
#if NO_DLOPEN
  // Library with implementations must have already been loaded.
  if (lib_handle) {
    // User has specified loaded library
    h = lib_handle;
  } else {
    // User hasn't provided us the loaded library so search the global namespace.
#   ifndef IMPLIB_EXPORT_SHIMS
    // If shim symbols are hidden we should search
    // for first available definition of symbol in library list
    h = RTLD_DEFAULT;
#   else
    // Otherwise look for next available definition
    h = RTLD_NEXT;
#   endif
  }
#else
  h = load_library();
  CHECK(h, "failed to resolve symbol '%s', library failed to load", sym_names[i]);
#endif

#if HAS_DLSYM_CALLBACK
  extern void *(void *handle, const char *sym_name);
  _libchipmunk_so_tramp_table[i] = (h, sym_names[i]);
  CHECK(_libchipmunk_so_tramp_table[i], "failed to resolve symbol '%s' via callback ", sym_names[i]);
#else
  // Dlsym is thread-safe so don't need to protect it.
  _libchipmunk_so_tramp_table[i] = dlsym(h, sym_names[i]);
  CHECK(_libchipmunk_so_tramp_table[i], "failed to resolve symbol '%s' via dlsym: %s", sym_names[i], dlerror());
#endif
}

// Helper for user to resolve all symbols
void _libchipmunk_so_tramp_resolve_all(void) {
  size_t i;
  for(i = 0; i < SYM_COUNT; ++i)
    _libchipmunk_so_tramp_resolve(i);
}

// Allows user to specify manually loaded implementation library.
void _libchipmunk_so_tramp_set_handle(void *handle) {
  lib_handle = handle;
  do_dlclose = 0;
}

// Resets all resolved symbols. This is needed in case
// client code wants to reload interposed library multiple times.
void _libchipmunk_so_tramp_reset(void) {
  memset(_libchipmunk_so_tramp_table, 0, SYM_COUNT * sizeof(_libchipmunk_so_tramp_table[0]));
  lib_handle = 0;
  do_dlclose = 0;
}

#ifdef __cplusplus
}  // extern "C"
#endif
