package box2o

// Result of computing the distance between two line segments
Segment_Distance_Result :: struct {
	closest1:     Vector2,
	closest2:     Vector2,
	fraction1:    Float,
	fraction2:    Float,
	dist_squared: Float,
}

// Compute the distance between two line segments, clamping at the end points if needed.
//B2_API
segment_distance :: proc(
	p1: Vector2,
	q1: Vector2,
	p2: Vector2,
	q2: Vector2,
) -> Segment_Distance_Result {unimplemented()}

/// A distance proxy is used by the GJK algorithm. It encapsulates any shape.
Distance_Proxy :: struct {
	vertices: [MAX_POLYGON_VERTS]Vector2,
	count:    i32,
	radius:   Float,
}

/// Used to warm start Distance.
/// Set count to zero on first call.
Distance_Cache :: struct {
	metric: Float, ///< length or area
	count:  u16,
	indexA: [3]u8, ///< vertices on shape A
	indexB: [3]u8, ///< vertices on shape B
}

EMPTY_DISTANCE_CACHE :: Distance_Cache{}

/// Input for Distance.
/// You have to option to use the shape radii
/// in the computation. Even
Distance_Input :: struct {
	proxyA:     Distance_Proxy,
	proxyB:     Distance_Proxy,
	transformA: Transform,
	transformB: Transform,
	useRadii:   bool,
}

/// Output for Distance.
Distance_Output :: struct {
	pointA:     Vector2, ///< closest point on shapeA
	pointB:     Vector2, ///< closest point on shapeB
	distance:   Float,
	iterations: i32, ///< number of GJK iterations used
}

/// Compute the closest points between two shapes. Supports any combination of:
/// Circle, Polygon, EdgeShape. The simplex cache is input/output.
/// On the first call set SimplexCache.count to zero.
//_API
ShapeDistance :: proc(
	cache: ^Distance_Cache,
	input: ^Distance_Input,
) -> Distance_Output {unimplemented()}

/// Input parameters for ShapeCast
Shape_Cast_Pair_Input :: struct {
	proxyA:       Distance_Proxy,
	proxyB:       Distance_Proxy,
	transformA:   Transform,
	transformB:   Transform,
	translationB: Vector2,
	maxFraction:  Float,
}

/// Perform a linear shape cast of shape B moving and shape A fixed. Determines the hit point, normal, and translation fraction.
/// @returns true if hit, false if there is no hit or an initial overlap
//_API
ShapeCast :: proc(input: ^Shape_Cast_Pair_Input) -> RayCast_Output {unimplemented()}

/// Make a proxy for use in GJK and related functions.
//_API
make_proxy :: proc(vertices: []Vector2, radius: Float) -> Distance_Proxy {unimplemented()}

/// This describes the motion of a body/shape for TOI computation. Shapes are defined with respect to the body origin,
/// which may not coincide with the center of mass. However, to support dynamics we must interpolate the center of mass
/// position.
Sweep :: struct {
	/// local center of mass position
	local_center: Vector2,
	/// center world positions
	c1, c2:       Vector2,
	/// world angles
	a1, a2:       Float,
}

//b2_api
get_sweep_transform :: proc(sweep: ^Sweep, time: Float) -> Transform {unimplemented()}

/// Input parameters for TimeOfImpact
TOI_Input :: struct {
	proxyA: Distance_Proxy,
	proxyB: Distance_Proxy,
	sweepA: Sweep,
	sweepB: Sweep,

	// defines sweep interval [0, tMax]
	tMax:   Float,
}

/// Describes the TOI output
TOI_State :: enum {
	Unknown,
	Failed,
	Overlapped,
	Hit,
	Separated,
}

/// Output parameters for TimeOfImpact.
TOI_Output :: struct {
	state: TOI_State,
	t:     Float,
}

/// Compute the upper bound on time before two shapes penetrate. Time is represented as
/// a fraction between [0,tMax]. This uses a swept separating axis and may miss some intermediate,
/// non-tunneling collisions. If you change the time interval, you should call this function
/// again.
//b2_API
time_of_impact :: proc(input: ^TOI_Input) -> TOI_Output {unimplemented()}
