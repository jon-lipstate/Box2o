package box2o

/// This struct holds callbacks you can implement to draw a box2d world.
Debug_Draw :: struct {
	/// Draw a closed polygon provided in CCW order.
	Draw_Polygon:         proc(vertices: []Vector2, color: Color, ctx: rawptr),
	/// Draw a solid closed polygon provided in CCW order.
	DrawSolidPolygon:     proc(vertices: []Vector2, color: Color, ctx: rawptr),
	/// Draw a rounded polygon provided in CCW order.
	DrawRoundedPolygon:   proc(
		vertices: []Vector2,
		radius: Float,
		lineColor: Color,
		fillColor: Color,
		ctx: rawptr,
	),
	/// Draw a circle.
	DrawCircle:           proc(center: Vector2, radius: Float, color: Color, ctx: rawptr),
	/// Draw a solid circle.
	DrawSolidCircle:      proc(
		center: Vector2,
		radius: Float,
		axis: Vector2,
		color: Color,
		ctx: rawptr,
	),
	/// Draw a capsule.
	DrawCapsule:          proc(p1: Vector2, p2: Vector2, radius: Float, color: Color, ctx: rawptr),
	/// Draw a solid capsule.
	DrawSolidCapsule:     proc(p1: Vector2, p2: Vector2, radius: Float, color: Color, ctx: rawptr),
	/// Draw a line segment.
	DrawSegment:          proc(p1: Vector2, p2: Vector2, color: Color, ctx: rawptr),
	/// Draw a transform. Choose your own length scale.
	/// @param xf a transform.
	DrawTransform:        proc(xf: Transform, ctx: rawptr),
	/// Draw a point.
	DrawPoint:            proc(p: Vector2, size: Float, color: Color, ctx: rawptr),
	/// Draw a string.
	DrawString:           proc(p: Vector2, s: string, ctx: rawptr),
	drawShapes:           bool,
	drawJoints:           bool,
	drawAABBs:            bool,
	drawMass:             bool,
	drawContacts:         bool,
	drawGraphColors:      bool,
	drawContactNormals:   bool,
	drawContactImpulses:  bool,
	drawFrictionImpulses: bool,
	ctx:                  rawptr,
}
