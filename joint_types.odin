package box2o


Joint_Type :: enum {
	Distance,
	Motor,
	Mouse,
	Prismatic,
	Revolute,
	Weld,
	Wheel,
}

/// Distance joint definition. This requires defining an anchor point on both
/// bodies and the non-zero distance of the distance joint. The definition uses
/// local anchor points so that the initial configuration can violate the
/// constraint slightly. This helps when saving and loading a game.
DistanceJointDef :: struct {
	/// The first attached body.
	bodyIdA:          Body_Id,
	/// The second attached body.
	bodyIdB:          Body_Id,
	/// The local anchor point relative to bodyA's origin.
	localAnchorA:     Vector2,
	/// The local anchor point relative to bodyB's origin.
	localAnchorB:     Vector2,
	/// The rest length of this joint. Clamped to a stable minimum value.
	length:           Float,
	/// Minimum length. Clamped to a stable minimum value.
	minLength:        Float,
	/// Maximum length. Must be greater than or equal to the minimum length.
	maxLength:        Float,
	/// The linear stiffness hertz (cycles per second)
	hertz:            Float,
	/// The linear damping ratio (non-dimensional)
	dampingRatio:     Float,
	/// Set this flag to true if the attached bodies should collide.
	collideConnected: bool,
}

/// Use this to initialize your joint definition
DEFAULT_DISTANCE_JOINT_DEF := DistanceJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // localAnchorA
	{0.0, 0.0}, // localAnchorB
	1.0, // length
	0.0, // minLength
	HUGE_NUMBER, // maxLength
	0.0, // hertz
	0.0, // dampingRatio
	false, // collideConnected
}

/// A motor joint is used to control the relative motion
/// between two bodies. A typical usage is to control the movement
/// of a dynamic body with respect to the ground.
MotorJointDef :: struct {
	/// The first attached body.
	bodyIdA:          Body_Id,
	/// The second attached body.
	bodyIdB:          Body_Id,
	/// Position of bodyB minus the position of bodyA, in bodyA's frame, in meters.
	linearOffset:     Vector2,
	/// The bodyB angle minus bodyA angle in radians.
	angularOffset:    Float,
	/// The maximum motor force in N.
	maxForce:         Float,
	/// The maximum motor torque in N-m.
	maxTorque:        Float,
	/// Position correction factor in the range [0,1].
	correctionFactor: Float,
}

/// Use this to initialize your joint definition
DEFAULT_MOTOR_JOINT_DEF := MotorJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // linearOffset
	0.0, // angularOffset
	1.0, // maxForce
	1.0, // maxTorque
	0.3, // correctionFactor
}

/// A mouse joint is used to make a point on a body track a
/// specified world point. This a soft constraint with a maximum
/// force. This allows the constraint to stretch without
/// applying huge forces.
MouseJointDef :: struct {
	/// The first attached body.
	bodyIdA:   Body_Id,

	/// The second attached body.
	bodyIdB:   Body_Id,

	/// The initial target point in world space
	target:    Vector2,

	/// The maximum constraint force that can be exerted
	/// to move the candidate body. Usually you will express
	/// as some multiple of the weight (multiplier * mass * gravity).
	maxForce:  Float,

	/// The linear stiffness in N/m
	stiffness: Float,

	/// The linear damping in N*s/m
	damping:   Float,
}

/// Use this to initialize your joint definition
DEFAULT_MOUSE_JOINT_DEF := MouseJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // target
	0.0, // maxForce
	0.0, // stiffness
	0.0, // damping
}
/// Prismatic joint definition. This requires defining a line of
/// motion using an axis and an anchor point. The definition uses local
/// anchor points and a local axis so that the initial configuration
/// can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space.
PrismaticJointDef :: struct {
	/// The first attached body.
	bodyIdA:          Body_Id,
	/// The second attached body.
	bodyIdB:          Body_Id,
	/// The local anchor point relative to bodyA's origin.
	localAnchorA:     Vector2,
	/// The local anchor point relative to bodyB's origin.
	localAnchorB:     Vector2,
	/// The local translation unit axis in bodyA.
	localAxisA:       Vector2,
	/// The constrained angle between the bodies: bodyB_angle - bodyA_angle.
	referenceAngle:   Float,
	/// Enable/disable the joint limit.
	enableLimit:      bool,
	/// The lower translation limit, usually in meters.
	lowerTranslation: Float,
	/// The upper translation limit, usually in meters.
	upperTranslation: Float,
	/// Enable/disable the joint motor.
	enableMotor:      bool,
	/// The maximum motor force, usually in N.
	maxMotorForce:    Float,
	/// The desired motor speed in radians per second.
	motorSpeed:       Float,
	/// Set this flag to true if the attached bodies should collide.
	collideConnected: bool,
}

/// Use this to initialize your joint definition
DEFAULT_PRISMATIC_JOINT_DEF := PrismaticJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // localAnchorA
	{0.0, 0.0}, // localAnchorB
	{1.0, 0.0}, // localAxisA
	0.0, // referenceAngle
	false, // enableLimit
	0.0, // lowerTranslation
	0.0, // upperTranslation
	false, // enableMotor
	0.0, // maxMotorForce
	0.0, // motorSpeed
	false, // collideConnected
}

