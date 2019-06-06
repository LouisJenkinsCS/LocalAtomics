The `LocalAtomicObject` is a very simple abstraction that is optimized to ignore the `locale` 
portion of a wide pointer (and act directly on the `addr`), and perform normal 64-bit atomic 
operations that way. It is a simple yet efficient solution.

```chpl
var head : LocalAtomicObject(unmanaged Node(int));
head.write(new Node(1));
```


**Dependencies**

Intels `CMPXCHG16B` must be supported on your system (it is on ~99% of machines these days)
for double-word compare-and-swap. As well, when you compile you _must_ build with
`CHPL_LLVM` set (I.E to `CHPL_LLVM=llvm` or `CHPL_LLVM=system`) as the program uses `extern`
blocks, and you must compile with `--llvm` (or alternatively compile with `--ccflags -O2`)
as GCC currently has an issue where it will try to 'optimize' the inlined assembly and results
in a general protection fault. 
