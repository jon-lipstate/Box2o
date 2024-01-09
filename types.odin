package box2o
/// The body type.
/// static: zero mass, zero velocity, may be manually moved
/// kinematic: zero mass, non-zero velocity set by user, moved by solver
/// dynamic: positive mass, non-zero velocity determined by forces, moved by solver
Body_Type :: enum {
	Static    = 0,
	Kinematic = 1,
	Dynamic   = 2,
}
Transform :: struct {
	origin:   Vector2,
	rotation: Rotation,
}
Rotation :: struct {
	sine:   Float,
	cosine: Float,
}
Atomic_Int :: distinct int
Atomic_UInt :: distinct uint

RayCast_Output :: struct {
	normal:     Vector2,
	point:      Vector2,
	fraction:   Float,
	iterations: i32,
	hit:        bool,
}
/// Low level ray-cast input data
RayCast_Input :: struct {
	origin:      Vector2,
	translation: Vector2,
	maxFraction: Float,
}

/// Low level hape cast input in generic form
ShapeCastInput :: struct {
	points:      [MAX_POLYGON_VERTS]Vector2,
	count:       i32,
	radius:      Float,
	translation: Vector2,
	maxFraction: Float,
}

/// Low level ray-cast or shape-cast output data
CastOutput :: struct {
	normal:     Vector2,
	point:      Vector2,
	fraction:   Float,
	iterations: i32,
	hit:        bool,
}

/// Task interface
/// This is prototype for a Box2D task. Your task system is expected to invoke the Box2D task with these arguments.
/// The task spans a range of the parallel-for: [startIndex, endIndex)
/// The thread index must correctly identify each thread in the user thread pool, expected in [0, workerCount)
/// The task context is the context pointer sent from Box2D when it is enqueued.
Task_Callback :: #type proc(startIndex: i32, endIndex: i32, threadIndex: u32, taskContext: rawptr)

/// These functions can be provided to Box2D to invoke a task system. These are designed to work well with enkiTS.
/// Returns a pointer to the user's task object. May be nilptr.
Enqueue_Task_Callback :: #type proc(
	task: ^Task_Callback,
	itemCount: i32,
	minRange: i32,
	taskContext: rawptr,
	userContext: rawptr,
) -> rawptr

/// Finishes a user task object that wraps a Box2D task.
Finish_Task_Callback :: #type proc(userTask: rawptr, userContext: rawptr)

/// World definition used to create a simulation world. Must be initialized using DefaultWorldDef.
WorldDef :: struct {
	/// Gravity vector. Box2D has no up-vector defined.
	gravity:                Vector2,
	/// Restitution velocity threshold, usually in m/s. Collisions above this
	/// speed have restitution applied (will bounce).
	restitutionThreshold:   Float,
	/// This parameter controls how fast overlap is resolved and has units of meters per second
	contactPushoutVelocity: Float,
	/// Contact stiffness. Cycles per second.
	contactHertz:           Float,
	/// Contact bounciness. Non-dimensional.
	contactDampingRatio:    Float,
	/// Can bodies go to sleep to improve performance
	enableSleep:            bool,
	/// Capacity for bodies. This may not be exceeded.
	bodyCapacity:           i32,
	/// initial capacity for shapes
	shapeCapacity:          i32,
	/// Capacity for contacts. This may not be exceeded.
	contactCapacity:        i32,
	/// Capacity for joints
	jointCapacity:          i32,
	/// Stack allocator capacity. This controls how much space box2d reserves for per-frame calculations.
	/// Larger worlds require more space. Counters can be used to determine a good capacity for your
	/// application.
	arenaAllocatorCapacity: i32,
	/// task system hookup
	workerCount:            u32,
	/// function to spawn task
	enqueueTask:            ^EnqueueTaskCallback,
	/// function to finish a task
	finishTask:             ^FinishTaskCallback,
	/// User context that is provided to enqueueTask and finishTask
	userTaskContext:        rawptr,
}

/// Use this to initialize your world definition
DEFAULT_WORLD_DEF := World_Def {
	Vector2{0.0, -10.0}, // gravity
	1. * LENGTH_SCALE, // restitutionThreshold
	3. * LENGTH_SCALE, // contactPushoutVelocity
	30.0, // contactHertz
	1.0, // contactDampingRatio
	true, // enableSleep
	0, // bodyCapacity
	0, // shapeCapacity
	0, // contactCapacity
	0, // jointCapacity
	1024 * 1024, // arenaAllocatorCapacity
	0, // workerCount
	nil, // enqueueTask
	nil, // finishTask
	nil, // userTaskContext}:,
}

/// A body definition holds all the data needed to construct a rigid body.
/// You can safely re-use body definitions. Shapes are added to a body after construction.
BodyDef :: struct {
	/// The body type: static, kinematic, or dynamic.
	/// Note: if a dynamic body would have zero mass, the mass is set to one.
	type:            Body_Type,
	/// The world position of the body. Avoid creating bodies at the origin
	/// since this can lead to many overlapping shapes.
	position:        Vector2,
	/// The world angle of the body in radians.
	angle:           Float,
	/// The linear velocity of the body's origin in world co-ordinates.
	linearVelocity:  Vector2,
	/// The angular velocity of the body.
	angularVelocity: Float,
	/// Linear damping is use to reduce the linear velocity. The damping parameter
	/// can be larger than 1.0f but the damping effect becomes sensitive to the
	/// time step when the damping parameter is large.
	linearDamping:   Float,
	/// Angular damping is use to reduce the angular velocity. The damping parameter
	/// can be larger than 1.0f but the damping effect becomes sensitive to the
	/// time step when the damping parameter is large.
	angularDamping:  Float,
	/// Scale the gravity applied to this body.
	gravityScale:    Float,
	/// Use this to store application specific body data.
	userData:        rawptr,
	/// Set this flag to false if this body should never fall asleep. Note that
	/// this increases CPU usage.
	enableSleep:     bool,
	/// Is this body initially awake or sleeping?
	isAwake:         bool,
	/// Should this body be prevented from rotating? Useful for characters.
	fixedRotation:   bool,
	/// Does this body start out enabled?
	isEnabled:       bool,
}

