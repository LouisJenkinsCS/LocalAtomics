The `LocalAtomicObject` is a very simple abstraction that is optimized to ignore the `locale` 
portion of a wide pointer (and act directly on the `addr`), and perform normal 64-bit atomic 
operations that way. It is a simple yet efficient solution. Also provided is a solution for
the ABA problem that relies on CMPXCHG16B Intel instruction for Double-Word Compare-And-Swap.
We require `unmanaged` classes; currently this will leak memory if you do not have safe memory-management solution. Originally
developed during the 
[Distributed Data Structures effort for GSoC 2017](https://summerofcode.withgoogle.com/archive/2017/projects/6530769430249472/) 
and now continued in the [Concurrent-Safe Memory Reclamation Systems effort for GSoC 2019](https://summerofcode.withgoogle.com/projects/#6095033818677248).



**Dependencies**

Intel's `CMPXCHG16B` must be supported on your system (it is on ~99% of machines these days)
for double-word compare-and-swap. As well, when you compile you _must_ build with
`CHPL_LLVM` set (I.E to `CHPL_LLVM=llvm` or `CHPL_LLVM=system`) as the program uses `extern`
blocks, and you must compile with `--llvm` (or alternatively compile with `--ccflags -O2`)
as GCC currently has an issue where it will try to 'optimize' the inlined assembly and results
in a general protection fault. 
