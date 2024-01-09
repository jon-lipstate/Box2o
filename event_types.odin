package box2o

/// A begin touch event is generated when a shape starts to overlap a sensor shape.
SensorBeginTouchEvent :: struct {
	sensorShapeId:  ShapeId,
	visitorShapeId: ShapeId,
}

/// An end touch event is generated when a shape stops overlapping a sensor shape.
SensorEndTouchEvent :: struct {
	sensorShapeId:  ShapeId,
	visitorShapeId: ShapeId,
}

/// Sensor events are buffered in the Box2D world and are available
///	as begin/end overlap event arrays after the time step is complete.
///	Note: these may become invalid if bodies and/or shapes are destroyed
SensorEvents :: struct {
	beginEvents: ^SensorBeginTouchEvent,
	endEvents:   ^SensorEndTouchEvent,
	beginCount:  int,
	endCount:    int,
}

/// A begin touch event is generated when two shapes begin touching. By convention the manifold
/// normal points from shape A to shape B.
ContactBeginTouchEvent :: struct {
	shapeIdA: ShapeId,
	shapeIdB: ShapeId,
	manifold: Manifold,
}

/// An end touch event is generated when two shapes stop touching.
ContactEndTouchEvent :: struct {
	shapeIdA: ShapeId,
	shapeIdB: ShapeId,
}

/// Contact events are buffered in the Box2D world and are available
///	as event arrays after the time step is complete.
///	Note: these may become invalid if bodies and/or shapes are destroyed
ContactEvents :: struct {
	beginEvents: ^ContactBeginTouchEvent,
	endEvents:   ^ContactEndTouchEvent,
	beginCount:  int,
	endCount:    int,
}

/// The contact data for two shapes. By convention the manifold normal points
///	from shape A to shape B.
ContactData :: struct {
	shapeIdA: ShapeId,
	shapeIdB: ShapeId,
	manifold: Manifold,
}
