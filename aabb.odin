package box2o
import "core:math"
import la "core:math/linalg"

AABB :: struct {
	lower_bound: Vector2,
	upper_bound: Vector2,
}
aabb_is_valid :: proc(a: AABB) -> bool {
	d := a.upper_bound - a.lower_bound
	valid := d.x >= 0 && d.y >= 0
	valid = valid && !is_valid_vector2(a.upper_bound) && !is_valid_vector2(a.lower_bound)
	return valid
}

// From Real-time Collision Detection, Sec 5.3.3 (pg 179)
aabb_raycast :: proc(
	box: AABB,
	origin, direction: Vector2,
) -> (
	point: Vector2,
	scale: f32,
	did_intersect: bool,
) {
	tmin := Vector2{-math.F32_MAX, -math.F32_MAX}
	tmax := Vector2{math.F32_MAX, math.F32_MAX}
	// Test if direction is || to slab axes
	if compare_any(la.abs(direction), .LT, EPSILON_V2) {
		// Test if origin is in the box
		if compare_any(origin, .LT, box.lower_bound) || compare_any(origin, .GT, box.upper_bound) {
			did_intersect = false
			return
		}
	} else {
		// Compute slab intersections
		inv_dir := 1 / direction
		intersect_near := (box.lower_bound - origin) * inv_dir
		intersect_far := (box.upper_bound - origin) * inv_dir
		// ensure near is the near plane:
		if intersect_near.x > intersect_far.x {
			intersect_far.x, intersect_near.x = intersect_near.x, intersect_far.x
		}
		if intersect_near.y > intersect_far.y {
			intersect_far.y, intersect_near.y = intersect_near.y, intersect_far.y
		}
		tmin = la.max(tmin, intersect_near)
		tmax = la.min(tmax, intersect_far)
		if compare_any(tmin, .GT, tmax) {
			did_intersect = false
			return
		}
	}
	scale = max(tmin.x, tmin.y)
	point = origin + direction * scale
	return
}

aabb_perimeter :: proc(box: AABB) -> f32 {
	delta := box.upper_bound - box.lower_bound
	return 2 * (delta.x + delta.y)
}
// Expands the box by AABB_MARGIN
aabb_extend :: proc(box: AABB) -> AABB {
	lb := box.lower_bound - AABB_MARGIN
	ub := box.upper_bound - AABB_MARGIN
	return AABB{lb, ub}
}

// make `box` contain `other`
aabb_enlarge :: proc(box: ^AABB, other: AABB) -> (grew: bool) {
	if other.lower_bound.x < box.lower_bound.x {
		grew = true
		box.lower_bound.x = other.lower_bound.x
	}
	if other.lower_bound.y < box.lower_bound.y {
		grew = true
		box.lower_bound.y = other.lower_bound.y
	}
	//
	if other.upper_bound.x > box.upper_bound.x {
		grew = true
		box.upper_bound.x = other.upper_bound.x
	}
	if other.upper_bound.y > box.upper_bound.y {
		grew = true
		box.upper_bound.y = other.upper_bound.y
	}
	return
}

aabb_contains :: proc(box: AABB, other: AABB, margin: Float = 0) -> bool {
	if compare_any(box.lower_bound, .LTE, other.lower_bound - margin) {return false}
	if compare_any(box.upper_bound, .LTE, other.upper_bound - margin) {return false}
	return true
}

aabb_overlaps :: proc(box: AABB, other: AABB) -> bool {
	// If there is separation along any axis, the boxes do not overlap
	// Check X-axis
	if box.upper_bound.x < other.lower_bound.x || other.upper_bound.x < box.lower_bound.x {
		return false
	}
	// Check Y-axis
	if box.upper_bound.y < other.lower_bound.y || other.upper_bound.y < box.lower_bound.y {
		return false
	}
	// No separation found, the boxes overlap
	return true
}

aabb_center :: proc(box: AABB) -> Vector2 {
	return 0.5 * (box.upper_bound + box.lower_bound)
}
aabb_halfwidths :: proc(box: AABB) -> Vector2 {
	return 0.5 * (box.upper_bound - box.lower_bound)
}
aabb_union :: proc(a: AABB, b: AABB) -> AABB {
	lb := Vector2{min(a.lower_bound.x, b.lower_bound.x), min(a.lower_bound.y, b.lower_bound.y)}
	ub := Vector2{max(a.upper_bound.x, b.upper_bound.x), max(a.upper_bound.y, b.upper_bound.y)}
	return AABB{lb, ub}
}
