package box2o

Set_Item :: struct {
	key:  u64,
	hash: u32,
}

Hash_Set :: struct {
	items:    ^Set_Item,
	capacity: u32,
	count:    u32,
}

CreateSet :: proc(capacity: i32) -> Hash_Set
DestroySet :: proc(set: ^Hash_Set)

ClearSet :: proc(set: ^Hash_Set)

// Returns true if key was already in set
AddKey :: proc(set: ^Hash_Set, key: u64) -> bool {unimplemented()}
// Returns true if the key was found
RemoveKey :: proc(set: ^Hash_Set, key: u64) -> bool {unimplemented()}
ContainsKey :: proc(set: ^Hash_Set, key: u64) -> bool {unimplemented()}
