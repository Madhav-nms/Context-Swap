.equ SYSTICK_CSR,   0xE000E010
.equ SYSTICK_RVR,   0xE000E014
.equ SYSTICK_CVR,   0xE000E018
.equ ICSR,          0xE000ED04
.equ SHPR3,         0xE000ED20
.equ PENDSVSET,     0x10000000

.equ TICK_RELOAD,   0x00FFFFFF
.equ NUM_TASKS,     3

.section .vectors
vector_table:
    .word _stack_top
    .word reset_handler + 1

    .org 0x38
    .word pendsv_handler + 1

    .org 0x3C
    .word systick_handler + 1


.section .text
.align 2
.type reset_handler, %function
reset_handler:

    ldr  r0, =SHPR3
    ldr  r1, [r0]
    orr  r1, r1, #(0xFF << 16)
    str  r1, [r0]

    ldr  r0, =SYSTICK_RVR
    ldr  r1, =TICK_RELOAD
    str  r1, [r0]

    ldr  r0, =SYSTICK_CVR
    mov  r1, #0
    str  r1, [r0]

    ldr  r0, =SYSTICK_CSR
    mov  r1, #0x7
    str  r1, [r0]

    ldr  r0, =task_stack_tops
    ldr  r1, [r0, #0]
    msr  PSP, r1

    mov  r0, #0x2
    msr  CONTROL, r0
    isb

    bl   task0

    b    .


.section .text
.align 2
.type systick_handler, %function
systick_handler:
    ldr  r0, =ICSR
    ldr  r1, =PENDSVSET
    str  r1, [r0]
    bx   lr


.section .text
.align 2
.type pendsv_handler, %function
pendsv_handler:

    mrs  r0, PSP
    isb

    stmdb r0!, {r4-r11}

    ldr  r1, =current_task
    ldr  r2, [r1]
    ldr  r3, =tcb
    str  r0, [r3, r2, lsl #2]

    add  r2, r2, #1
    cmp  r2, #NUM_TASKS
    it   eq
    moveq r2, #0
    str  r2, [r1]

    ldr  r0, [r3, r2, lsl #2]

    ldmia r0!, {r4-r11}

    msr  PSP, r0
    isb

    ldr  lr, =0xFFFFFFFD
    bx   lr


.section .text
.p2align 2
.globl task0
.type  task0, %function
task0:
    nop
    add  r4, r4, #1
    b    task0


.section .text
.p2align 2
.globl task1
.type  task1, %function
task1:
    nop
    add  r5, r5, #1
    b    task1


.section .text
.p2align 2
.globl task2
.type  task2, %function
task2:
    nop
    add  r6, r6, #1
    b    task2


.data

.align 2
current_task:
    .word 0

.align 2
tcb:
    .word 0
    .word 0
    .word 0

.align 2
task_stack_tops:
    .word stack0_top
    .word stack1_top
    .word stack2_top


.align 3
.skip 256
stack0_frame:
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word task0 + 1
    .word 0x01000000
stack0_top = stack0_frame


.align 3
.skip 256
stack1_frame:
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word task1 + 1
    .word 0x01000000
stack1_top = stack1_frame


.align 3
.skip 256
stack2_frame:
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000
    .word task2 + 1
    .word 0x01000000
stack2_top = stack2_frame
