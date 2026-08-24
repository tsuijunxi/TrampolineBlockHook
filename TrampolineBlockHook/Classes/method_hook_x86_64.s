//
//  method_hook_x86_64.m
//  TrampolineBlockHook
//
//  Created by tsuijunxi on 20/2/2023.
//

#if defined(__x86_64__)

.macro save_register
push %rdi
push %rsi
push %rdx
push %rcx
push %r8
push %r9
push %r10
push %r11
push %rax
push %rax
.endm

.macro load_register
pop %rax
pop %rax
pop %r11
pop %r10
pop %r9
pop %r8
pop %rcx
pop %rdx
pop %rsi
pop %rdi
.endm

.text
.align 12
.globl _method_table_page
_method_table_page:

_method_tramp_dispatch:
movq (%rsp), %r11

subq $0x20, %rsp

subq $0x5, %r11
subq $0x1000, %r11
movq %r11, 0x8(%rsp)
movq %rdi, 0x10(%rsp)
movq %rsi, 0x18(%rsp)

movq 0x18(%r11), %r10
cmpq $0x0, %r10
je method

before:
save_register
call *%r10
load_register

method:
call *0x10(%r11)

movq 0x8(%rsp), %r11
movq 0x20(%r11), %r10
cmpq $0x0, %r10
je end

after:
save_register
movq 0x60(%rsp), %rdi
movq 0x68(%rsp), %rsi
call *%r10
load_register

end:
addq $0x20, %rsp
ret
.align 4

.rept 256
call _method_tramp_dispatch # 5 bytes
.rept 34
nop
.endr
ret
.endr

#endif

