package box2o
// Deterministic solver
//
// Collide all awake contacts
// Use bit array to emit start/stop touching events in defined order, per thread. Try using contact index, assuming contacts are created in
// a deterministic order. bit-wise OR together bit arrays and issue changes:
// - start touching: merge islands - temporary linked list - mark root island dirty - wake all - largest island is root
// - stop touching: mark island dirty - wake island
// Reserve island jobs
// - island job does a DFS to merge/split islands. Mutex to allocate new islands. Split islands sent to different jobs.

// Persistent island
// https://en.wikipedia.org/wiki/Component_(graph_theory)
// https://en.wikipedia.org/wiki/Dynamic_connectivity
Island :: struct {
	object:                  Object,
	world:                   ^World,
	head_body:               i32,
	tail_body:               i32,
	body_count:              i32,
	head_contact:            i32,
	tail_contact:            i32,
	contact_count:           i32,
	head_joint:              i32,
	tail_joint:              i32,
	joint_count:             i32,

	// Union find
	parent_island:           i32,

	// Index into world awake island array, NULL_INDEX if the island is sleeping
	awake_index:             i32,

	// Keeps track of how many contacts have been removed from this island.
	constraint_remove_count: i32,
}

create_island :: proc(island: ^Island) {unimplemented()}
destroy_island :: proc(island: ^Island) {unimplemented()}

wake_island :: proc(island: ^Island) {unimplemented()}

// Link contacts into the island graph when it starts having contact points
link_contact :: proc(world: ^World, contact: ^Contact) {unimplemented()}

// Unlink contact from the island graph when it stops having contact points
unlink_contact :: proc(world: ^World, contact: ^Contact) {unimplemented()}

// Link a joint into the island graph when it is created
link_joint :: proc(world: ^World, joint: ^Joint) {unimplemented()}

// Unlink a joint from the island graph when it is destroyed
unlink_joint :: proc(world: ^World, joint: ^Joint) {unimplemented()}

merge_awake_islands :: proc(world: ^World) {unimplemented()}

split_island_task :: proc(
	startIndex: i32,
	endIndex: i32,
	threadIndex: u32,
	ctx: rawptr,
) {unimplemented()}
complete_split_island :: proc(island: ^Island) {unimplemented()}

validate_island :: proc(island: ^Island, checkSleep: bool) {unimplemented()}
