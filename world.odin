package box2o

import ba "core:container/bit_array"
import "core:intrinsics"
import "core:mem"
WORLDS := [MAX_WORLDS]World{}
Task_Context :: struct {
	// These bits align with the awake contact array and signal change in contact status
	// that affects the island graph.
	contact_state: ba.Bit_Array,
	// Used to prevent duplicate awake contacts
	awake_contact: ba.Bit_Array,
	// Used to sort shapes that have enlarged AABBs
	shape:         ba.Bit_Array,
	// Used to wake islands
	awake_island:  ba.Bit_Array,
}
World :: struct {
	index:                     i16,
	internal_allocator:        mem.Allocator, // used for internal allocations-only (eg bit_arry and slices)
	block_allocator:           ^mem.Dynamic_Pool,
	stack_allocator:           ^mem.Stack,
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
	task_context_array:        []Task_Context,

	// Awake island array holds indices into the island array (islandPool).
	// This is a dense array that is rebuilt every time step.
	awake_island_array:        []i32,

	// Awake contact array holds contacts that should be updated.
	// This is a dense array that is rebuilt every time step. Order doesn't matter for determinism
	// but a bit set is used to prevent duplicates
	awake_contact_array:       [dynamic]i32,

	// Hot data split from b2Contact. Used when a contact is destroyed and needs to be removed from the awake contact array.
	// A contact is destroyed when a shape/body is destroyed or when the shape AABBs stop overlapping.
	// TODO_ERIN use a bit array somehow?
	contact_awake_index_array: []i32,
	sensor_begin_event_Array:  []Sensor_Begin_Touch_Event,
	sensor_end_event_Array:    []Sensor_End_Touch_Event,
	contact_begin_array:       []Contact_Begin_Touch_Event,
	contact_end_array:         []Contact_End_Touch_Event,

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
	pre_solve_fcn:             pre_solve_proc,
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

get_world_from_id :: #force_inline proc(id: World_Id) -> ^World {
	return get_world_from_index(id.index)
}
get_world_from_index :: proc(index: i16) -> ^World {
	assert(0 <= index && index <= MAX_WORLDS)
	world := &WORLDS[index]
	return world
}
get_world_from_index_locked :: proc(index: i16) -> ^World {
	world := get_world_from_index(index)
	if world.locked {
		debug_break()
		return nil
	}
	return world
}
default_add_task_proc :: proc(
	task: Task_Callback,
	count: i32,
	min_range: i32,
	task_ctx: rawptr,
	user_ctx: rawptr,
) -> rawptr {
	task(0, count, 0, task_ctx)
	return nil
}
default_finish_task_proc :: proc(user_task: rawptr, user_ctx: rawptr) { /**/}

