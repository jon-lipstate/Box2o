package box2o

Body :: struct {
	pool_obj:         Object,
	kind:             Body_Type,
	transform:        Transform, // the body origin transform (not center of mass)
	// C.G. (World Space)
	position0:        Vector2,
	position:         Vector2,
	// rotation(Radians)
	angle0:           Float,
	angle:            Float,
	// local center of mass relative to origin
	local_center:     Vector2,
	linear_velocity:  Vector2,
	angular_velocity: Float,

	// These are the change in position/angle that accumulate across constraint substeps
	delta_position:   Vector2,
	delta_angle:      Float,
	force:            Vector2,
	torque:           Float,
	shape_list:       i32,
	chain_list:       i32,

	// This is a key: [jointIndex:31, edgeIndex:1]
	joint_list:       i32,
	joint_count:      i32,
	contact_list:     i32,
	contact_count:    i32,

	// A non-static body is always in an island. B2_NULL_INDEX for static bodies.
	island_index:     i32,

	// Doubly linked island list
	island_prev:      i32,
	island_next:      i32,
	mass, inv_mass:   Float,

	// Rotational inertia about the center of mass.
	I:                Float,
	inv_I:            Float,
	min_extent:       Float,
	max_extent:       Float,
	linear_damping:   Float,
	angular_damping:  Float,
	gravity_scale:    Float,
	sleep_time:       Float,
	user_data:        rawptr,
	world:            i16,
	enable_sleep:     bool,
	fixed_rotation:   bool,
	is_enabled:       bool,
	is_marked:        bool,
	is_fast:          bool,
	is_speed_capped:  bool,
	enlarge_AABB:     bool,
}

// TODO_ERIN every non-static body gets a solver body. No solver bodies for static bodies to avoid cross thread sharing and the cache misses they bring.
// Keep two solver body arrays: awake and sleeping
// 12 + 12 + 8 = 32 bytes
Solver_Body :: struct {
	linear_velocity:  Vector2, // 8
	angular_velocity: Float, // 4

	// These are the change in position/angle that accumulate across constraint substeps
	delta_position:   Vector2, // 8
	delta_angle:      Float, // 4
	inv_mass:         Float, // 4
	inv_I:            Float, // 4
}


make_sweep :: proc(body: ^Body) -> Sweep {
	#partial switch body.kind {
	case .Static:
		s := Sweep {
			c1          = body.position,
			c2          = body.position,
			a1          = body.angle,
			a2          = body.angle,
			localCenter = body.local_center,
		}
		return s
	case:
		s := Sweep {
			c1          = body.position0,
			c2          = body.position,
			a1          = body.angle0,
			a2          = body.angle,
			localCenter = body.local_center,
		}
		return s
	}
}

create_island_for_body :: proc(world: ^World, body: ^Body, is_awake: bool) {
	assert(body.island_index == NULL_INDEX)
	assert(body.island_prev == NULL_INDEX)
	assert(body.island_next == NULL_INDEX)
	if body.kind == .Static {return}
	island := alloc_object(&world.island_pool, Island)
	unimplemented()
}
