package box2o


/// A joint edge is used to connect bodies and joints together
/// in a joint graph where each body is a node and each joint
/// is an edge. A joint edge belongs to a doubly linked list
/// maintained in each attached body. Each joint has two joint
/// nodes, one for each attached body.
Joint_Edge :: struct {
	bodyIndex: i32,
	prevKey:   i32,
	nextKey:   i32,
}

Distance_Joint :: struct {
	hertz:                    Float,
	dampingRatio:             Float,
	length:                   Float,
	minLength:                Float,
	maxLength:                Float,

	// Solver shared
	impulse:                  Float,
	lowerImpulse:             Float,
	upperImpulse:             Float,

	// Solver temp
	indexA:                   i32,
	indexB:                   i32,
	rA:                       Vector2,
	rB:                       Vector2,
	separation:               Vector2,
	springBiasCoefficient:    Float,
	springMassCoefficient:    Float,
	springImpulseCoefficient: Float,
	limitBiasCoefficient:     Float,
	limitMassCoefficient:     Float,
	limitImpulseCoefficient:  Float,
	axialMass:                Float,
}

MotorJoint :: struct {
	// Solver shared
	linearOffset:      Vector2,
	angularOffset:     Float,
	linearImpulse:     Vector2,
	angularImpulse:    Float,
	maxForce:          Float,
	maxTorque:         Float,
	correctionFactor:  Float,

	// Solver temp
	indexA:            i32,
	indexB:            i32,
	rA:                Vector2,
	rB:                Vector2,
	linearSeparation:  Vector2,
	angularSeparation: Float,
	linearMass:        matrix[2, 2]Float,
	angularMass:       Float,
}

MouseJoint :: struct {
	targetA:      Vector2,
	stiffness:    Float,
	damping:      Float,
	beta:         Float,

	// Solver shared
	impulse:      Vector2,
	maxForce:     Float,
	gamma:        Float,

	// Solver temp
	indexB:       i32,
	positionB:    Vector2,
	rB:           Vector2,
	localCenterB: Vector2,
	mass:         matrix[2, 2]Float,
	C:            Vector2,
}

PrismaticJoint :: struct {
	// Solver shared
	localAxisA:         Vector2,
	impulse:            Vector2,
	motorImpulse:       Float,
	lowerImpulse:       Float,
	upperImpulse:       Float,
	enableMotor:        bool,
	maxMotorForce:      Float,
	motorSpeed:         Float,
	enableLimit:        bool,
	referenceAngle:     Float,
	lowerTranslation:   Float,
	upperTranslation:   Float,

	// Solver temp
	indexA:             i32,
	indexB:             i32,
	rA:                 Vector2,
	rB:                 Vector2,
	axisA:              Vector2,
	pivotSeparation:    Vector2,
	angleSeparation:    Float,
	pivotMass:          matrix[2, 2]Float,
	axialMass:          Float,
	biasCoefficient:    Float,
	massCoefficient:    Float,
	impulseCoefficient: Float,
}

RevoluteJoint :: struct {
	// Solver shared
	linearImpulse:           Vector2,
	motorImpulse:            Float,
	lowerImpulse:            Float,
	upperImpulse:            Float,
	enableMotor:             bool,
	maxMotorTorque:          Float,
	motorSpeed:              Float,
	enableLimit:             bool,
	referenceAngle:          Float,
	lowerAngle:              Float,
	upperAngle:              Float,

	// Solver temp
	indexA:                  i32,
	indexB:                  i32,
	angleA:                  Float,
	angleB:                  Float,
	rA:                      Vector2,
	rB:                      Vector2,
	separation:              Vector2,
	pivotMass:               matrix[2, 2]Float,
	limitBiasCoefficient:    Float,
	limitMassCoefficient:    Float,
	limitImpulseCoefficient: Float,
	biasCoefficient:         Float,
	massCoefficient:         Float,
	impulseCoefficient:      Float,
	axialMass:               Float,
}

WeldJoint :: struct {
	// Solver shared
	referenceAngle:            Float,
	linearHertz:               Float,
	linearDampingRatio:        Float,
	angularHertz:              Float,
	angularDampingRatio:       Float,
	linearBiasCoefficient:     Float,
	linearMassCoefficient:     Float,
	linearImpulseCoefficient:  Float,
	angularBiasCoefficient:    Float,
	angularMassCoefficient:    Float,
	angularImpulseCoefficient: Float,
	linearImpulse:             Vector2,
	angularImpulse:            Float,

	// Solver temp
	indexA:                    i32,
	indexB:                    i32,
	rA:                        Vector2,
	rB:                        Vector2,
	linearSeparation:          Vector2,
	angularSeparation:         Float,
	pivotMass:                 matrix[2, 2]Float,
	axialMass:                 Float,
}

WheelJoint :: struct {
	// Solver shared
	localAxisA:         Vector2,
	perpImpulse:        Float,
	motorImpulse:       Float,
	springImpulse:      Float,
	lowerImpulse:       Float,
	upperImpulse:       Float,
	maxMotorTorque:     Float,
	motorSpeed:         Float,
	lowerTranslation:   Float,
	upperTranslation:   Float,
	stiffness:          Float,
	damping:            Float,
	enableMotor:        bool,
	enableLimit:        bool,

	// Solver temp
	indexA:             i32,
	indexB:             i32,
	rA:                 Vector2,
	rB:                 Vector2,
	axisA:              Vector2,
	pivotSeparation:    Vector2,
	perpMass:           Float,
	motorMass:          Float,
	axialMass:          Float,
	springMass:         Float,
	bias:               Float,
	gamma:              Float,
	biasCoefficient:    Float,
	massCoefficient:    Float,
	impulseCoefficient: Float,
}

/// The base joint class. Joints are used to constraint two bodies together in
/// various fashions. Some joints also feature limits and motors.
Joint :: struct {
	object:           Object,
	type:             Joint_Type,
	edges:            [2]Joint_Edge,
	islandIndex:      i32,
	islandPrev:       i32,
	islandNext:       i32,

	// The color of this constraint in the graph coloring
	colorIndex:       i32,

	// Index of joint within color
	colorSubIndex:    i32,
	localAnchorA:     Vector2,
	localAnchorB:     Vector2,
	using _:          struct #raw_union {
		distanceJoint:  Distance_Joint,
		motorJoint:     MotorJoint,
		mouseJoint:     MouseJoint,
		revoluteJoint:  RevoluteJoint,
		prismaticJoint: PrismaticJoint,
		weldJoint:      WeldJoint,
		wheelJoint:     WheelJoint,
	},
	drawSize:         Float,
	isMarked:         bool,
	collideConnected: bool,
}

GetJoint :: proc(world: ^World, jointId: Joint_Id) -> ^Joint {unimplemented()}

// todo remove this
GetJointCheckType :: proc(id: Joint_Id, type: Joint_Type) -> ^Joint {unimplemented()}

PrepareJoint :: proc(joint: ^Joint, ctx: ^Step_Context) {unimplemented()}
WarmStartJoint :: proc(joint: ^Joint, ctx: ^Step_Context) {unimplemented()}
SolveJoint :: proc(joint: ^Joint, ctx: ^Step_Context, useBias: bool) {unimplemented()}

PrepareAndWarmStartOverflowJoints :: proc(ctx: ^SolverTaskContext) {unimplemented()}
SolveOverflowJoints :: proc(ctx: ^SolverTaskContext, useBias: bool) {unimplemented()}

DrawJoint :: proc(draw: ^DebugDraw, world: ^World, joint: ^Joint) {unimplemented()}
