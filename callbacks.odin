package box2o


/// Prototype for a pre-solve callback.
/// This is called after a contact is updated. This allows you to inspect a
/// contact before it goes to the solver. If you are careful, you can modify the
/// contact manifold (e.g. disable contact).
/// Notes:
///	- this function must be thread-safe
///	- this is only called if the shape has enabled presolve events
/// - this is called only for awake dynamic bodies
/// - this is not called for sensors
/// - the supplied manifold has impulse values from the previous step
///	Return false if you want to disable the contact this step
pre_solve_proc :: #type proc(
	shapeIdA: Shape_Id,
	shapeIdB: Shape_Id,
	manifold: ^Manifold,
	ctx: rawptr,
) -> bool

/// Register the pre-solve callback. This is optional.
world_set_pre_solve_callback :: #type proc(worldId: World_Id, fcn: pre_solve_proc, ctx: rawptr)

/// Prototype callback for AABB queries.
/// See World_Query
/// Called for each shape found in the query AABB.
/// @return false to terminate the query.
query_result_proc :: #type proc(shapeId: Shape_Id, ctx: rawptr) -> bool

/// Prototype callback for ray casts.
/// See World::RayCast
/// Called for each shape found in the query. You control how the ray cast
/// proceeds by returning a float:
/// return -1: ignore this shape and continue
/// return 0: terminate the ray cast
/// return fraction: clip the ray to this point
/// return 1: don't clip the ray and continue
/// @param shape the shape hit by the ray
/// @param point the point of initial intersection
/// @param normal the normal vector at the point of intersection
/// @param fraction the fraction along the ray at the point of intersection
/// @return -1 to filter, 0 to terminate, fraction to clip the ray for
/// closest hit, 1 to continue
ray_result_proc :: #type proc(
	shapeId: Shape_Id,
	point: Vector2,
	normal: Vector2,
	fraction: Float,
	ctx: rawptr,
) -> Float

/// Use an instance of this structure and the callback below to get the closest hit.
Ray_Result :: struct {
	shapeId:  Shape_Id,
	point:    Vector2,
	normal:   Vector2,
	fraction: Float,
	hit:      bool,
}

EMPTY_RAY_RESULT :: Ray_Result{{-1, -1, 0}, {0.0, 0.0}, {0.0, 0.0}, 0.0, false}
