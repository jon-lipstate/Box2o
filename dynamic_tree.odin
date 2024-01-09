package box2o


// #define _defaultCategoryBits (0x00000001)
// #define _defaultMaskBits (0xFFFFFFFF)

/// A node in the dynamic tree. The user does not interact with this directly.
/// 16 + 16 + 8 + pad(8)
Tree_Node :: struct {
	aabb:         AABB, // 16
	// Category bits for collision filtering
	categoryBits: u32, // 4
	using _:      struct #raw_union {
		parent: i32,
		next:   i32,
	}, // 4
	child1:       i32, // 4
	child2:       i32, // 4
	// todo could be union with child index
	userData:     i32, // 4
	// leaf = 0, free node = -1
	height:       i16, // 2
	enlarged:     bool, // 1
	pad:          [9]u8,
}

/// A dynamic AABB tree broad-phase, inspired by Nathanael Presson's btDbvt.
/// A dynamic tree arranges data in a binary tree to accelerate
/// queries such as AABB queries and ray casts. Leaf nodes are proxies
/// with an AABB. These are used to hold a user collision object, such as a reference to a Shape.
/// Nodes are pooled and relocatable, so I use node indices rather than pointers.
///	The dynamic tree is made available for advanced users that would like to use it to organize
///	spatial game data besides rigid bodies.
Dynamic_Tree :: struct {
	nodes:           ^Tree_Node,
	root:            i32,
	nodeCount:       i32,
	nodeCapacity:    i32,
	freeList:        i32,
	proxyCount:      i32,
	leafIndices:     ^i32,
	leafBoxes:       AABB,
	leafCenters:     ^Vector2,
	binIndices:      ^i32,
	rebuildCapacity: i32,
}

/// Constructing the tree initializes the node pool.
Dynamic_Tree_Create :: proc() -> Dynamic_Tree

/// Destroy the tree, freeing the node pool.
Dynamic_Tree_Destroy :: proc(tree: ^Dynamic_Tree)

/// Create a proxy. Provide a tight fitting AABB and a userData value.
Dynamic_Tree_CreateProxy :: proc(
	tree: ^Dynamic_Tree,
	aabb: AABB,
	categoryBits: u32,
	userData: i32,
) -> i32

/// Destroy a proxy. This asserts if the id is invalid.
Dynamic_Tree_DestroyProxy :: proc(tree: ^Dynamic_Tree, proxyId: i32)

// Clone one tree to another, reusing storage in the outTree if possible
Dynamic_Tree_Clone :: proc(outTree: ^Dynamic_Tree, inTree: ^Dynamic_Tree)

/// Move a proxy to a new AABB by removing and reinserting into the tree.
Dynamic_Tree_MoveProxy :: proc(tree: ^Dynamic_Tree, proxyId: i32, aabb: AABB)

/// Enlarge a proxy and enlarge ancestors as necessary.
Dynamic_Tree_EnlargeProxy :: proc(tree: ^Dynamic_Tree, proxyId: i32, aabb: AABB)

/// This function receives proxies found in the AABB query.
/// @return true if the query should continue
tree_query_callback_proc :: #type proc(proxyId: i32, userData: i32, ctx: rawptr) -> bool

/// Query an AABB for overlapping proxies. The callback class
/// is called for each proxy that overlaps the supplied AABB.
Dynamic_Tree_QueryFiltered :: proc(
	tree: ^Dynamic_Tree,
	aabb: AABB,
	maskBits: u32,
	callback: ^tree_query_callback_proc,
	ctx: rawptr,
)

/// Query an AABB for overlapping proxies. The callback class
/// is called for each proxy that overlaps the supplied AABB.
Dynamic_Tree_Query :: proc(
	tree: ^Dynamic_Tree,
	aabb: AABB,
	callback: ^tree_query_callback_proc,
	ctx: rawptr,
)

