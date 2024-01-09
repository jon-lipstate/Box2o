package box2o

/// A convex hull. Used to create convex polygons.
Hull :: struct {
	points: [MAX_POLYGON_VERTS]Vector2,
	count:  i32,
}

/// Compute the convex hull of a set of points. Returns an empty hull if it fails.
/// Some failure cases:
/// - all points very close together
/// - all points on a line
/// - less than 3 points
/// - more than b2_maxPolygonVertices points
/// This welds close points and removes collinear points.
compute_hull :: proc(points: []Vector2) -> Hull

/// This determines if a hull is valid. Checks for:
/// - convexity
/// - collinear points
/// This is expensive and should not be called at runtime.
validate_hull :: proc(hull: ^Hull) -> bool