create_world :: proc(
	def: ^World_Def,
	allocator := context.allocator,
) -> (
	id: World_Id,
	ok: bool,
) #optional_ok {
	context.allocator = allocator
	id = NULL_WORLD_ID
	for i: i16 = 0; i < MAX_WORLDS; i += 1 {
		if WORLDS[i].block_allocator == nil {
			id.index = i
			break
		}
	}
	if id.index == NULL_WORLD_ID.index {return id, false} 	// alloc failure
	initialize_contact_registers()
	world := &WORLDS[id.index]
	world^ = {} // zero all world memory
	world.index = id.index
	world.block_allocator = create_block_allocator()
	world.stack_allocator = create_stack_allocator(def.arenaAllocatorCapacity)

	create_broad_phase(&world.broadPhase)
	create_graph(&world.graph, def.bodyCapacity, def.contactCapacity, def.jointCapacity)

	world.body_pool = create_pool(Body, max(def.bodyCapacity, 1))
	world.bodies = (cast([^]Body)world.body_pool.memory) // todo: sb slice?

	world.shape_pool = create_pool(Shape, max(def.shapeCapacity, 1))
	world.shapes = (cast([^]Shape)world.shape_pool.memory) // todo: sb slice?

	world.chain_pool = create_pool(Chain, max(def.chainCapacity, 1))
	world.chains = (cast([^]Chain)world.chain_pool.memory) // todo: sb slice?

	world.contact_pool = create_pool(Contact, max(def.contactCapacity, 1))
	world.contacts = (cast([^]Contact)world.contact_pool.memory) // todo: sb slice?

	world.joint_pool = create_pool(Joint, max(def.jointCapacity, 1))
	world.joints = (cast([^]Joint)world.joint_pool.memory) // todo: sb slice?

	world.island_pool = create_pool(Island, max(def.islandCapacity, 1))
	world.islands = (cast([^]Island)world.island_pool.memory) // todo: sb slice?

	world.awake_island_array = make([]i32, max(def.bodyCapacity, 1))

	world.awake_contact_array = make([]i32, max(def.contactCapacity, 1))
	world.contact_awake_index_array = make([]i32, world.contact_pool.capacity)

	world.sensor_begin_event_array = make([]i32, size_of(Sensor_Begin_Touch_Event), 4)
	world.sensor_end_event_array = make([]i32, size_of(Sensor_End_Touch_Event), 4)

	world.contact_begin_array = make([]i32, size_of(Contact_Begin_Touch_Event), 4)
	world.contact_end_array = make([]i32, size_of(Contact_End_Touch_Event), 4)

	world.revision += 1 // Globals start at 0. It should be fine for this to roll over.

	world.gravity = def.gravity
	world.restitution_threshold = def.restitutionThreshold
	world.contact_pushout_velocity = def.contactPushoutVelocity
	world.contact_hertz = def.contactHertz
	world.contact_damping_ratio = def.contactDampingRatio
	world.enable_sleep = true
	world.enable_warm_starting = true
	world.enable_continuous = true
	world.profile = EMPTY_PROFILE
	world.split_island_index = NULL_INDEX

	id.rev = world.revision

	if def.workerCount > 0 && def.enqueueTask != nil && def.finishTask != nil {
		world.worker_count = min(def.workerCount, MAX_WORKERS)
		world.enqueue_task_fcn = def.enqueueTask
		world.finish_task_fcn = def.finishTask
		world.user_task_context = def.userTaskContext
	} else {
		world.worker_count = 1
		world.enqueue_task_fcn = default_add_task_proc
		world.finish_task_fcn = default_finish_task_proc
	}
	world.task_context_array = make([]size_of(Task_Context), world.worker_count)
	for &tc in world.task_context_array {
		tc.contact_state = ba.create(def.contactCapacity, 0)
		tc.awake_contact = ba.create(def.contactCapacity, 0)
		tc.shape = ba.create(def.shapeCapacity, 0)
		tc.awake_island = ba.create(256, 0)
	}
	return id
}
destroy_world :: proc(id: World_Id) {
	world := get_world_from_id(id)
	for &tca in world.task_context_array {
		ba.destroy(tca.contact_state, world.internal_allocator)
		ba.destroy(tca.awake_contact, world.internal_allocator)
		ba.destroy(tca.shape, world.internal_allocator)
		ba.destroy(tca.awake_island, world.internal_allocator)
	}
	delete(world.task_context_array, world.internal_allocator)
	delete(world.awake_contact_array, world.internal_allocator)
	delete(world.awake_island_array, world.internal_allocator)
	delete(world.contact_awake_index_array, world.internal_allocator)

	delete(world.sensor_BeginEvent_Array, world.internal_allocator)
	delete(world.sensor_EndEvent_Array, world.internal_allocator)

	delete(world.contact_Begin_Array, world.internal_allocator)
	delete(world.contact_End_Array, world.internal_allocator)

	mem.dynamic_pool_destroy(&world.island_pool)
	mem.dynamic_pool_destroy(&world.joint_pool)
	mem.dynamic_pool_destroy(&world.contact_pool)
	mem.dynamic_pool_destroy(&world.shape_pool)

	for i := 0; i < world.chain_pool.capacity; i += 1 {
		chain := world.chains[i]
		if object_valid(&chain.object) {
			free(chain.shapeIndices) // fixme
		}
	}

	mem.dynamic_pool_destroy(&world.chain_pool)
	mem.dynamic_pool_destroy(&world.body_pool)

	destroy_graph(world.graph)
	destroy_broad_phase(world.broadPhase)

	world^ = {}
}

