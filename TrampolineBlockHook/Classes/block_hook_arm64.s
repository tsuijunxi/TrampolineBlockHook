//
//  block_hook_arm64.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 17/2/2023.
//

#if defined(__arm64__)

.macro save_register
stp q0,  q1,   [sp, #-32]!
stp q2,  q3,   [sp, #-32]!
stp q4,  q5,   [sp, #-32]!
stp q6,  q7,   [sp, #-32]!
stp lr,  x10,  [sp, #-16]!
stp x0,  x1,   [sp, #-16]!
stp x2,  x3,   [sp, #-16]!
stp x4,  x5,   [sp, #-16]!
stp x6,  x7,   [sp, #-16]!
stp x8,  x12,  [sp, #-16]!
.endm

.macro load_register
ldp x8,  x12,  [sp], #16
ldp x6,  x7,   [sp], #16
ldp x4,  x5,   [sp], #16
ldp x2,  x3,   [sp], #16
ldp x0,  x1,   [sp], #16
ldp lr,  x10,  [sp], #16
ldp q6,  q7,   [sp], #32
ldp q4,  q5,   [sp], #32
ldp q2,  q3,   [sp], #32
ldp q0,  q1,   [sp], #32
.endm

# write out the trampoline table, aligned to the page boundary
.text
.align 14
.globl _blockimp_table_page
_blockimp_table_page:

_block_tramp_dispatch:

# trampoline address+8 is in lr
sub x12, lr, #0x8
sub x12, x12, #0x4000

# save x12
str x13, [sp, #-16]!
str x12, [sp, #-16]!

# restore the link register
mov x10, x13

ldr x13, [x12, #0x18]
cbz x13, block

pre:
save_register
ldr x0, [x12]
blr x13
load_register

block:
ldr x13, [x12, #0x10]
blr x13

after:
ldr x12, [sp], #16
ldr x13, [x12, #0x20]
cbz x13, end
save_register
ldr x0, [x12]
blr x13
load_register

end:
ldr x13, [sp], #0x10
br x13

.rept 1022
mov x13, lr
bl _block_tramp_dispatch;
.rept 8
nop
.endr
.endr

#endif

