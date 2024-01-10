package box2o

/// A begin touch event is generated when a shape starts to overlap a sensor shape.
Sensor_Begin_Touch_Event :: struct {
	sensorShapeId:  Shape_Id,
	visitorShapeId: Shape_Id,
}

/// An end touch event is generated when a shape stops overlapping a sensor shape.
Sensor_End_Touch_Event :: struct {
	sensorShapeId:  Shape_Id,
	visitorShapeId: Shape_Id,
}

/// Sensor events are buffered in the Box2D world and are available
///	as begin/end overlap event arrays after the time step is complete.
///	Note: these may become invalid if bodies and/or shapes are destroyed
Sensor_Events :: struct {
	beginEvents: ^Sensor_Begin_Touch_Event,
	endEvents:   ^Sensor_End_Touch_Event,
	beginCount:  int,
	endCount:    int,
}

/// A begin touch event is generated when two shapes begin touching. By convention the manifold
/// normal points from shape A to shape B.
Contact_Begin_Touch_Event :: struct {
	shapeIdA: Shape_Id,
	shapeIdB: Shape_Id,
	manifold: Manifold,
}

/// An end touch event is generated when two shapes stop touching.
Contact_End_Touch_Event :: struct {
	shapeIdA: Shape_Id,
	shapeIdB: Shape_Id,
}

/// Contact events are buffered in the Box2D world and are available
///	as event arrays after the time step is complete.
///	Note: these may become invalid if bodies and/or shapes are destroyed
Contact_Events :: struct {
	beginEvents: ^Contact_Begin_Touch_Event,
	endEvents:   ^Contact_End_Touch_Event,
	beginCount:  int,
	endCount:    int,
}

/// The contact data for two shapes. By convention the manifold normal points
///	from shape A to shape B.
Contact_Data :: struct {
	shapeIdA: Shape_Id,
	shapeIdB: Shape_Id,
	manifold: Manifold,
}
