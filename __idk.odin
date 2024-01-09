package box2o
import "core:math"
import la "core:math/linalg"

is_valid_flt :: #force_inline proc(flt: Float) -> bool {
	if math.is_nan(flt) {return false}
	if math.is_inf(flt) {return false}
	return true
}
is_valid_vector2 :: #force_inline proc(v: Vector2) -> bool {
	return is_valid_flt(v.x) && is_valid_flt(v.y)
}

normalize :: la.normalize0
norm_and_magnitude :: proc(v: Vector2) -> (norm: Vector2, mag: Float) {
	mag = math.sqrt(la.dot(v, v))
	if mag < EPSILON {
		norm = Vector2{}
		mag = 0
	}
	norm = v / mag
	return
}
normalize_checked :: proc(v: Vector2) -> Vector2 {
	mag := math.sqrt(la.dot(v, v))
	if mag < EPSILON {
		panic("Failed checked normalize, zero-length vector")
	}
	return v / mag
}

abs_piecewise :: #force_inline proc(v: Vector2) -> Vector2 {
	return Vector2{math.abs(v.x), math.abs(v.y)}
}
// Element-Wise ||
compare_any :: #force_inline proc(a: Vector2, cmp: Comparison, b: Vector2) -> bool {
	switch cmp {
	case .LT:
		return a.x < b.x || a.y < b.y
	case .LTE:
		return a.x <= b.x || a.y <= b.y
	case .GT:
		return a.x > b.x || a.y > b.y
	case .GTE:
		return a.x >= b.x || a.y >= b.y
	case .EQ:
		return a.x == b.x || a.y == b.y
	case .Not_EQ:
		return a.x != b.x || a.y != b.y
	}
	unreachable()
}
// Element-Wise &&
compare_all :: #force_inline proc(a: Vector2, cmp: Comparison, b: Vector2) -> bool {
	switch cmp {
	case .LT:
		return a.x < b.x && a.y < b.y
	case .LTE:
		return a.x <= b.x && a.y <= b.y
	case .GT:
		return a.x > b.x && a.y > b.y
	case .GTE:
		return a.x >= b.x && a.y >= b.y
	case .EQ:
		return a.x == b.x && a.y == b.y
	case .Not_EQ:
		return a.x != b.x && a.y != b.y
	}
	unreachable()
}
Comparison :: enum {
	LT,
	LTE,
	GT,
	GTE,
	EQ,
	Not_EQ,
}
