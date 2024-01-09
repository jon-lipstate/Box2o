package box2o

import "core:math"
import la "core:math/linalg"

// TODO: CONFIGS
when true {
	Vector2 :: la.Vector2f32
	Float :: f32
	FLT_MAX :: math.F32_MAX
	FLT_MIN :: -math.F32_MIN
	EPSILON :: math.F32_EPSILON
} else {
	Vector2 :: la.Vector2f64
	Float :: f64
	FLT_MAX :: math.F64_MAX
	FLT_MIN :: -math.F64_MIN
	EPSILON :: math.F64_EPSILON
}
Color :: distinct la.Vector4f32
HUGE_NUMBER :: 100000.0 * LENGTH_SCALE
PI :: math.PI
LENGTH_SCALE :: 1 // length-per-meter
EPSILON_V2 :: Vector2{EPSILON, EPSILON}

// This is used to fatten AABBs in the dynamic tree. This allows proxies
// to move by a small amount without triggering a tree adjustment.
// This is in meters.
// @warning modifying this can have a significant impact on performance
AABB_MARGIN :: 0.1 * LENGTH_SCALE

// A small length used as a collision and constraint tolerance. Usually it is
// chosen to be numerically significant, but visually insignificant. In meters.
// @warning modifying this can have a significant impact on stability
LINEAR_SLOP :: 0.005 * LENGTH_SCALE

// A small angle used as a collision and constraint tolerance. Usually it is
// chosen to be numerically significant, but visually insignificant.
// @warning modifying this can have a significant impact on stability
ANGULAR_SLOP :: (2.0 / 180) * PI

// The maximum linear translation of a body per step. This limit is very large and is used
// to prevent numerical problems. You shouldn't need to adjust this. Meters.
// @warning modifying this can have a significant impact on stability
MAX_POLYGON_VERTS :: 8

// Maximum number of simultaneous worlds that can be allocated
MAX_WORLDS :: 128

// The maximum linear translation of a body per step. This limit is very large and is used
// to prevent numerical problems. You shouldn't need to adjust this. Meters.
// @warning modifying this can have a significant impact on stability
MAX_TRANSLATION :: 4 * LENGTH_SCALE

// The maximum angular velocity of a body. This limit is very large and is used
// to prevent numerical problems. You shouldn't need to adjust this.
// @warning modifying this can have a significant impact on stability
MAX_ROTATION :: PI * 0.5

// @warning modifying this can have a significant impact on performance and stability
SPECULATIVE_DISTANCE :: 4 * LINEAR_SLOP

// The time that a body must be still before it will go to sleep. In seconds.
TIME_TO_SLEEP :: 0.5

// A body cannot sleep if its linear velocity is above this tolerance. Meters per second.
LINEAR_SLEEP_TOLERANCE :: 0.01 * LENGTH_SCALE

// A body cannot sleep if its angular velocity is above this tolerance. Radians per second.
ANGULAR_SLEEP_TOLERANCE :: (2.0 / 180) * PI

// Used to detect bad values. Positions greater than about 16km will have precision
// problems, so 100km as a limit should be fine in all cases.
HUGE :: 100_000.0 * LENGTH_SCALE

/// Maximum parallel workers. Used to size some static arrays.
MAX_WORKERS :: 64

/// Solver graph coloring
GRAPH_COLOR_COUNT :: 12

/// Version numbering scheme.
Version :: struct {
	major:    int,
	minor:    int,
	revision: int,
}

VERSION :: Version{3, 0, 0}

NULL_INDEX :: -1
