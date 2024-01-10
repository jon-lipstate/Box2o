package box2o

Shape :: struct {
	object:               Object,
	bodyIndex:            i32,
	nextShapeIndex:       i32,
	type:                 Shape_Type,
	density:              Float,
	friction:             Float,
	restitution:          Float,
	aabb:                 AABB,
	fatAABB:              AABB,
	localCentroid:        Vector2,
	proxyKey:             i32,
	filter:               Filter,
	userData:             rawptr,
	isSensor:             bool,
	enableSensorEvents:   bool,
	enableContactEvents:  bool,
	enablePreSolveEvents: bool,
	enlargedAABB:         bool,
	isFast:               bool,

	// TODO_ERIN maybe not anonymous, check asm
	using _:              struct #raw_union {
		capsule:       Capsule,
		circle:        Circle,
		polygon:       Polygon,
		segment:       Segment,
		smoothSegment: Smooth_Segment,
	},
}

Chain_Shape :: struct {
	object:       Object,
	bodyIndex:    i32,
	nextIndex:    i32,
	shapeIndices: [^]i32,
	count:        i32,
}

Shape_Extent :: struct {
	minExtent: Float,
	maxExtent: Float,
}

Create_Shape_Proxy :: proc(
	shape: ^Shape,
	bp: ^Broad_Phase,
	type: Body_Type,
	xf: Transform,
) {unimplemented()}
Destroy_Shape_Proxy :: proc(shape: ^Shape, bp: ^Broad_Phase) {unimplemented()}

Compute_Shape_Mass :: proc(shape: ^Shape) -> Mass_Data {unimplemented()}
Compute_Shape_Extent :: proc(shape: ^Shape) -> Shape_Extent {unimplemented()}
Compute_Shape_AABB :: proc(shape: ^Shape, xf: Transform) -> AABB {unimplemented()}
Get_Shape_Centroid :: proc(shape: ^Shape) -> Vector2 {unimplemented()}

Make_Shape_Distance_Proxy :: proc(shape: ^Shape) -> Distance_Proxy {unimplemented()}

Ray_Cast_Shape :: proc(
	input: ^RayCast_Input,
	shape: ^Shape,
	xf: Transform,
) -> RayCast_Output {unimplemented()}
Shape_Cast_Shape :: proc(
	input: ^ShapeCastInput,
	shape: ^Shape,
	xf: ^Transform,
) -> RayCast_Output {unimplemented()}

Get_Shape :: proc(world: ^World, shapeId: Shape_Id) -> ^Shape {unimplemented()}