is_body_id_valid :: proc(world: ^World, id: Body_Id) -> bool {
	if id.world != world.index do return false
	if id.index >= world.body_pool.capacity do return false
	body := world.bodies[id.index]
	if body.pool_obj.index != body.pool_obj.next do return false
	if body.pool_obj.rev != id.rev do return false
	return true
}

set_pre_solve_callback :: proc(world_id: World_Id, fcn: ^pre_solve_proc, ctx: rawptr) {
	world := get_world_from_id(world_id)
	world.pre_solve_fcn = fcn
	world.pre_solve_context = ctx
}

collide_task :: proc(start_index: i32, end_index: i32, thread_index: ui32, ctx: rawptr) {
	//tracy_c_zone_nc(collide_task, "Collide Task", color_dodger_blue_1, true)
	world := cast(^World)ctx
	assert(thread_index < world.worker_count)
	task_context := &world.task_context_array[thread_index]
	shapes := world.shapes
	bodies := world.bodies
	contacts := world.contacts
	awake_count := len(world.awake_contact_array)
	awake_contact_array := world.awake_contact_array
	contact_awake_index_array := world.contact_awake_index_array

	assert(start_index < end_index)
	assert(end_index <= awake_count)

	for awake_index := start_index; awake_index < end_index; awake_index += 1 {
		contact_index := awake_contact_array[awake_index]
		if contact_index == NULL_INDEX {
			// Contact was destroyed
			continue
		}

		assert(0 <= contact_index && contact_index < world.contact_pool.capacity)
		contact := &contacts[contact_index]

		assert(contact_awake_index_array[contact_index] == awake_index)
		assert(
			contact.object.index == contact_index && contact.object.index == contact.object.next,
		)

		// Reset contact awake index. Contacts must be added to the awake contact array
		// each time step in the island solver.
		contact_awake_index_array[contact_index] = NULL_INDEX

		shape_a := &shapes[contact.shape_index_a]
		shape_b := &shapes[contact.shape_index_b]

		// Do proxies still overlap?
		overlap := aabb_overlaps(shape_a.fat_aabb, shape_b.fat_aabb)
		if !overlap {
			contact.flags |= Contact_Flags.Disjoint
			ba.set(&task_context.contact_state, awake_index)
		} else {
			was_touching := (contact.flags & Contact_Flags.Touching) != 0
			assert(was_touching || contact.island_index == NULL_INDEX)

			// Update contact respecting shape/body order (A,B)
			body_a := &bodies[shape_a.body_index]
			body_b := &bodies[shape_b.body_index]
			update_contact(world, contact, shape_a, body_a, shape_b, body_b)

			touching := (contact.flags & Contact_Flags.Touching) != 0

			// State changes that affect island connectivity
			if touching && !was_touching {
				contact.flags |= Contact_Flags.StartedTouching
				ba.set(&task_context.contact_state_bit_set, awake_index)
			} else if !touching && was_touching {
				contact.flags |= Contact_Flags.StoppedTouching
				ba.set(&task_context.contact_state_bit_set, awake_index)
			}
		}
	}
	//tracy_c_zone_end(collide_task)
}

