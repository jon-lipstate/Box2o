package box2o


// Store the proxy type in the lower 4 bits of the proxy key. This leaves 28 bits for the id.
// #define _PROXY_TYPE(KEY) ((BodyType)((KEY)&0xF))
// #define _PROXY_ID(KEY) ((KEY) >> 4)
// #define _PROXY_KEY(ID, TYPE) (((ID) << 4) | (TYPE))

/// The broad-phase is used for computing pairs and performing volume queries and ray casts.
/// This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
/// It is up to the client to consume the new pairs and to track subsequent overlap.
Broad_Phase :: struct {
	trees:            [len(Body_Type)]Dynamic_Tree,
	proxyCount:       i32,
	// The move set and array are used to track shapes that have moved significantly
	// and need a pair query for new contacts. The array has a deterministic order.
	// TODO_ERIN perhaps just a move set?
	moveSet:          Hash_Set,
	moveArray:        ^i32,
	// These are the results from the pair query and are used to create new contacts
	// in deterministic order.
	moveResults:      ^Move_Result,
	movePairs:        ^Move_Pair,
	movePairCapacity: i32,
	movePairIndex:    Atomic_Int,
	pairSet:          Hash_Set,
}

create_broad_phase :: proc(bp: ^Broad_Phase)
destroy_broad_phase :: proc(bp: ^Broad_Phase)
broad_phase_create_proxy :: proc(
	bp: ^Broad_Phase,
	bodyType: Body_Type,
	aabb: AABB,
	categoryBits: u32,
	shapeIndex: i32,
) -> i32
broad_phase_destroy_proxy :: proc(bp: ^Broad_Phase, proxyKey: i32)
broad_phase_move_proxy :: proc(bp: ^Broad_Phase, proxyKey: i32, aabb: AABB)
broad_phase_enlarge_proxy :: proc(bp: ^Broad_Phase, proxyKey: i32, aabb: AABB)

broad_phase_rebuild_trees :: proc(bp: ^Broad_Phase)

broad_phase_get_shape_index :: proc(bp: ^Broad_Phase, proxyKey: i32) -> i32

update_broad_phase_pairs :: proc(world: ^World)
broad_phase_test_overlap :: proc(bp: ^Broad_Phase, proxyKeyA: i32, proxyKeyB: i32) -> bool

validate_broad_phase :: proc(bp: ^Broad_Phase)
validate_no_enlarged :: proc(bp: ^Broad_Phase)

// Warning: this must be called in deterministic order
buffer_move :: #force_inline proc(bp: ^Broad_Phase, proxyKey: i32) {
	unimplemented()
	// // Adding 1 because 0 is the sentinel
	// bool alreadyAdded = AddKey(&bp->moveSet, proxyKey + 1)
	// if (alreadyAdded == false)
	// {
	// 	Array_Push(bp->moveArray, proxyKey)
	// }
}
