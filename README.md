# Context-Swap
 
A tiny preemptive scheduler for ARM Cortex-M3, written from scratch in assembly. Three simple tasks take turns running, swapped out by a timer interrupt every second or so. No C, no FreeRTOS, no vendor libraries - just the assembler and the bare chip.
 
Runs in QEMU, debugged with GDB.
 
## What I learnt from building this

I understood how the Cortex-M exception model, the split between MSP and PSP, why `EXC_RETURN` is a magic value instead of a normal address, and how a context switch is really just "save eight registers, swap a stack pointer, restore eight registers." Most of an RTOS scheduler is hidden in those few instructions.
 
So I wrote the smallest thing I could that demonstrates the real mechanics. If you understand this file, you understand most of how an RTOS schedules tasks on a Cortex-M.
 
## What's in the box
 
```
.s       : The whole kernel: vector table, handlers, tasks, stacks
.ld      : Tells the linker where flash and RAM live
Makefile : Build, run in QEMU, attach GDB
```
 
## How it works (the short version)
 
When the chip boots, the kernel sets up a timer (SysTick), points the CPU at task 0, and lets it run. Every time the timer fires, an interrupt called PendSV swaps in the next task. Each task gets its own stack and its own copy of the CPU registers, so they don't step on each other.
 
The tasks themselves are deliberately boring — each one just increments a different register in a loop. That way when you break in GDB, you can see three counters going up independently, which proves the context switching actually works. 
 
## A few things I cut corners on
 
I'd rather flag these honestly than pretend they're production-ready:
 
- **No fault handlers.** If anything goes wrong (bad memory access, divide by zero), the chip just hangs.
- **`.data` lives directly in RAM.** That works in QEMU because it loads the ELF straight into memory, but on a real chip you'd need a copy loop in reset. I left it out to keep the kernel readable.
- **256 bytes of stack per task.** Plenty for these tasks, way too small for anything real.
- **Round-robin only.** No priorities, no sleep, no synchronization. Just "next task, please."
## What I'd do next
 
If I kept building on this, the next steps would be a fault handler that prints diagnostics, cooperative `yield()` via SVCall, and a simple semaphore so tasks could actually coordinate.