/// Revolute joint definition. This requires defining an anchor point where the
/// bodies are joined. The definition uses local anchor points so that the
/// initial configuration can violate the constraint slightly. You also need to
/// specify the initial relative angle for joint limits. This helps when saving
/// and loading a game.
/// The local anchor points are measured from the body's origin
/// rather than the center of mass because:
/// 1. you might not know where the center of mass will be.
/// 2. if you add/remove shapes from a body and recompute the mass,
///    the joints will be broken.
RevoluteJointDef :: struct {
	/// The first attached body.
	bodyIdA:          Body_Id,
	/// The second attached body.
	bodyIdB:          Body_Id,
	/// The local anchor point relative to bodyA's origin.
	localAnchorA:     Vector2,
	/// The local anchor point relative to bodyB's origin.
	localAnchorB:     Vector2,
	/// The bodyB angle minus bodyA angle in the reference state (radians).
	/// This defines the zero angle for the joint limit.
	referenceAngle:   Float,
	/// A flag to enable joint limits.
	enableLimit:      bool,
	/// The lower angle for the joint limit (radians).
	lowerAngle:       Float,
	/// The upper angle for the joint limit (radians).
	upperAngle:       Float,
	/// A flag to enable the joint motor.
	enableMotor:      bool,
	/// The maximum motor torque used to achieve the desired motor speed.
	/// Usually in N-m.
	maxMotorTorque:   Float,
	/// The desired motor speed. Usually in radians per second.
	motorSpeed:       Float,
	/// Scale the debug draw
	drawSize:         Float,
	/// Set this flag to true if the attached bodies should collide.
	collideConnected: bool,
}

/// Use this to initialize your joint definition
DEFAULT_REVOLUTE_JOINT_DEF := RevoluteJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // localAnchorA
	{0.0, 0.0}, // localAnchorB
	0.0, // referenceAngle
	false, // enableLimit
	0.0, // lowerAngle
	0.0, // upperAngle
	false, // enableMotor
	0.0, // maxMotorTorque
	0.0, // motorSpeed
	0.25, // drawSize
	false, // collideConnected
}

/// A weld joint connect to bodies together rigidly. This constraint can be made soft to mimic
///	soft-body simulation.
/// @warning the approximate solver in Box2D cannot hold many bodies together rigidly
WeldJointDef :: struct {
	/// The first attached body.
	bodyIdA:             Body_Id,
	/// The second attached body.
	bodyIdB:             Body_Id,
	/// The local anchor point relative to bodyA's origin.
	localAnchorA:        Vector2,
	/// The local anchor point relative to bodyB's origin.
	localAnchorB:        Vector2,
	/// The bodyB angle minus bodyA angle in the reference state (radians).
	referenceAngle:      Float,
	/// Linear stiffness expressed as hertz (oscillations per second). Use zero for maximum stiffness.
	linearHertz:         Float,
	/// Angular stiffness as hertz (oscillations per second). Use zero for maximum stiffness.
	angularHertz:        Float,
	/// Linear damping ratio, non-dimensional. Use 1 for critical damping.
	linearDampingRatio:  Float,
	/// Linear damping ratio, non-dimensional. Use 1 for critical damping.
	angularDampingRatio: Float,
	/// Set this flag to true if the attached bodies should collide.
	collideConnected:    bool,
}

/// Use this to initialize your joint definition
DEFAULT_WELD_JOINT_DEF := WeldJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // localAnchorA
	{0.0, 0.0}, // localAnchorB,
	0.0, // referenceAngle
	0.0, // linearHertz
	0.0, // angularHertz
	1.0, // linearDampingRatio
	1.0, // angularDampingRatio
	false, // collideConnected
}

/// Wheel joint definition. This requires defining a line of
/// motion using an axis and an anchor point. The definition uses local
/// anchor points and a local axis so that the initial configuration
/// can violate the constraint slightly. The joint translation is zero
/// when the local anchor points coincide in world space. Using local
/// anchors and a local axis helps when saving and loading a game.
WheelJointDef :: struct {
	/// The first attached body.
	bodyIdA:          Body_Id,
	/// The second attached body.
	bodyIdB:          Body_Id,
	/// The local anchor point relative to bodyA's origin.
	localAnchorA:     Vector2,
	/// The local anchor point relative to bodyB's origin.
	localAnchorB:     Vector2,
	/// The local translation unit axis in bodyA.
	localAxisA:       Vector2,
	/// Enable/disable the joint limit.
	enableLimit:      bool,
	/// The lower translation limit, usually in meters.
	lowerTranslation: Float,
	/// The upper translation limit, usually in meters.
	upperTranslation: Float,
	/// Enable/disable the joint motor.
	enableMotor:      bool,
	/// The maximum motor torque, usually in N-m.
	maxMotorTorque:   Float,
	/// The desired motor speed in radians per second.
	motorSpeed:       Float,
	/// The linear stiffness in N/m
	stiffness:        Float,
	/// The linear damping in N*s/m
	damping:          Float,
	/// Set this flag to true if the attached bodies should collide.
	collideConnected: bool,
}

/// Use this to initialize your joint definition
DEFAULT_WHEEL_JOINT_DEF := WheelJointDef {
	NULL_BODY_ID, // bodyIdA
	NULL_BODY_ID, // bodyIdB
	{0.0, 0.0}, // localAnchorA
	{0.0, 0.0}, // localAnchorB
	{1.0, 0.0}, // localAxisA
	false, // enableLimit
	0.0, // lowerTranslation
	0.0, // upperTranslation
	false, // enableMotor
	0.0, // maxMotorTorque
	0.0, // motorSpeed
	0.0, // stiffness
	0.0, // damping
	false, // collideConnected
}
