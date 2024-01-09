package box2o
import "core:simd"
Contact_Constraint_Point :: struct {
	rA:               Vector2,
	rB:               Vector2,
	separation:       Float,
	relativeVelocity: Float,
	normalImpulse:    Float,
	tangentImpulse:   Float,
	normalMass:       Float,
	tangentMass:      Float,
}

Contact_Constraint :: struct {
	contact:            Contact,
	indexA:             i32,
	indexB:             i32,
	points:             [2]Contact_Constraint_Point,
	normal:             Vector2,
	friction:           Float,
	restitution:        Float,
	massCoefficient:    Float,
	biasCoefficient:    Float,
	impulseCoefficient: Float,
	pointCount:         i32,
}

FloatW :: simd.f32x8
Vector2W :: struct {
	X: FloatW,
	Y: FloatW,
}

Contact_Constraint_SIMD :: struct {
	indexA:             [8]i32,
	indexB:             [8]i32,
	normal:             Vector2W,
	friction:           FloatW,
	restitution:        FloatW,
	rA1:                Vector2W,
	rB1:                Vector2W,
	rA2:                Vector2W,
	r:                  Vector2W,
	separation1:        FloatW,
	separation2:        FloatW,
	relativeVelocity1:  FloatW,
	relativeVelocity2:  FloatW,
	normalImpulse1:     FloatW,
	normalImpulse2:     FloatW,
	tangentImpulse1:    FloatW,
	tangentImpulse2:    FloatW,
	normalMass1:        FloatW,
	tangentMass1:       FloatW,
	normalMass2:        FloatW,
	tangentMass2:       FloatW,
	massCoefficient:    FloatW,
	biasCoefficient:    FloatW,
	impulseCoefficient: FloatW,
}

// Scalar
Prepare_And_Warm_Start_Overflow_Contacts :: proc(ctx: ^Solver_Task_Context) {unimplemented()}
Solve_Overflow_Contacts :: proc(ctx: ^Solver_Task_Context, useBias: bool) {unimplemented()}
Apply_Overflow_Restitution :: proc(ctx: ^Solver_Task_Context) {unimplemented()}
Store_Overflow_Impulses :: proc(ctx: ^Solver_Task_Context) {unimplemented()}

// AVX versions
Prepare_Contacts_SIMD :: proc(
	startIndex: i32,
	endIndex: i32,
	ctx: ^Solver_Task_Context,
) {unimplemented()}
Warm_Start_Contacts_SIMD :: proc(
	startIndex: i32,
	endIndex: i32,
	ctx: ^Solver_Task_Context,
	colorIndex: i32,
) {unimplemented()}
Solve_Contacts_SIMD :: proc(
	startIndex: i32,
	endIndex: i32,
	ctx: ^Solver_Task_Context,
	colorIndex: i32,
	useBias: bool,
) {unimplemented()}
Apply_Restitution_SIMD :: proc(
	startIndex: i32,
	endIndex: i32,
	ctx: ^Solver_Task_Context,
	colorIndex: i32,
) {unimplemented()}
Store_Impulses_SIMD :: proc(
	startIndex: i32,
	endIndex: i32,
	ctx: ^Solver_Task_Context,
) {unimplemented()}
