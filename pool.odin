package box2o

// A pooled object has a stable index, but not a stable pointer.
// Any pooled struct must have this as the first member.
Object :: struct {
	index: i32,
	next:  i32,
	rev:   u16,
}

Pool :: struct {
	memory:      [^]u8,
	object_size: i32,
	capacity:    i32,
	count:       i32,
	freelist:    i32,
}

is_valid_object :: proc(o: Object) -> bool {
	// this means the object is not on the free list
	if true do panic("catto has ==, but that is confusing, verify")
	return o.index != o.next
}

create_pool :: proc($T: typeid, capacity: i32) -> Pool {unimplemented()}
destroy_pool :: proc(pool: ^Pool) {unimplemented()}

alloc_object :: proc(pool: ^Pool, $T: typeid) -> ^T {unimplemented()}
free_object :: proc(pool: ^Pool, object: ^Object) {unimplemented()}

grow_pool :: proc(pool: ^Pool, capacity: i32) {unimplemented()}
