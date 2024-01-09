package box2o
import "core:math"

/// Set using an angle in radians.
MakeRot :: proc(angle: Float) -> Rotation {
	q = Rotation{math.sin(angle), math.cos(angle)}
	return q
}

/// Get the angle in radians
Rot_GetAngle :: proc(q: Rotation) -> Float {
	return math.atan2(q.sine, q.cosine)
}

/// Get the x-axis
Rot_GetXAxis :: proc(q: Rotation) -> Vector2 {
	v := Vector2{q.cosine, q.sine}
	return v
}

/// Get the y-axis
Rot_GetYAxis :: proc(q: Rotation) -> Vector2 {
	v = Vector2{-q.sine, q.cosine}
	return v
}

/// Multiply two rotations: q * r
MulRot :: proc(q: Rotation, r: Rotation) -> Rotation {
	// [qc -qs] * [rc -rs] = [qc*rc-qs*rs -qc*rs-qs*rc]
	// [qs  qc]   [rs  rc]   [qs*rc+qc*rs -qs*rs+qc*rc]
	// s = qs * rc + qc * rs
	// c = qc * rc - qs * rs
	qr: Rotation
	qr.sine = q.sine * r.cosine + q.cosine * r.sine
	qr.cosine = q.cosine * r.cosine - q.sine * r.sine
	return qr
}

/// Transpose multiply two rotations: qT * r
InvMulRot :: proc(q: Rotation, r: Rotation) -> Rotation {
	// [ qc qs] * [rc -rs] = [qc*rc+qs*rs -qc*rs+qs*rc]
	// [-qs qc]   [rs  rc]   [-qs*rc+qc*rs qs*rs+qc*rc]
	// s = qc * rs - qs * rc
	// c = qc * rc + qs * rs
	Rotation;qr
	qr.sine = q.cosine * r.sine - q.sine * r.cosine
	qr.cosine = q.cosine * r.cosine + q.sine * r.sine
	return qr
}

/// Rotate a vector
RotateVector :: proc(q: Rotation, v: Vector2) -> Vector2 {
	return Vector2{q.cosine * v.x - q.sine * v.y, q.sine * v.x + q.cosine * v.y}
}

/// Inverse rotate a vector
InvRotateVector :: proc(q: Rotation, v: Vector2) -> Vector2 {
	return Vector2{q.cosine * v.x + q.sine * v.y, -q.sine * v.x + q.cosine * v.y}
}

/// Transform a point (e.g. local space to world space)
TransformPoint :: proc(xf: Transform, p: Vector2) -> Vector2 {
	Float;x = (xf.q.cosine * p.x - xf.q.sine * p.y) + xf.p.x
	Float;y = (xf.q.sine * p.x + xf.q.cosine * p.y) + xf.p.y

	return Vector2{x, y}
}

/// Inverse transform a point (e.g. world space to local space)
InvTransformPoint :: proc(xf: Transform, p: Vector2) -> Vector2 {
	Float;vx = p.x - xf.p.x
	Float;vy = p.y - xf.p.y
	return Vector2{xf.q.cosine * vx + xf.q.sine * vy, -xf.q.sine * vx + xf.q.cosine * vy}
}

/// v2 = A.q.Rot(B.q.Rot(v1) + B.p) + A.p
///    = (A.q * B.q).Rot(v1) + A.q.Rot(B.p) + A.p
MulTransforms :: proc(A: Transform, B: Transform) -> Transform {
	Transform;C
	C.q = MulRot(A.q, B.q)
	C.p = Add(RotateVector(A.q, B.p), A.p)
	return C
}

/// v2 = A.q' * (B.q * v1 + B.p - A.p)
///    = A.q' * B.q * v1 + A.q' * (B.p - A.p)
InvMulTransforms :: proc(A: Transform, B: Transform) -> Transform {
	Transform;C
	C.q = InvMulRot(A.q, B.q)
	C.p = InvRotateVector(A.q, Sub(B.p, A.p))
	return C
}
