package box2o

World_Id :: struct {
	index: i16,
	rev:   u16,
}
Body_Id :: struct {
	index: i32,
	world: i16,
	rev:   u16,
}
Shape_Id :: distinct Body_Id
Joint_Id :: distinct Body_Id
Chain_Id :: distinct Body_Id

NULL_WORLD_ID :: World_Id{-1, 0}
NULL_BODY_ID :: Body_Id{-1, -1, 0}
NULL_SHAPE_ID :: Shape_Id{-1, -1, 0}
NULL_JOINT_ID :: Joint_Id{-1, -1, 0}
NULL_CHAIN_ID :: Chain_Id{-1, -1, 0}

is_null_id :: proc {
	is_null_world_id,
	is_null_body_id,
	is_null_shape_id,
	is_null_joint_id,
	is_null_chain_id,
}
is_null_world_id :: proc(i: World_Id) -> bool {return i.index == -1}
is_null_body_id :: proc(i: Body_Id) -> bool {return i.index == -1}
is_null_shape_id :: proc(i: Shape_Id) -> bool {return i.index == -1}
is_null_joint_id :: proc(i: Joint_Id) -> bool {return i.index == -1}
is_null_chain_id :: proc(i: Chain_Id) -> bool {return i.index == -1}
///
ids_are_equal :: proc {
	body_ids_are_equal,
	shape_ids_are_equal,
	joint_ids_are_equal,
	chain_ids_are_equal,
}
body_ids_are_equal :: proc(a, b: Body_Id) -> bool {
	return a.index == b.index && a.world == b.world && a.rev == b.rev
}
shape_ids_are_equal :: proc(a, b: Shape_Id) -> bool {
	return body_ids_are_equal(Body_Id(a), Body_Id(b))
}
joint_ids_are_equal :: proc(a, b: Joint_Id) -> bool {
	return body_ids_are_equal(Body_Id(a), Body_Id(b))
}
chain_ids_are_equal :: proc(a, b: Chain_Id) -> bool {
	return body_ids_are_equal(Body_Id(a), Body_Id(b))
}
///
is_valid_id :: proc {
	is_valid_world_id,
	is_valid_body_id,
	is_valid_shape_id,
	is_valid_joint_id,
	is_valid_chain_id,
}
is_valid_world_id :: proc(i: World_Id) -> bool {
	if i.index < 0 || i.index >= MAX_WORLDS {return false}
	world := WORLDS[i.index]
	return i.rev == world.revision
}
is_valid_body_id :: proc(i: Body_Id) -> bool {
	if i.world < 0 || i.index >= MAX_WORLDS {return false}
	world := WORLDS[i.index]
	if i.index < 0 || world.body_pool.capacity <= i.index {
		return false
	}
	body := world.bodies[i.index]
	if !is_valid_object(body.pool_obj) {return false}
	return i.rev == body.pool_obj.rev
}
is_valid_shape_id :: proc(i: Shape_Id) -> bool {
	if i.world < 0 || i.index >= MAX_WORLDS {return false}
	world := WORLDS[i.index]
	if i.index < 0 || world.shape_pool.capacity <= i.index {
		return false
	}
	shape := world.shapes[i.index]
	if !is_valid_object(shape.object) {return false}
	return i.rev == shape.object.rev
}
is_valid_joint_id :: proc(i: Joint_Id) -> bool {
	if i.world < 0 || i.index >= MAX_WORLDS {return false}
	world := WORLDS[i.index]
	if i.index < 0 || world.joint_pool.capacity <= i.index {
		return false
	}
	joint := world.joints[i.index]
	if !is_valid_object(joint.object) {return false}
	return i.rev == joint.object.rev
}
is_valid_chain_id :: proc(i: Chain_Id) -> bool {
	if i.world < 0 || i.index >= MAX_WORLDS {return false}
	world := WORLDS[i.index]
	if i.index < 0 || world.chain_pool.capacity <= i.index {
		return false
	}
	chain := world.chains[i.index]
	if !is_valid_object(chain.object) {return false}
	return i.rev == chain.object.rev
}