update_trees_task :: proc(startIndex: i32, endIndex: i32, threadIndex: v, ctx: rawptr) {
	// b2TracyCZoneNC(tree_task, "Rebuild Trees", b2_colorSnow1, true)
	world := cast(^World)ctx
	broad_phase_rebuild_trees(&world.broadPhase)
	// b2TracyCZoneEnd(tree_task)
}
// Narrow-phase collision
collide :: proc(world: ^World) {
	assert(world.worker_count > 0)
	//tracy_c_zone_nc(collide, "Collide", color_dark_orchid, true)

	world.user_tree_task = world.enqueue_task_fcn(
		update_trees_task,
		1,
		1,
		world,
		world.user_task_context,
	)
	world.task_count += 1
	world.active_task_count += world.user_tree_task != nil ? 1 : 0

	awake_contact_count := len(world.awake_contact_array)

	if awake_contact_count == 0 {
		//tracy_c_zone_end(collide)
		return
	}

	for i := 0; i < world.worker_count; i += 1 {
		ba.clear(&world.task_context_array[i].contact_state)
		// cpp resizes here, odin does in the physics loop via set(), but should only happen on one frame
	}

	// Task should take at least 40us on a 4GHz CPU (10K cycles)
	min_range := i32(64)
	user_collide_task := world.enqueue_task_fcn(
		collide_task,
		awake_contact_count,
		min_range,
		world,
		world.user_task_context,
	)
	world.task_count += 1
	if user_collide_task != nil {
		world.finish_task_fcn(user_collide_task, world.user_task_context)
	}

	//tracy_c_zone_nc(contact_state, "Contact State", color_coral, true)

	// Bitwise OR all contact bits (joining worker's results)
	contact_state := &world.task_context_array[0].contact_state
	for i := 1; i < world.worker_count; i += 1 {
		in_place_union(contact_state, &world.task_context_array[i].contact_state)
	}
	// Prepare to capture events
	clear(&world.sensor_begin_event_array)
	clear(&world.sensor_end_event_array)
	clear(&world.contact_begin_array)
	clear(&world.contact_end_array)

	shapes := world.shapes
	world_index := world.index

	for k := 0; k < len(contact_state.bits); k += 1 {
		word := contact_state.bits[k]
		for word != 0 {
			ctz := intrinsics.count_trailing_zeros(word)
			awake_index := 64 * k + ctz
			assert(awake_index < u32(awake_contact_count))

			contact_index := world.awake_contact_array[awake_index]
			assert(contact_index != NULL_INDEX)

			contact := &world.contacts[contact_index]
			shape_a := &shapes[contact.shape_index_a]
			shape_b := &shapes[contact.shape_index_b]
			shape_id_a := Shape_Id{shape_a.object.index, world_index, shape_a.object.revision}
			shape_id_b := Shape_Id{shape_b.object.index, world_index, shape_b.object.revision}
			flags := contact.flags

			if flags & Contact_Flags.Disjoint != 0 {
				if flags & Contact_Flags.Touching != 0 &&
				   flags & Contact_Flags.EnableContactEvents != 0 {
					event := Contact_End_Touch_Event{shape_id_a, shape_id_b}
					append(&world.contact_end_array, event)
				}
				destroy_contact(world, contact)
			} else if flags & Contact_Flags.StartedTouching != 0 {
				assert(contact.island_index == NULL_INDEX)
				if flags & Contact_Flags.Sensor != 0 &&
				   flags & Contact_Flags.EnableSensorEvents != 0 {
					if shape_a.is_sensor {
						event := Sensor_Begin_Touch_Event{shape_id_a, shape_id_b}
						append(&world.sensor_begin_event_array, event)
					}

					if shape_b.is_sensor {
						event := Sensor_Begin_Touch_Event{shape_id_b, shape_id_a}
						append(&world.sensor_begin_event_array, event)
					}
				} else {
					if flags & Contact_Flags.EnableContactEvents != 0 {
						event := Contact_Begin_Touch_Event {
							shape_id_a,
							shape_id_b,
							contact.manifold,
						}
						append(&world.contact_begin_array, event)
					}

					link_contact(world, contact)
					add_contact_to_graph(world, contact)
				}

				contact.flags &= ~Contact_Flags.StartedTouching
			} else {
				assert(contact.flags & Contact_Flags.StoppedTouching != 0)
				if flags & Contact_Flags.Sensor != 0 &&
				   flags & Contact_Flags.EnableSensorEvents != 0 {
					if shape_a.is_sensor {
						event := Sensor_End_Touch_Event{shape_id_a, shape_id_b}
						append(&world.sensor_end_event_array, event)
					}

					if shape_b.is_sensor {
						event := Sensor_End_Touch_Event{shape_id_b, shape_id_a}
						append(&world.sensor_end_event_array, event)
					}
				} else {
					if contact.flags & Contact_Flags.EnableContactEvents != 0 {
						event := Contact_End_Touch_Event{shape_id_a, shape_id_b}
						append(&world.contact_end_array, event)
					}

					unlink_contact(world, contact)
					remove_contact_from_graph(world, contact)
				}

				contact.flags &= ~Contact_Flags.StoppedTouching
			}
			// Clear the smallest set bit
			word = word & (word - 1)
		}
	}

	// tracy_c_zone_end(contact_state)
	// tracy_c_zone_end(collide)
}
