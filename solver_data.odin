package box2o
// Context for a time step. Recreated each time step.
Step_Context :: struct {
	// time step
	dt:                   Float,
	// inverse time step (0 if dt == 0).
	inv_dt:               Float,
	// TODO_ERIN eliminate support for variable time step
	// ratio between current and previous time step (dt * inv_dt0)
	dtRatio:              Float,
	// Velocity iterations for constraint solver. Controls the accuracy of internal forces.
	velocityIterations:   i32,
	// Relax iterations for constraint solver. Reduces constraint bounce.
	relaxIterations:      i32,
	restitutionThreshold: Float,
	// TODO_ERIN for joints
	bodies:               ^Body,
	bodyCapacity:         i32,
	// Map from world body pool index to solver body
	bodyToSolverMap:      ^i32,
	// Map from solver body to world body
	solverToBodyMap:      ^i32,
	solverBodies:         ^Solver_Body,
	solverBodyCount:      i32,
	enableWarmStarting:   bool,
}

Solver_Stage_Type :: enum {
	stageIntegrateVelocities,
	stagePrepareJoints,
	stagePrepareContacts,
	stageWarmStart,
	stageSolve,
	stageIntegratePositions,
	stageRelax,
	stageRestitution,
	stageStoreImpulses,
}

Solver_Block_Type :: enum {
	bodyBlock,
	jointBlock,
	contactBlock,
	graphJointBlock,
	graphContactBlock,
}

// Each block of work has a sync index that gets incremented when a worker claims the block. This ensures only a single worker claims a
// block, yet lets work be distributed dynamically across multiple workers (work stealing). This also reduces contention on a single block
// index atomic. For non-iterative stages the sync index is simply set to one. For iterative stages (solver iteration) the same block of
// work is executed once per iteration and the atomic sync index is shared across iterations, so it increases monotonically.
Solver_Block :: struct {
	startIndex: i32,
	count:      i16,
	blockType:  i16, // SolverBlockType
	syncIndex:  Atomic_Int,
}

// Each stage must be completed before going to the next stage.
// Non-iterative stages use a stage instance once while iterative stages re-use the same instance each iteration.
Solver_Stage :: struct {
	type:            Solver_Stage_Type,
	blocks:          ^Solver_Block,
	blockCount:      i32,
	colorIndex:      i32,
	completionCount: Atomic_Int,
}

// TODO_ERIN combine with StepContext
Solver_Task_Context :: struct {
	world:               ^World,
	graph:               ^Graph,
	awakeBodies:         ^^Body,
	solverBodies:        ^Solver_Body,
	bodyToSolverMap:     ^i32,
	solverToBodyMap:     ^i32,
	jointIndices:        ^i32,
	contactIndices:      ^i32,
	stepContext:         ^Step_Context,
	contactConstraints:  ^Contact_Constraint_SIMD,
	active_color_count:  i32,
	velocity_iterations: i32,
	relax_iterations:    i32,
	worker_count:        i32,
	timestep:            Float,
	inv_timestep:        Float,
	sub_step:            Float,
	inv_substep:         Float,
	stages:              ^Solver_Stage,
	stage_count:         i32,

	// sync index (16-bits) | stage type (16-bits)
	sync_bits:           Atomic_UInt,
}
