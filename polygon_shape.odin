package box2o
/// A chain shape is a free form sequence of line segments.
/// The chain has one-sided collision, with the surface normal pointing to the right of the edge.
/// This provides a counter-clockwise winding like the polygon shape.
/// @warning the chain will not collide properly if there are self-intersections.
Polygon_Shape :: []Vector2