/// This function receives clipped raycast input for a proxy. The function
/// returns the new ray fraction.
/// - return a value of 0 to terminate the ray cast
/// - return a value less than input.maxFraction to clip the ray
/// - return a value of input.maxFraction to continue the ray cast without clipping
tree_raycast_callback_proc :: #type proc(
	input: ^RayCast_Input,
	proxyId: i32,
	userData: i32,
	ctx: rawptr,
) -> float

/// Ray-cast against the proxies in the tree. This relies on the callback
/// to perform a exact ray-cast in the case were the proxy contains a shape.
/// The callback also performs the any collision filtering. This has performance
/// roughly equal to k * log(n), where k is the number of collisions and n is the
/// number of proxies in the tree.
/// @param input the ray-cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1).
/// @param callback a callback class that is called for each proxy that is hit by the ray.
Dynamic_Tree_RayCast :: proc(
	tree: ^Dynamic_Tree,
	input: ^RayCast_Input,
	maskBits: u32,
	callback: ^tree_raycast_callback_proc,
	ctx: rawptr,
)

/// This function receives clipped raycast input for a proxy. The function
/// returns the new ray fraction.
/// - return a value of 0 to terminate the ray cast
/// - return a value less than input.maxFraction to clip the ray
/// - return a value of input.maxFraction to continue the ray cast without clipping
tree_shapecast_callback_proc :: #type proc(
	input: ^ShapeCastInput,
	proxyId: i32,
	userData: i32,
	ctx: rawptr,
) -> float

/// Ray-cast against the proxies in the tree. This relies on the callback
/// to perform a exact ray-cast in the case were the proxy contains a shape.
/// The callback also performs the any collision filtering. This has performance
/// roughly equal to k * log(n), where k is the number of collisions and n is the
/// number of proxies in the tree.
/// @param input the ray-cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1).
/// @param callback a callback class that is called for each proxy that is hit by the ray.
Dynamic_Tree_ShapeCast :: proc(
	tree: ^Dynamic_Tree,
	input: ^ShapeCastInput,
	maskBits: u32,
	callback: ^tree_shapecast_callback_proc,
	ctx: rawptr,
)

/// Validate this tree. For testing.
Dynamic_Tree_Validate :: proc(tree: ^Dynamic_Tree)

/// Compute the height of the binary tree in O(N) time. Should not be
/// called often.
Dynamic_Tree_GetHeight :: proc(tree: ^Dynamic_Tree) -> i32

/// Get the maximum balance of the tree. The balance is the difference in height of the two children of a node.
Dynamic_Tree_GetMaxBalance :: proc(tree: ^Dynamic_Tree) -> i32

/// Get the ratio of the sum of the node areas to the root area.
Dynamic_Tree_GetAreaRatio :: proc(tree: ^Dynamic_Tree) -> float

/// Build an optimal tree. Very expensive. For testing.
Dynamic_Tree_RebuildBottomUp :: proc(tree: ^Dynamic_Tree)

/// Get the number of proxies created
Dynamic_Tree_GetProxyCount :: proc(tree: ^Dynamic_Tree) -> i32

/// Rebuild the tree while retaining subtrees that haven't changed. Returns the number of boxes sorted.
Dynamic_Tree_Rebuild :: proc(tree: ^Dynamic_Tree, fullBuild: bool) -> i32

/// Shift the world origin. Useful for large worlds.
/// The shift formula is: position -= newOrigin
/// @param newOrigin the new origin with respect to the old origin
Dynamic_Tree_ShiftOrigin :: proc(tree: ^Dynamic_Tree, newOrigin: Vector2)

/// Get proxy user data
/// @return the proxy user data or 0 if the id is invalid
Dynamic_Tree_GetUserData :: #force_inline proc(tree: ^Dynamic_Tree, proxyId: i32) -> i32 {
	return tree.nodes[proxyId].userData
}

/// Get the AABB of a proxy
Dynamic_Tree_GetAABB :: #force_inline proc(tree: ^Dynamic_Tree, proxyId: i32) -> AABB {
	return tree.nodes[proxyId].aabb
}
