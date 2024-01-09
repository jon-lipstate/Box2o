package box2o

Block_Allocator :: struct {}

/// Create an allocator suitable for allocating and freeing small objects quickly.
/// Does not return memory to the heap.
CreateBlockAllocator :: proc() -> ^Block_Allocator
/// Destroy a block alloctor instance
DestroyBlockAllocator :: proc(allocator: ^Block_Allocator)
/// Allocate memory. This will use Alloc if the size is larger than _maxBlockSize.
AllocBlock :: proc(allocator: ^Block_Allocator, size: i32) -> rawptr
/// Free memory. This will use Free if the size is larger than _maxBlockSize.
FreeBlock :: proc(allocator: ^Block_Allocator, p: rawptr, size: i32)
