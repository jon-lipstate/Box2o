package box2o

/// This holds the mass data computed for a shape.
Mass_Data :: struct {
	/// The mass of the shape, usually in kilograms.
	mass:   Float,
	/// The position of the shape's centroid relative to the shape's origin.
	center: Vector2,
	/// The rotational inertia of the shape about the local origin.
	I:      Float,
}

/// A solid circle
Circle :: struct {
	point:  Vector2,
	radius: Float,
}

/// A solid capsule
Capsule :: struct {
	point1, point2: Vector2,
	radius:         Float,
}

/// A solid convex polygon. It is assumed that the interior of the polygon is to
/// the left of each edge.
/// Polygons have a maximum number of vertices equal to _maxPolygonVertices.
/// In most cases you should not need many vertices for a convex polygon.
///	@warning DO NOT fill this out manually, instead use a helper function like
///	MakePolygon or MakeBox.
Polygon :: struct {
	vertices: [MAX_POLYGON_VERTS]Vector2,
	normals:  [MAX_POLYGON_VERTS]Vector2,
	centroid: Vector2,
	radius:   Float,
	count:    i32,
}

/// A line segment with two-sided collision.
Segment :: struct {
	point1: Vector2,
	point2: Vector2,
}

/// A smooth line segment with one-sided collision. Only collides on the right side.
/// Several of these are generated for a chain shape.
/// ghost1 -> point1 -> point2 -> ghost2
Smooth_Segment :: struct {
	/// The tail ghost vertex
	ghost1:     Vector2,
	/// The line segment
	segment:    Segment,
	/// The head ghost vertex
	ghost2:     Vector2,
	/// The owning chain shape index (internal usage only)
	chainIndex: i32,
}

/// Validate ray cast input data (NaN, etc)
IsValidRay :: proc(input: ^RayCast_Input) -> bool

/// Make a convex polygon from a convex hull. This will assert if the hull is not valid.
MakePolygon :: proc(hull: ^Hull, radius: Float) -> Polygon

/// Make an offset convex polygon from a convex hull. This will assert if the hull is not valid.
MakeOffsetPolygon :: proc(hull: ^Hull, radius: Float, transform: Transform) -> Polygon

/// Make a square polygon, bypassing the need for a convex hull.
MakeSquare :: proc(h: Float) -> Polygon

/// Make a box (rectangle) polygon, bypassing the need for a convex hull.
MakeBox :: proc(hx: Float, hy: Float) -> Polygon

/// Make a rounded box, bypassing the need for a convex hull.
MakeRoundedBox :: proc(hx: Float, hy: Float, radius: Float) -> Polygon

/// Make an offset box, bypassing the need for a convex hull.
MakeOffsetBox :: proc(hx: Float, hy: Float, center: Vector2, angle: Float) -> Polygon

/// Transform a polygon. This is useful for transfering a shape from one body to another.
TransformPolygon :: proc(transform: Transform, polygon: ^Polygon) -> Polygon

/// Compute mass properties of a circle
ComputeCircleMass :: proc(shape: ^Circle, density: Float) -> Mass_Data

/// Compute mass properties of a capsule
ComputeCapsuleMass :: proc(shape: ^Capsule, density: Float) -> Mass_Data

/// Compute mass properties of a polygon
ComputePolygonMass :: proc(shape: ^Polygon, density: Float) -> Mass_Data

/// Compute the bounding box of a transformed circle
ComputeCircleAABB :: proc(shape: ^Circle, transform: Transform) -> AABB

/// Compute the bounding box of a transformed capsule
ComputeCapsuleAABB :: proc(shape: ^Capsule, transform: Transform) -> AABB

/// Compute the bounding box of a transformed polygon
ComputePolygonAABB :: proc(shape: ^Polygon, transform: Transform) -> AABB

/// Compute the bounding box of a transformed line segment
ComputeSegmentAABB :: proc(shape: ^Segment, transform: Transform) -> AABB

/// Test a point for overlap with a circle in local space
PointInCircle :: proc(point: Vector2, shape: ^Circle) -> bool

/// Test a point for overlap with a capsule in local space
PointInCapsule :: proc(point: Vector2, shape: ^Capsule) -> bool

/// Test a point for overlap with a convex polygon in local space
PointInPolygon :: proc(point: Vector2, shape: ^Polygon) -> bool

/// Ray cast versus circle in shape local space. Initial overlap is treated as a miss.
RayCastCircle :: proc(input: ^RayCast_Input, shape: ^Circle) -> RayCast_Output

/// Ray cast versus capsule in shape local space. Initial overlap is treated as a miss.
RayCastCapsule :: proc(input: ^RayCast_Input, shape: ^Capsule) -> RayCast_Output

/// Ray cast versus segment in shape local space. Optionally treat the segment as one-sided with hits from
/// the left side being treated as a miss.
RayCastSegment :: proc(input: ^RayCast_Input, shape: ^Segment, oneSided: bool) -> RayCast_Output

/// Ray cast versus polygon in shape local space. Initial overlap is treated as a miss.
RayCastPolygon :: proc(input: ^RayCast_Input, shape: ^Polygon) -> RayCast_Output

/// Shape cast versus a circle. Initial overlap is treated as a miss.
ShapeCastCircle :: proc(input: ^ShapeCastInput, shape: ^Circle) -> RayCast_Output

/// Shape cast versus a capsule. Initial overlap is treated as a miss.
ShapeCastCapsule :: proc(input: ^ShapeCastInput, shape: ^Capsule) -> RayCast_Output

/// Shape cast versus a line segment. Initial overlap is treated as a miss.
ShapeCastSegment :: proc(input: ^ShapeCastInput, shape: ^Segment) -> RayCast_Output

/// Shape cast versus a convex polygon. Initial overlap is treated as a miss.
ShapeCastPolygon :: proc(input: ^ShapeCastInput, shape: ^Polygon) -> RayCast_Output
