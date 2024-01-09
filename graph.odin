package box2o

Overflow_Index :: GRAPH_COLOR_COUNT

Graph_Color :: struct {
	bodySet:            Bit_Set,
	contactArray:       ^i32,
	jointArray:         ^i32,
	// transient
	contactConstraints: ^Contact_Constraint_SIMD,
}

// This holds constraints that cannot fit the graph color limit. This happens when a single dynamic body
// is touching many other bodies.
Graph_Overflow :: struct {
	contactArray:       ^i32,
	jointArray:         ^i32,
	// transient
	contactConstraints: ^Contact_Constraint,
}

Graph :: struct {
	colors:     [GRAPH_COLOR_COUNT]Graph_Color,
	colorCount: i32,

	// debug info
	occupancy:  [GRAPH_COLOR_COUNT + 1]i32,
	overflow:   Graph_Overflow,
}

create_graph :: proc(
	graph: ^Graph,
	bodyCapacity: i32,
	contactCapacity: i32,
	jointCapacity: i32,
) {unimplemented()}
destroy_graph :: proc(graph: ^Graph) {unimplemented()}

add_contact_to_graph :: proc(world: ^World, contact: ^Contact) {unimplemented()}
remove_contact_from_graph :: proc(world: ^World, contact: ^Contact) {unimplemented()}

add_Joint_to_graph :: proc(world: ^World, joint: ^Joint) {unimplemented()}
remove_joint_from_graph :: proc(world: ^World, joint: ^Joint) {unimplemented()}

solve :: proc(world: ^World, step_context: ^Step_Context) {unimplemented()}
