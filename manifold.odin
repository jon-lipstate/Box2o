package box2o

/// A manifold point is a contact point belonging to a contact
/// manifold. It holds details related to the geometry and dynamics
/// of the contact points.
Manifold_Point :: struct {
	/// world coordinates of contact point
	point:            Vector2,
	/// body anchors used by solver internally
	anchorA, anchorB: Vector2,
	/// the separation of the contact point, negative if penetrating
	separation:       Float,
	/// the non-penetration impulse
	normalImpulse:    Float,
	/// the friction impulse
	tangentImpulse:   Float,
	/// uniquely identifies a contact point between two shapes
	id:               u16,
	/// did this contact point exist the previous step?
	persisted:        bool,
}

/// Contact manifold convex shapes.
Manifold :: struct {
	points:     [2]Manifold_Point,
	normal:     Vector2,
	pointCount: i32,
}

/// Compute the collision manifold between two circles.
CollideCircles :: proc(
	circleA: ^Circle,
	xfA: Transform,
	circleB: ^Circle,
	xfB: Transform,
) -> Manifold

/// Compute the collision manifold between a capsule and circle
CollideCapsuleAndCircle :: proc(
	capsuleA: ^Capsule,
	xfA: Transform,
	circleB: ^Circle,
	xfB: Transform,
) -> Manifold

/// Compute the collision manifold between an segment and a circle.
CollideSegmentAndCircle :: proc(
	segmentA: ^Segment,
	xfA: Transform,
	circleB: ^Circle,
	xfB: Transform,
) -> Manifold

/// Compute the collision manifold between a polygon and a circle.
CollidePolygonAndCircle :: proc(
	polygonA: ^Polygon,
	xfA: Transform,
	circleB: ^Circle,
	xfB: Transform,
) -> Manifold

/// Compute the collision manifold between a capsule and circle
CollideCapsules :: proc(
	capsuleA: ^Capsule,
	xfA: Transform,
	capsuleB: ^Capsule,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between an segment and a capsule.
CollideSegmentAndCapsule :: proc(
	segmentA: ^Segment,
	xfA: Transform,
	capsuleB: ^Capsule,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between a polygon and capsule
CollidePolygonAndCapsule :: proc(
	polygonA: ^Polygon,
	xfA: Transform,
	capsuleB: ^Capsule,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between two polygons.
CollidePolygons :: proc(
	polyA: ^Polygon,
	xfA: Transform,
	polyB: ^Polygon,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between an segment and a polygon.
CollideSegmentAndPolygon :: proc(
	segmentA: ^Segment,
	xfA: Transform,
	polygonB: ^Polygon,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between a smooth segment and a circle.
CollideSmoothSegmentAndCircle :: proc(
	smoothSegmentA: ^SmoothSegment,
	xfA: Transform,
	circleB: ^Circle,
	xfB: Transform,
) -> Manifold

/// Compute the collision manifold between an segment and a capsule.
CollideSmoothSegmentAndCapsule :: proc(
	segmentA: ^SmoothSegment,
	xfA: Transform,
	capsuleB: ^Capsule,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold

/// Compute the collision manifold between a smooth segment and a rounded polygon.
CollideSmoothSegmentAndPolygon :: proc(
	segmentA: ^SmoothSegment,
	xfA: Transform,
	polygonB: ^Polygon,
	xfB: Transform,
	cache: ^DistanceCache,
) -> Manifold
