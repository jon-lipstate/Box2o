package box2o

/// Utility to compute linear stiffness values from frequency and damping ratio
linear_stiffness :: proc(
	stiffness: ^Float,
	damping: ^Float,
	frequency_hertz: Float,
	damping_ratio: Float,
	body_a: Body_Id,
	body_b: Body_Id,
)

/// Utility to compute angular stiffness values from frequency and damping ratio
angular_stiffness :: proc(
	stiffness: ^Float,
	damping: ^Float,
	frequency_hertz: Float,
	damping_ratio: Float,
	body_a: Body_Id,
	body_b: Body_Id,
)
