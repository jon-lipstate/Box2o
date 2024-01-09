package box2o

WORLDS := [MAX_WORLDS]World{}

World :: struct {
	index:                     i16,
	block_allocator:           ^Block_Allocator,
	stack_allocator:           ^Block_Allocator,
	broadPhase:                Broad_Phase,
	graph:                     Graph,
	body_pool:                 Pool,
	contact_pool:              Pool,
	joint_pool:                Pool,
	shape_pool:                Pool,
	chain_pool:                Pool,
	island_pool:               Pool,

	// These are sparse arrays that point into the pools above
	bodies:                    [^]Body,
	contacts:                  [^]Contact,
	joints:                    [^]Joint,
	shapes:                    [^]Shape,
	chains:                    [^]Chain_Shape,
	islands:                   [^]Island,

	// Per thread storage
	task_context_array:        [^]Task_Context,

	// Awake island array holds indices into the island array (islandPool).
	// This is a dense array that is rebuilt every time step.
	awake_island_array:        [^]i32,

	// Awake contact array holds contacts that should be updated.
	// This is a dense array that is rebuilt every time step. Order doesn't matter for determinism
	// but a bit set is used to prevent duplicates
	awake_contact_array:       [^]i32,

	// Hot data split from b2Contact. Used when a contact is destroyed and needs to be removed from the awake contact array.
	// A contact is destroyed when a shape/body is destroyed or when the shape AABBs stop overlapping.
	// TODO_ERIN use a bit array somehow?
	contact_awake_index_array: [^]i32,
	sensor_BeginEvent_Array:   ^Sensor_Begin_Touch_Event,
	sensor_EndEvent_Array:     ^Sensor_End_Touch_Event,
	contact_Begin_Array:       ^Contact_Begin_Touch_Event,
	contact_End_Array:         ^Contact_End_Touch_Event,

	// Array of fast bodies that need continuous collision handling
	fast_bodies:               [^]i32,
	fast_body_count:           Atomic_Int,

	// Id that is incremented every time step
	step_id:                   u64,
	gravity:                   Vector2,
	restitution_threshold:     Float,
	contact_pushout_velocity:  Float,
	contact_hertz:             Float,
	contact_damping_ratio:     Float,

	// This is used to compute the time step ratio to support a variable time step.
	inv_dt0:                   Float,
	revision:                  u16,
	profile:                   Profile,
	pre_solve_fcn:             Pre_Solve_Fcn,
	pre_solve_context:         rawptr,
	worker_count:              u32,
	enqueue_task_fcn:          ^Enqueue_Task_Callback,
	finish_task_fcn:           ^Finish_Task_Callback,
	user_task_context:         rawptr,
	user_tree_task:            rawptr,
	split_island_index:        i32,
	active_task_count:         i32,
	task_count:                i32,
	enable_sleep:              bool,
	locked:                    bool,
	enable_warm_starting:      bool,
	enable_continuous:         bool,
}

GetWorldFromId :: proc(id: World_Id) -> ^World {unimplemented()}
GetWorldFromIndex :: proc(index: i16) -> ^World {unimplemented()}
GetWorldFromIndexLocked :: proc(index: i16) -> ^World {unimplemented()}

IsBodyIdValid :: proc(world: ^World, id: Body_Id) -> bool {unimplemented()}
