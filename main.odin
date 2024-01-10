package box2o

main :: proc() {

	world_def := DEFAULT_WORLD_DEF
	world_def.gravity = Vector2{0, -10}
	world_id := create_world(&world_def)
	defer destroy_world(world_id)

	ground_body_def := DEFAULT_BODY_DEF
	ground_body_def.position = Vector2{0, -10}
	ground_body_id := create_body(world_id, &ground_body_def)

	ground_box := make_box(50, 10)
	ground_shape_def := DEFAULT_SHAPE_DEF
	create_polygon_shape(ground_body_id, &ground_shape_def, &ground_box)

	body_def := DEFAULT_BODY_DEF
	body_def.type = .Dynamic
	body_def.position = Vector2{0, 4}
	body_id := create_body(world_id, &body_def)

	shape_def := DEFAULT_SHAPE_DEF
	shape_def.density = 1
	shape_def.friction = 0.3

	circle: Circle
	circle.radius = 1
	create_circle_shape(body_id, &shape_def, &circle)

	time_step: f32 = 1.0 / 60
	velocity_iterations: i32 = 8
	position_iterations: i32 = 3

	for i in 0 ..< 60 {
		world_step(world_id, time_step, velocity_iterations, position_iterations)
		position := body_get_position(body_id)
		angle := body_get_angle(body_id)
		fmt.println(position, angle)
	}
}
