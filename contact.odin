package box2o

Contact_Edge :: struct {
	body_index: i32,
	prev_key:   i32,
	next_key:   i32,
}
Contact_Flags :: enum {
	// Set when the shapes are touching.
	Touching             = 0x00000002,
	// One of the shapes is a sensor
	Sensor               = 0x00000010,
	// This contact no longer has overlapping AABBs
	Disjoint             = 0x00000020,
	// This contact started touching
	StartedTouching      = 0x00000040,
	// This contact stopped touching
	StoppedTouching      = 0x00000080,
	// This contact wants sensor events
	EnableSensorEvents   = 0x00000100,
	// This contact wants contact events
	EnableContactEvents  = 0x00000200,
	// This contact wants presolve events
	EnablePreSolveEvents = 0x00000400,
}

/// The class manages contact between two shapes. A contact exists for each overlapping
/// AABB in the broad-phase (except if filtered). Therefore a contact object may exist
/// that has no contact points.
Contact :: struct {
	object:        Object,
	flags:         u32,
	// The color of this constraint in the graph coloring
	colorIndex:    i32,
	// Index of contact within color
	colorSubIndex: i32,
	edges:         [2]Contact_Edge,
	shapeIndexA:   i32,
	shapeIndexB:   i32,
	cache:         Distance_Cache,
	manifold:      Manifold,
	// A contact only belongs to an island if touching, otherwise B2_NULL_INDEX.
	islandPrev:    i32,
	islandNext:    i32,
	islandIndex:   i32,
	// Mixed friction and restitution
	friction:      Float,
	restitution:   Float,
	// For conveyor belts
	tangentSpeed:  Float,
	isMarked:      bool,
}

initialize_contact_registers :: proc() {unimplemented()}

create_contact :: proc(world: ^World, shapeA: ^Shape, shapeB: ^Shape) {unimplemented()}
destroy_contact :: proc(world: ^World, contact: ^Contact) {unimplemented()}

should_shapes_collide :: proc(filterA: Filter, filterB: Filter) -> bool {unimplemented()}

update_contact :: proc(
	world: ^World,
	contact: ^Contact,
	shapeA: ^Shape,
	bodyA: ^Body,
	shapeB: ^Shape,
	bodyB: ^Body,
) {unimplemented()}