/// Use this to initialize your body definition
DEFAULT_BODY_DEF := Body_Def {
	.Static, // bodyType
	{0.0, 0.0}, // position
	0.0, // angle
	{0.0, 0.0}, // linearVelocity
	0.0, // angularVelocity
	0.0, // linearDamping
	0.0, // angularDamping
	1.0, // gravityScale
	nil, // userData
	true, // enableSleep
	true, // isAwake
	false, // fixedRotation
	true, // isEnabled}:,
}
/// This holds contact filtering data.
Filter :: struct {
	/// The collision category bits. Normally you would just set one bit.
	categoryBits: u32,
	/// The collision mask bits. This states the categories that this
	/// shape would accept for collision.
	maskBits:     u32,
	/// Collision groups allow a certain group of objects to never collide (negative)
	/// or always collide (positive). Zero means no collision group. Non-zero group
	/// filtering always wins against the mask bits.
	groupIndex:   i32,
}

/// Use this to initialize your filter
DEFAULT_FILTER := Filter{0x00000001, 0xFFFFFFFF, 0}

/// This holds contact filtering data.
QueryFilter :: struct {
	/// The collision category bits. Normally you would just set one bit.
	categoryBits: u32,
	/// The collision mask bits. This states the categories that this
	/// shape would accept for collision.
	maskBits:     u32,
}

/// Use this to initialize your query filter
DEFAULT_QUERY_FILTER := QueryFilter{0x00000001, 0xFFFFFFFF}

/// Shape type
Shape_Type :: enum {
	Capsule,
	Circle,
	Polygon,
	Segment,
	Smooth_Segment,
}

/// Used to create a shape
Shape_Def :: struct {
	/// Use this to store application specific shape data.
	userData:             rawptr,
	/// The friction coefficient, usually in the range [0,1].
	friction:             Float,
	/// The restitution (bounce) usually in the range [0,1].
	restitution:          Float,
	/// The density, usually in kg/m^2.
	density:              Float,
	/// Contact filtering data.
	filter:               Filter,
	/// A sensor shape collects contact information but never generates a collision response.
	isSensor:             bool,
	/// Enable sensor events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	enableSensorEvents:   bool,
	/// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	enableContactEvents:  bool,
	/// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
	///	and must be carefully handled due to multi-threading. Ignored for sensors.
	enablePreSolveEvents: bool,
}

/// Use this to initialize your shape definition
DEFAULT_SHAPE_DEF := Shape_Def {
	nil, // userData
	0.6, // friction
	0.0, // restitution
	1.0, // density
	{0x00000001, 0xFFFFFFFF, 0}, // filter
	false, // isSensor
	true, // enableSensorEvents
	true, // enableContactEvents
	false, // enablePreSolveEvents
}

/// Used to create a chain of edges. This is designed to eliminate ghost collisions with some limitations.
///	- DO NOT use chain shapes unless you understand the limitations. This is an advanced feature!
///	- chains are one-sided
///	- chains have no mass and should be used on static bodies
///	- the front side of the chain points the right of the point sequence
///	- chains are either a loop or open
/// - a chain must have at least 4 points
///	- the distance between any two points must be greater than _linearSlop
///	- a chain shape should not self intersect (this is not validated)
///	- an open chain shape has NO COLLISION on the first and final edge
///	- you may overlap two open chains on their first three and/or last three points to get smooth collision
///	- a chain shape creates multiple hidden shapes on the body
ChainDef :: struct {
	/// An array of at least 4 points. These are cloned and may be temporary.
	points:      []Vector2,
	/// Indicates a closed chain formed by connecting the first and last points
	loop:        bool,
	/// Use this to store application specific shape data.
	userData:    rawptr,
	/// The friction coefficient, usually in the range [0,1].
	friction:    Float,
	/// The restitution (elasticity) usually in the range [0,1].
	restitution: Float,
	/// Contact filtering data.
	filter:      Filter,
}

/// Use this to initialize your chain definition
DEFAULT_CHAIN_DEF := Chain_Def {
	nil, // points
	0, // count
	false, // loop
	nil, // userData
	0.6, // friction
	0.0, // restitution
	{0x00000001, 0xFFFFFFFF, 0}, // filter
}

/// Profiling data. Times are in milliseconds.
Profile :: struct {
	step:             Float,
	pairs:            Float,
	collide:          Float,
	solve:            Float,
	buildIslands:     Float,
	solveConstraints: Float,
	broadphase:       Float,
	continuous:       Float,
}

/// Use this to initialize your profile
EMPTY_PROFILE := Profile{}

/// Counters that give details of the simulation size
Counters :: struct {
	islandCount:   i32,
	bodyCount:     i32,
	contactCount:  i32,
	jointCount:    i32,
	proxyCount:    i32,
	pairCount:     i32,
	treeHeight:    i32,
	stackCapacity: i32,
	stackUsed:     i32,
	byteCount:     i32,
	taskCount:     i32,
	colorCounts:   [GRAPH_COLOR_COUNT + 1]i32,
}

/// Use this to initialize your counters
COUNTERS := Counters{}
