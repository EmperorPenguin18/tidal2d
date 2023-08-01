/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .data

  .globl _libSDL2_so_tramp_table
  .hidden _libSDL2_so_tramp_table
  .align 8
_libSDL2_so_tramp_table:
  .zero 6712

  .text

  .globl _libSDL2_so_tramp_resolve
  .hidden _libSDL2_so_tramp_resolve

  .globl _libSDL2_so_save_regs_and_resolve
  .hidden _libSDL2_so_save_regs_and_resolve
  .type _libSDL2_so_save_regs_and_resolve, %function
_libSDL2_so_save_regs_and_resolve:
  .cfi_startproc

#define PUSH_REG(reg) pushq %reg ; .cfi_adjust_cfa_offset 8; .cfi_rel_offset reg, 0
#define POP_REG(reg) popq %reg ; .cfi_adjust_cfa_offset -8; .cfi_restore reg

#define DEC_STACK(d) subq $d, %rsp; .cfi_adjust_cfa_offset d
#define INC_STACK(d) addq $d, %rsp; .cfi_adjust_cfa_offset -d

#define PUSH_XMM_REG(reg) DEC_STACK(16); movdqa %reg, (%rsp); .cfi_rel_offset reg, 0
#define POP_XMM_REG(reg) movdqa (%rsp), %reg; .cfi_restore reg; INC_STACK(16)

  // Slow path which calls dlsym, taken only on first call.
  // All registers are stored to handle arbitrary calling conventions
  // (except x87 FPU registers which do not have to be preserved).
  // For Dwarf directives, read https://www.imperialviolet.org/2017/01/18/cfi.html.

  .cfi_def_cfa_offset 8  // Return address

  // FIXME: AVX (YMM, ZMM) registers are NOT saved to simplify code.

  PUSH_REG(rdi)  // 16
  mov 0x10(%rsp), %rdi
  PUSH_REG(rax)
  PUSH_REG(rbx)  // 16
  PUSH_REG(rcx)
  PUSH_REG(rdx)  // 16
  PUSH_REG(rbp)
  PUSH_REG(rsi)  // 16
  PUSH_REG(r8)
  PUSH_REG(r9)  // 16
  PUSH_REG(r10)
  PUSH_REG(r11)  // 16
  PUSH_REG(r12)
  PUSH_REG(r13)  // 16
  PUSH_REG(r14)
  PUSH_REG(r15)  // 16
  PUSH_XMM_REG(xmm0)
  PUSH_XMM_REG(xmm1)
  PUSH_XMM_REG(xmm2)
  PUSH_XMM_REG(xmm3)
  PUSH_XMM_REG(xmm4)
  PUSH_XMM_REG(xmm5)
  PUSH_XMM_REG(xmm6)
  PUSH_XMM_REG(xmm7)

  // Stack is just 8-byte aligned but callee will re-align to 16
  call _libSDL2_so_tramp_resolve

  POP_XMM_REG(xmm7)
  POP_XMM_REG(xmm6)
  POP_XMM_REG(xmm5)
  POP_XMM_REG(xmm4)
  POP_XMM_REG(xmm3)
  POP_XMM_REG(xmm2)
  POP_XMM_REG(xmm1)
  POP_XMM_REG(xmm0)  // 16
  POP_REG(r15)
  POP_REG(r14)  // 16
  POP_REG(r13)
  POP_REG(r12)  // 16
  POP_REG(r11)
  POP_REG(r10)  // 16
  POP_REG(r9)
  POP_REG(r8)  // 16
  POP_REG(rsi)
  POP_REG(rbp)  // 16
  POP_REG(rdx)
  POP_REG(rcx)  // 16
  POP_REG(rbx)
  POP_REG(rax)  // 16
  POP_REG(rdi)

  ret

  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AddEventWatch
  .p2align 4
  .type SDL_AddEventWatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AddEventWatch
#endif
SDL_AddEventWatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AddHintCallback
  .p2align 4
  .type SDL_AddHintCallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AddHintCallback
#endif
SDL_AddHintCallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AddTimer
  .p2align 4
  .type SDL_AddTimer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AddTimer
#endif
SDL_AddTimer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AllocFormat
  .p2align 4
  .type SDL_AllocFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AllocFormat
#endif
SDL_AllocFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AllocPalette
  .p2align 4
  .type SDL_AllocPalette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AllocPalette
#endif
SDL_AllocPalette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AllocRW
  .p2align 4
  .type SDL_AllocRW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AllocRW
#endif
SDL_AllocRW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicAdd
  .p2align 4
  .type SDL_AtomicAdd, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicAdd
#endif
SDL_AtomicAdd:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicCAS
  .p2align 4
  .type SDL_AtomicCAS, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicCAS
#endif
SDL_AtomicCAS:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicCASPtr
  .p2align 4
  .type SDL_AtomicCASPtr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicCASPtr
#endif
SDL_AtomicCASPtr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicGet
  .p2align 4
  .type SDL_AtomicGet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicGet
#endif
SDL_AtomicGet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicGetPtr
  .p2align 4
  .type SDL_AtomicGetPtr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicGetPtr
#endif
SDL_AtomicGetPtr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicLock
  .p2align 4
  .type SDL_AtomicLock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicLock
#endif
SDL_AtomicLock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicSet
  .p2align 4
  .type SDL_AtomicSet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicSet
#endif
SDL_AtomicSet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicSetPtr
  .p2align 4
  .type SDL_AtomicSetPtr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicSetPtr
#endif
SDL_AtomicSetPtr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicTryLock
  .p2align 4
  .type SDL_AtomicTryLock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicTryLock
#endif
SDL_AtomicTryLock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AtomicUnlock
  .p2align 4
  .type SDL_AtomicUnlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AtomicUnlock
#endif
SDL_AtomicUnlock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioInit
  .p2align 4
  .type SDL_AudioInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioInit
#endif
SDL_AudioInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioQuit
  .p2align 4
  .type SDL_AudioQuit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioQuit
#endif
SDL_AudioQuit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioStreamAvailable
  .p2align 4
  .type SDL_AudioStreamAvailable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioStreamAvailable
#endif
SDL_AudioStreamAvailable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioStreamClear
  .p2align 4
  .type SDL_AudioStreamClear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioStreamClear
#endif
SDL_AudioStreamClear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioStreamFlush
  .p2align 4
  .type SDL_AudioStreamFlush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioStreamFlush
#endif
SDL_AudioStreamFlush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioStreamGet
  .p2align 4
  .type SDL_AudioStreamGet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioStreamGet
#endif
SDL_AudioStreamGet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_AudioStreamPut
  .p2align 4
  .type SDL_AudioStreamPut, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_AudioStreamPut
#endif
SDL_AudioStreamPut:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_BuildAudioCVT
  .p2align 4
  .type SDL_BuildAudioCVT, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_BuildAudioCVT
#endif
SDL_BuildAudioCVT:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CalculateGammaRamp
  .p2align 4
  .type SDL_CalculateGammaRamp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CalculateGammaRamp
#endif
SDL_CalculateGammaRamp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CaptureMouse
  .p2align 4
  .type SDL_CaptureMouse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CaptureMouse
#endif
SDL_CaptureMouse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ClearComposition
  .p2align 4
  .type SDL_ClearComposition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ClearComposition
#endif
SDL_ClearComposition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ClearError
  .p2align 4
  .type SDL_ClearError, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ClearError
#endif
SDL_ClearError:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ClearHints
  .p2align 4
  .type SDL_ClearHints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ClearHints
#endif
SDL_ClearHints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ClearQueuedAudio
  .p2align 4
  .type SDL_ClearQueuedAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ClearQueuedAudio
#endif
SDL_ClearQueuedAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CloseAudio
  .p2align 4
  .type SDL_CloseAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CloseAudio
#endif
SDL_CloseAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CloseAudioDevice
  .p2align 4
  .type SDL_CloseAudioDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CloseAudioDevice
#endif
SDL_CloseAudioDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ComposeCustomBlendMode
  .p2align 4
  .type SDL_ComposeCustomBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ComposeCustomBlendMode
#endif
SDL_ComposeCustomBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CondBroadcast
  .p2align 4
  .type SDL_CondBroadcast, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CondBroadcast
#endif
SDL_CondBroadcast:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CondSignal
  .p2align 4
  .type SDL_CondSignal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CondSignal
#endif
SDL_CondSignal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CondWait
  .p2align 4
  .type SDL_CondWait, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CondWait
#endif
SDL_CondWait:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CondWaitTimeout
  .p2align 4
  .type SDL_CondWaitTimeout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CondWaitTimeout
#endif
SDL_CondWaitTimeout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ConvertAudio
  .p2align 4
  .type SDL_ConvertAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ConvertAudio
#endif
SDL_ConvertAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ConvertPixels
  .p2align 4
  .type SDL_ConvertPixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ConvertPixels
#endif
SDL_ConvertPixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ConvertSurface
  .p2align 4
  .type SDL_ConvertSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ConvertSurface
#endif
SDL_ConvertSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ConvertSurfaceFormat
  .p2align 4
  .type SDL_ConvertSurfaceFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ConvertSurfaceFormat
#endif
SDL_ConvertSurfaceFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateColorCursor
  .p2align 4
  .type SDL_CreateColorCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateColorCursor
#endif
SDL_CreateColorCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateCond
  .p2align 4
  .type SDL_CreateCond, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateCond
#endif
SDL_CreateCond:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateCursor
  .p2align 4
  .type SDL_CreateCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateCursor
#endif
SDL_CreateCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateMutex
  .p2align 4
  .type SDL_CreateMutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateMutex
#endif
SDL_CreateMutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateRGBSurface
  .p2align 4
  .type SDL_CreateRGBSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateRGBSurface
#endif
SDL_CreateRGBSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateRGBSurfaceFrom
  .p2align 4
  .type SDL_CreateRGBSurfaceFrom, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateRGBSurfaceFrom
#endif
SDL_CreateRGBSurfaceFrom:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateRGBSurfaceWithFormat
  .p2align 4
  .type SDL_CreateRGBSurfaceWithFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateRGBSurfaceWithFormat
#endif
SDL_CreateRGBSurfaceWithFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateRGBSurfaceWithFormatFrom
  .p2align 4
  .type SDL_CreateRGBSurfaceWithFormatFrom, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateRGBSurfaceWithFormatFrom
#endif
SDL_CreateRGBSurfaceWithFormatFrom:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateRenderer
  .p2align 4
  .type SDL_CreateRenderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateRenderer
#endif
SDL_CreateRenderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateSemaphore
  .p2align 4
  .type SDL_CreateSemaphore, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateSemaphore
#endif
SDL_CreateSemaphore:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateShapedWindow
  .p2align 4
  .type SDL_CreateShapedWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateShapedWindow
#endif
SDL_CreateShapedWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateSoftwareRenderer
  .p2align 4
  .type SDL_CreateSoftwareRenderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateSoftwareRenderer
#endif
SDL_CreateSoftwareRenderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateSystemCursor
  .p2align 4
  .type SDL_CreateSystemCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateSystemCursor
#endif
SDL_CreateSystemCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateTexture
  .p2align 4
  .type SDL_CreateTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateTexture
#endif
SDL_CreateTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateTextureFromSurface
  .p2align 4
  .type SDL_CreateTextureFromSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateTextureFromSurface
#endif
SDL_CreateTextureFromSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateThread
  .p2align 4
  .type SDL_CreateThread, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateThread
#endif
SDL_CreateThread:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateThreadWithStackSize
  .p2align 4
  .type SDL_CreateThreadWithStackSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateThreadWithStackSize
#endif
SDL_CreateThreadWithStackSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateWindow
  .p2align 4
  .type SDL_CreateWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateWindow
#endif
SDL_CreateWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateWindowAndRenderer
  .p2align 4
  .type SDL_CreateWindowAndRenderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateWindowAndRenderer
#endif
SDL_CreateWindowAndRenderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_CreateWindowFrom
  .p2align 4
  .type SDL_CreateWindowFrom, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_CreateWindowFrom
#endif
SDL_CreateWindowFrom:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DYNAPI_entry
  .p2align 4
  .type SDL_DYNAPI_entry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DYNAPI_entry
#endif
SDL_DYNAPI_entry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DelEventWatch
  .p2align 4
  .type SDL_DelEventWatch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DelEventWatch
#endif
SDL_DelEventWatch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DelHintCallback
  .p2align 4
  .type SDL_DelHintCallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DelHintCallback
#endif
SDL_DelHintCallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Delay
  .p2align 4
  .type SDL_Delay, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Delay
#endif
SDL_Delay:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DequeueAudio
  .p2align 4
  .type SDL_DequeueAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DequeueAudio
#endif
SDL_DequeueAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyCond
  .p2align 4
  .type SDL_DestroyCond, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyCond
#endif
SDL_DestroyCond:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyMutex
  .p2align 4
  .type SDL_DestroyMutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyMutex
#endif
SDL_DestroyMutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyRenderer
  .p2align 4
  .type SDL_DestroyRenderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyRenderer
#endif
SDL_DestroyRenderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroySemaphore
  .p2align 4
  .type SDL_DestroySemaphore, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroySemaphore
#endif
SDL_DestroySemaphore:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyTexture
  .p2align 4
  .type SDL_DestroyTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyTexture
#endif
SDL_DestroyTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyWindow
  .p2align 4
  .type SDL_DestroyWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyWindow
#endif
SDL_DestroyWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DestroyWindowSurface
  .p2align 4
  .type SDL_DestroyWindowSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DestroyWindowSurface
#endif
SDL_DestroyWindowSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DetachThread
  .p2align 4
  .type SDL_DetachThread, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DetachThread
#endif
SDL_DetachThread:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DisableScreenSaver
  .p2align 4
  .type SDL_DisableScreenSaver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DisableScreenSaver
#endif
SDL_DisableScreenSaver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_DuplicateSurface
  .p2align 4
  .type SDL_DuplicateSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_DuplicateSurface
#endif
SDL_DuplicateSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_EnableScreenSaver
  .p2align 4
  .type SDL_EnableScreenSaver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_EnableScreenSaver
#endif
SDL_EnableScreenSaver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_EncloseFPoints
  .p2align 4
  .type SDL_EncloseFPoints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_EncloseFPoints
#endif
SDL_EncloseFPoints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_EnclosePoints
  .p2align 4
  .type SDL_EnclosePoints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_EnclosePoints
#endif
SDL_EnclosePoints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Error
  .p2align 4
  .type SDL_Error, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Error
#endif
SDL_Error:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_EventState
  .p2align 4
  .type SDL_EventState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_EventState
#endif
SDL_EventState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FillRect
  .p2align 4
  .type SDL_FillRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FillRect
#endif
SDL_FillRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FillRects
  .p2align 4
  .type SDL_FillRects, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FillRects
#endif
SDL_FillRects:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FilterEvents
  .p2align 4
  .type SDL_FilterEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FilterEvents
#endif
SDL_FilterEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FlashWindow
  .p2align 4
  .type SDL_FlashWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FlashWindow
#endif
SDL_FlashWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FlushEvent
  .p2align 4
  .type SDL_FlushEvent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FlushEvent
#endif
SDL_FlushEvent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FlushEvents
  .p2align 4
  .type SDL_FlushEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FlushEvents
#endif
SDL_FlushEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeAudioStream
  .p2align 4
  .type SDL_FreeAudioStream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeAudioStream
#endif
SDL_FreeAudioStream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeCursor
  .p2align 4
  .type SDL_FreeCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeCursor
#endif
SDL_FreeCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeFormat
  .p2align 4
  .type SDL_FreeFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeFormat
#endif
SDL_FreeFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreePalette
  .p2align 4
  .type SDL_FreePalette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreePalette
#endif
SDL_FreePalette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeRW
  .p2align 4
  .type SDL_FreeRW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeRW
#endif
SDL_FreeRW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeSurface
  .p2align 4
  .type SDL_FreeSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeSurface
#endif
SDL_FreeSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_FreeWAV
  .p2align 4
  .type SDL_FreeWAV, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_FreeWAV
#endif
SDL_FreeWAV:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_BindTexture
  .p2align 4
  .type SDL_GL_BindTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_BindTexture
#endif
SDL_GL_BindTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_CreateContext
  .p2align 4
  .type SDL_GL_CreateContext, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_CreateContext
#endif
SDL_GL_CreateContext:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_DeleteContext
  .p2align 4
  .type SDL_GL_DeleteContext, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_DeleteContext
#endif
SDL_GL_DeleteContext:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_ExtensionSupported
  .p2align 4
  .type SDL_GL_ExtensionSupported, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_ExtensionSupported
#endif
SDL_GL_ExtensionSupported:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetAttribute
  .p2align 4
  .type SDL_GL_GetAttribute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetAttribute
#endif
SDL_GL_GetAttribute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetCurrentContext
  .p2align 4
  .type SDL_GL_GetCurrentContext, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetCurrentContext
#endif
SDL_GL_GetCurrentContext:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetCurrentWindow
  .p2align 4
  .type SDL_GL_GetCurrentWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetCurrentWindow
#endif
SDL_GL_GetCurrentWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetDrawableSize
  .p2align 4
  .type SDL_GL_GetDrawableSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetDrawableSize
#endif
SDL_GL_GetDrawableSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetProcAddress
  .p2align 4
  .type SDL_GL_GetProcAddress, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetProcAddress
#endif
SDL_GL_GetProcAddress:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_GetSwapInterval
  .p2align 4
  .type SDL_GL_GetSwapInterval, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_GetSwapInterval
#endif
SDL_GL_GetSwapInterval:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_LoadLibrary
  .p2align 4
  .type SDL_GL_LoadLibrary, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_LoadLibrary
#endif
SDL_GL_LoadLibrary:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_MakeCurrent
  .p2align 4
  .type SDL_GL_MakeCurrent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_MakeCurrent
#endif
SDL_GL_MakeCurrent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_ResetAttributes
  .p2align 4
  .type SDL_GL_ResetAttributes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_ResetAttributes
#endif
SDL_GL_ResetAttributes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_SetAttribute
  .p2align 4
  .type SDL_GL_SetAttribute, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_SetAttribute
#endif
SDL_GL_SetAttribute:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_SetSwapInterval
  .p2align 4
  .type SDL_GL_SetSwapInterval, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_SetSwapInterval
#endif
SDL_GL_SetSwapInterval:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_SwapWindow
  .p2align 4
  .type SDL_GL_SwapWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_SwapWindow
#endif
SDL_GL_SwapWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_UnbindTexture
  .p2align 4
  .type SDL_GL_UnbindTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_UnbindTexture
#endif
SDL_GL_UnbindTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GL_UnloadLibrary
  .p2align 4
  .type SDL_GL_UnloadLibrary, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GL_UnloadLibrary
#endif
SDL_GL_UnloadLibrary:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GUIDFromString
  .p2align 4
  .type SDL_GUIDFromString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GUIDFromString
#endif
SDL_GUIDFromString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GUIDToString
  .p2align 4
  .type SDL_GUIDToString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GUIDToString
#endif
SDL_GUIDToString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerAddMapping
  .p2align 4
  .type SDL_GameControllerAddMapping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerAddMapping
#endif
SDL_GameControllerAddMapping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerAddMappingsFromRW
  .p2align 4
  .type SDL_GameControllerAddMappingsFromRW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerAddMappingsFromRW
#endif
SDL_GameControllerAddMappingsFromRW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerClose
  .p2align 4
  .type SDL_GameControllerClose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerClose
#endif
SDL_GameControllerClose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerEventState
  .p2align 4
  .type SDL_GameControllerEventState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerEventState
#endif
SDL_GameControllerEventState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerFromInstanceID
  .p2align 4
  .type SDL_GameControllerFromInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerFromInstanceID
#endif
SDL_GameControllerFromInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerFromPlayerIndex
  .p2align 4
  .type SDL_GameControllerFromPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerFromPlayerIndex
#endif
SDL_GameControllerFromPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetAppleSFSymbolsNameForAxis
  .p2align 4
  .type SDL_GameControllerGetAppleSFSymbolsNameForAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetAppleSFSymbolsNameForAxis
#endif
SDL_GameControllerGetAppleSFSymbolsNameForAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetAppleSFSymbolsNameForButton
  .p2align 4
  .type SDL_GameControllerGetAppleSFSymbolsNameForButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetAppleSFSymbolsNameForButton
#endif
SDL_GameControllerGetAppleSFSymbolsNameForButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetAttached
  .p2align 4
  .type SDL_GameControllerGetAttached, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetAttached
#endif
SDL_GameControllerGetAttached:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetAxis
  .p2align 4
  .type SDL_GameControllerGetAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetAxis
#endif
SDL_GameControllerGetAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetAxisFromString
  .p2align 4
  .type SDL_GameControllerGetAxisFromString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetAxisFromString
#endif
SDL_GameControllerGetAxisFromString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetBindForAxis
  .p2align 4
  .type SDL_GameControllerGetBindForAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetBindForAxis
#endif
SDL_GameControllerGetBindForAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetBindForButton
  .p2align 4
  .type SDL_GameControllerGetBindForButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetBindForButton
#endif
SDL_GameControllerGetBindForButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetButton
  .p2align 4
  .type SDL_GameControllerGetButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetButton
#endif
SDL_GameControllerGetButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetButtonFromString
  .p2align 4
  .type SDL_GameControllerGetButtonFromString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetButtonFromString
#endif
SDL_GameControllerGetButtonFromString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetFirmwareVersion
  .p2align 4
  .type SDL_GameControllerGetFirmwareVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetFirmwareVersion
#endif
SDL_GameControllerGetFirmwareVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetJoystick
  .p2align 4
  .type SDL_GameControllerGetJoystick, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetJoystick
#endif
SDL_GameControllerGetJoystick:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetNumTouchpadFingers
  .p2align 4
  .type SDL_GameControllerGetNumTouchpadFingers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetNumTouchpadFingers
#endif
SDL_GameControllerGetNumTouchpadFingers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetNumTouchpads
  .p2align 4
  .type SDL_GameControllerGetNumTouchpads, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetNumTouchpads
#endif
SDL_GameControllerGetNumTouchpads:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetPlayerIndex
  .p2align 4
  .type SDL_GameControllerGetPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetPlayerIndex
#endif
SDL_GameControllerGetPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetProduct
  .p2align 4
  .type SDL_GameControllerGetProduct, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetProduct
#endif
SDL_GameControllerGetProduct:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetProductVersion
  .p2align 4
  .type SDL_GameControllerGetProductVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetProductVersion
#endif
SDL_GameControllerGetProductVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetSensorData
  .p2align 4
  .type SDL_GameControllerGetSensorData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetSensorData
#endif
SDL_GameControllerGetSensorData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetSensorDataRate
  .p2align 4
  .type SDL_GameControllerGetSensorDataRate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetSensorDataRate
#endif
SDL_GameControllerGetSensorDataRate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetSensorDataWithTimestamp
  .p2align 4
  .type SDL_GameControllerGetSensorDataWithTimestamp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetSensorDataWithTimestamp
#endif
SDL_GameControllerGetSensorDataWithTimestamp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetSerial
  .p2align 4
  .type SDL_GameControllerGetSerial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetSerial
#endif
SDL_GameControllerGetSerial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetStringForAxis
  .p2align 4
  .type SDL_GameControllerGetStringForAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetStringForAxis
#endif
SDL_GameControllerGetStringForAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetStringForButton
  .p2align 4
  .type SDL_GameControllerGetStringForButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetStringForButton
#endif
SDL_GameControllerGetStringForButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetTouchpadFinger
  .p2align 4
  .type SDL_GameControllerGetTouchpadFinger, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetTouchpadFinger
#endif
SDL_GameControllerGetTouchpadFinger:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetType
  .p2align 4
  .type SDL_GameControllerGetType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetType
#endif
SDL_GameControllerGetType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerGetVendor
  .p2align 4
  .type SDL_GameControllerGetVendor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerGetVendor
#endif
SDL_GameControllerGetVendor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasAxis
  .p2align 4
  .type SDL_GameControllerHasAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasAxis
#endif
SDL_GameControllerHasAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasButton
  .p2align 4
  .type SDL_GameControllerHasButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasButton
#endif
SDL_GameControllerHasButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasLED
  .p2align 4
  .type SDL_GameControllerHasLED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasLED
#endif
SDL_GameControllerHasLED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasRumble
  .p2align 4
  .type SDL_GameControllerHasRumble, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasRumble
#endif
SDL_GameControllerHasRumble:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasRumbleTriggers
  .p2align 4
  .type SDL_GameControllerHasRumbleTriggers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasRumbleTriggers
#endif
SDL_GameControllerHasRumbleTriggers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerHasSensor
  .p2align 4
  .type SDL_GameControllerHasSensor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerHasSensor
#endif
SDL_GameControllerHasSensor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerIsSensorEnabled
  .p2align 4
  .type SDL_GameControllerIsSensorEnabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerIsSensorEnabled
#endif
SDL_GameControllerIsSensorEnabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerMapping
  .p2align 4
  .type SDL_GameControllerMapping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerMapping
#endif
SDL_GameControllerMapping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerMappingForDeviceIndex
  .p2align 4
  .type SDL_GameControllerMappingForDeviceIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerMappingForDeviceIndex
#endif
SDL_GameControllerMappingForDeviceIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerMappingForGUID
  .p2align 4
  .type SDL_GameControllerMappingForGUID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerMappingForGUID
#endif
SDL_GameControllerMappingForGUID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerMappingForIndex
  .p2align 4
  .type SDL_GameControllerMappingForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerMappingForIndex
#endif
SDL_GameControllerMappingForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerName
  .p2align 4
  .type SDL_GameControllerName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerName
#endif
SDL_GameControllerName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerNameForIndex
  .p2align 4
  .type SDL_GameControllerNameForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerNameForIndex
#endif
SDL_GameControllerNameForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerNumMappings
  .p2align 4
  .type SDL_GameControllerNumMappings, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerNumMappings
#endif
SDL_GameControllerNumMappings:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerOpen
  .p2align 4
  .type SDL_GameControllerOpen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerOpen
#endif
SDL_GameControllerOpen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerPath
  .p2align 4
  .type SDL_GameControllerPath, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerPath
#endif
SDL_GameControllerPath:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerPathForIndex
  .p2align 4
  .type SDL_GameControllerPathForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerPathForIndex
#endif
SDL_GameControllerPathForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerRumble
  .p2align 4
  .type SDL_GameControllerRumble, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerRumble
#endif
SDL_GameControllerRumble:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerRumbleTriggers
  .p2align 4
  .type SDL_GameControllerRumbleTriggers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerRumbleTriggers
#endif
SDL_GameControllerRumbleTriggers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerSendEffect
  .p2align 4
  .type SDL_GameControllerSendEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerSendEffect
#endif
SDL_GameControllerSendEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerSetLED
  .p2align 4
  .type SDL_GameControllerSetLED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerSetLED
#endif
SDL_GameControllerSetLED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerSetPlayerIndex
  .p2align 4
  .type SDL_GameControllerSetPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerSetPlayerIndex
#endif
SDL_GameControllerSetPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerSetSensorEnabled
  .p2align 4
  .type SDL_GameControllerSetSensorEnabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerSetSensorEnabled
#endif
SDL_GameControllerSetSensorEnabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerTypeForIndex
  .p2align 4
  .type SDL_GameControllerTypeForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerTypeForIndex
#endif
SDL_GameControllerTypeForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GameControllerUpdate
  .p2align 4
  .type SDL_GameControllerUpdate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GameControllerUpdate
#endif
SDL_GameControllerUpdate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAssertionHandler
  .p2align 4
  .type SDL_GetAssertionHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAssertionHandler
#endif
SDL_GetAssertionHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAssertionReport
  .p2align 4
  .type SDL_GetAssertionReport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAssertionReport
#endif
SDL_GetAssertionReport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAudioDeviceName
  .p2align 4
  .type SDL_GetAudioDeviceName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAudioDeviceName
#endif
SDL_GetAudioDeviceName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAudioDeviceSpec
  .p2align 4
  .type SDL_GetAudioDeviceSpec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAudioDeviceSpec
#endif
SDL_GetAudioDeviceSpec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAudioDeviceStatus
  .p2align 4
  .type SDL_GetAudioDeviceStatus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAudioDeviceStatus
#endif
SDL_GetAudioDeviceStatus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAudioDriver
  .p2align 4
  .type SDL_GetAudioDriver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAudioDriver
#endif
SDL_GetAudioDriver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetAudioStatus
  .p2align 4
  .type SDL_GetAudioStatus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetAudioStatus
#endif
SDL_GetAudioStatus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetBasePath
  .p2align 4
  .type SDL_GetBasePath, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetBasePath
#endif
SDL_GetBasePath:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCPUCacheLineSize
  .p2align 4
  .type SDL_GetCPUCacheLineSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCPUCacheLineSize
#endif
SDL_GetCPUCacheLineSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCPUCount
  .p2align 4
  .type SDL_GetCPUCount, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCPUCount
#endif
SDL_GetCPUCount:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetClipRect
  .p2align 4
  .type SDL_GetClipRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetClipRect
#endif
SDL_GetClipRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetClipboardText
  .p2align 4
  .type SDL_GetClipboardText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetClipboardText
#endif
SDL_GetClipboardText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetClosestDisplayMode
  .p2align 4
  .type SDL_GetClosestDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetClosestDisplayMode
#endif
SDL_GetClosestDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetColorKey
  .p2align 4
  .type SDL_GetColorKey, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetColorKey
#endif
SDL_GetColorKey:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCurrentAudioDriver
  .p2align 4
  .type SDL_GetCurrentAudioDriver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCurrentAudioDriver
#endif
SDL_GetCurrentAudioDriver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCurrentDisplayMode
  .p2align 4
  .type SDL_GetCurrentDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCurrentDisplayMode
#endif
SDL_GetCurrentDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCurrentVideoDriver
  .p2align 4
  .type SDL_GetCurrentVideoDriver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCurrentVideoDriver
#endif
SDL_GetCurrentVideoDriver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetCursor
  .p2align 4
  .type SDL_GetCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetCursor
#endif
SDL_GetCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDefaultAssertionHandler
  .p2align 4
  .type SDL_GetDefaultAssertionHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDefaultAssertionHandler
#endif
SDL_GetDefaultAssertionHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDefaultAudioInfo
  .p2align 4
  .type SDL_GetDefaultAudioInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDefaultAudioInfo
#endif
SDL_GetDefaultAudioInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDefaultCursor
  .p2align 4
  .type SDL_GetDefaultCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDefaultCursor
#endif
SDL_GetDefaultCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDesktopDisplayMode
  .p2align 4
  .type SDL_GetDesktopDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDesktopDisplayMode
#endif
SDL_GetDesktopDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayBounds
  .p2align 4
  .type SDL_GetDisplayBounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayBounds
#endif
SDL_GetDisplayBounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayDPI
  .p2align 4
  .type SDL_GetDisplayDPI, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayDPI
#endif
SDL_GetDisplayDPI:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayMode
  .p2align 4
  .type SDL_GetDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayMode
#endif
SDL_GetDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayName
  .p2align 4
  .type SDL_GetDisplayName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayName
#endif
SDL_GetDisplayName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayOrientation
  .p2align 4
  .type SDL_GetDisplayOrientation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayOrientation
#endif
SDL_GetDisplayOrientation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetDisplayUsableBounds
  .p2align 4
  .type SDL_GetDisplayUsableBounds, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetDisplayUsableBounds
#endif
SDL_GetDisplayUsableBounds:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetError
  .p2align 4
  .type SDL_GetError, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetError
#endif
SDL_GetError:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetErrorMsg
  .p2align 4
  .type SDL_GetErrorMsg, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetErrorMsg
#endif
SDL_GetErrorMsg:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetEventFilter
  .p2align 4
  .type SDL_GetEventFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetEventFilter
#endif
SDL_GetEventFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetGlobalMouseState
  .p2align 4
  .type SDL_GetGlobalMouseState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetGlobalMouseState
#endif
SDL_GetGlobalMouseState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetGrabbedWindow
  .p2align 4
  .type SDL_GetGrabbedWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetGrabbedWindow
#endif
SDL_GetGrabbedWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetHint
  .p2align 4
  .type SDL_GetHint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetHint
#endif
SDL_GetHint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetHintBoolean
  .p2align 4
  .type SDL_GetHintBoolean, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetHintBoolean
#endif
SDL_GetHintBoolean:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetJoystickGUIDInfo
  .p2align 4
  .type SDL_GetJoystickGUIDInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetJoystickGUIDInfo
#endif
SDL_GetJoystickGUIDInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetKeyFromName
  .p2align 4
  .type SDL_GetKeyFromName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetKeyFromName
#endif
SDL_GetKeyFromName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetKeyFromScancode
  .p2align 4
  .type SDL_GetKeyFromScancode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetKeyFromScancode
#endif
SDL_GetKeyFromScancode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetKeyName
  .p2align 4
  .type SDL_GetKeyName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetKeyName
#endif
SDL_GetKeyName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetKeyboardFocus
  .p2align 4
  .type SDL_GetKeyboardFocus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetKeyboardFocus
#endif
SDL_GetKeyboardFocus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetKeyboardState
  .p2align 4
  .type SDL_GetKeyboardState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetKeyboardState
#endif
SDL_GetKeyboardState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetMemoryFunctions
  .p2align 4
  .type SDL_GetMemoryFunctions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetMemoryFunctions
#endif
SDL_GetMemoryFunctions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetModState
  .p2align 4
  .type SDL_GetModState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetModState
#endif
SDL_GetModState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetMouseFocus
  .p2align 4
  .type SDL_GetMouseFocus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetMouseFocus
#endif
SDL_GetMouseFocus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetMouseState
  .p2align 4
  .type SDL_GetMouseState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetMouseState
#endif
SDL_GetMouseState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumAllocations
  .p2align 4
  .type SDL_GetNumAllocations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumAllocations
#endif
SDL_GetNumAllocations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumAudioDevices
  .p2align 4
  .type SDL_GetNumAudioDevices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumAudioDevices
#endif
SDL_GetNumAudioDevices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumAudioDrivers
  .p2align 4
  .type SDL_GetNumAudioDrivers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumAudioDrivers
#endif
SDL_GetNumAudioDrivers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumDisplayModes
  .p2align 4
  .type SDL_GetNumDisplayModes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumDisplayModes
#endif
SDL_GetNumDisplayModes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumRenderDrivers
  .p2align 4
  .type SDL_GetNumRenderDrivers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumRenderDrivers
#endif
SDL_GetNumRenderDrivers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumTouchDevices
  .p2align 4
  .type SDL_GetNumTouchDevices, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumTouchDevices
#endif
SDL_GetNumTouchDevices:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumTouchFingers
  .p2align 4
  .type SDL_GetNumTouchFingers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumTouchFingers
#endif
SDL_GetNumTouchFingers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumVideoDisplays
  .p2align 4
  .type SDL_GetNumVideoDisplays, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumVideoDisplays
#endif
SDL_GetNumVideoDisplays:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetNumVideoDrivers
  .p2align 4
  .type SDL_GetNumVideoDrivers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetNumVideoDrivers
#endif
SDL_GetNumVideoDrivers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetOriginalMemoryFunctions
  .p2align 4
  .type SDL_GetOriginalMemoryFunctions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetOriginalMemoryFunctions
#endif
SDL_GetOriginalMemoryFunctions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPerformanceCounter
  .p2align 4
  .type SDL_GetPerformanceCounter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPerformanceCounter
#endif
SDL_GetPerformanceCounter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPerformanceFrequency
  .p2align 4
  .type SDL_GetPerformanceFrequency, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPerformanceFrequency
#endif
SDL_GetPerformanceFrequency:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPixelFormatName
  .p2align 4
  .type SDL_GetPixelFormatName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPixelFormatName
#endif
SDL_GetPixelFormatName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPlatform
  .p2align 4
  .type SDL_GetPlatform, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPlatform
#endif
SDL_GetPlatform:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPointDisplayIndex
  .p2align 4
  .type SDL_GetPointDisplayIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPointDisplayIndex
#endif
SDL_GetPointDisplayIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPowerInfo
  .p2align 4
  .type SDL_GetPowerInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPowerInfo
#endif
SDL_GetPowerInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPrefPath
  .p2align 4
  .type SDL_GetPrefPath, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPrefPath
#endif
SDL_GetPrefPath:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPreferredLocales
  .p2align 4
  .type SDL_GetPreferredLocales, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPreferredLocales
#endif
SDL_GetPreferredLocales:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetPrimarySelectionText
  .p2align 4
  .type SDL_GetPrimarySelectionText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetPrimarySelectionText
#endif
SDL_GetPrimarySelectionText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetQueuedAudioSize
  .p2align 4
  .type SDL_GetQueuedAudioSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetQueuedAudioSize
#endif
SDL_GetQueuedAudioSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRGB
  .p2align 4
  .type SDL_GetRGB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRGB
#endif
SDL_GetRGB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRGBA
  .p2align 4
  .type SDL_GetRGBA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRGBA
#endif
SDL_GetRGBA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRectDisplayIndex
  .p2align 4
  .type SDL_GetRectDisplayIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRectDisplayIndex
#endif
SDL_GetRectDisplayIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRelativeMouseMode
  .p2align 4
  .type SDL_GetRelativeMouseMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRelativeMouseMode
#endif
SDL_GetRelativeMouseMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRelativeMouseState
  .p2align 4
  .type SDL_GetRelativeMouseState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRelativeMouseState
#endif
SDL_GetRelativeMouseState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRenderDrawBlendMode
  .p2align 4
  .type SDL_GetRenderDrawBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRenderDrawBlendMode
#endif
SDL_GetRenderDrawBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRenderDrawColor
  .p2align 4
  .type SDL_GetRenderDrawColor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRenderDrawColor
#endif
SDL_GetRenderDrawColor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRenderDriverInfo
  .p2align 4
  .type SDL_GetRenderDriverInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRenderDriverInfo
#endif
SDL_GetRenderDriverInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRenderTarget
  .p2align 4
  .type SDL_GetRenderTarget, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRenderTarget
#endif
SDL_GetRenderTarget:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRenderer
  .p2align 4
  .type SDL_GetRenderer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRenderer
#endif
SDL_GetRenderer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRendererInfo
  .p2align 4
  .type SDL_GetRendererInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRendererInfo
#endif
SDL_GetRendererInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRendererOutputSize
  .p2align 4
  .type SDL_GetRendererOutputSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRendererOutputSize
#endif
SDL_GetRendererOutputSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRevision
  .p2align 4
  .type SDL_GetRevision, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRevision
#endif
SDL_GetRevision:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetRevisionNumber
  .p2align 4
  .type SDL_GetRevisionNumber, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetRevisionNumber
#endif
SDL_GetRevisionNumber:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetScancodeFromKey
  .p2align 4
  .type SDL_GetScancodeFromKey, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetScancodeFromKey
#endif
SDL_GetScancodeFromKey:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetScancodeFromName
  .p2align 4
  .type SDL_GetScancodeFromName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetScancodeFromName
#endif
SDL_GetScancodeFromName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetScancodeName
  .p2align 4
  .type SDL_GetScancodeName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetScancodeName
#endif
SDL_GetScancodeName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetShapedWindowMode
  .p2align 4
  .type SDL_GetShapedWindowMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetShapedWindowMode
#endif
SDL_GetShapedWindowMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetSurfaceAlphaMod
  .p2align 4
  .type SDL_GetSurfaceAlphaMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetSurfaceAlphaMod
#endif
SDL_GetSurfaceAlphaMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetSurfaceBlendMode
  .p2align 4
  .type SDL_GetSurfaceBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetSurfaceBlendMode
#endif
SDL_GetSurfaceBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetSurfaceColorMod
  .p2align 4
  .type SDL_GetSurfaceColorMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetSurfaceColorMod
#endif
SDL_GetSurfaceColorMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetSystemRAM
  .p2align 4
  .type SDL_GetSystemRAM, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetSystemRAM
#endif
SDL_GetSystemRAM:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTextureAlphaMod
  .p2align 4
  .type SDL_GetTextureAlphaMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTextureAlphaMod
#endif
SDL_GetTextureAlphaMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTextureBlendMode
  .p2align 4
  .type SDL_GetTextureBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTextureBlendMode
#endif
SDL_GetTextureBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTextureColorMod
  .p2align 4
  .type SDL_GetTextureColorMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTextureColorMod
#endif
SDL_GetTextureColorMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTextureScaleMode
  .p2align 4
  .type SDL_GetTextureScaleMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTextureScaleMode
#endif
SDL_GetTextureScaleMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTextureUserData
  .p2align 4
  .type SDL_GetTextureUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTextureUserData
#endif
SDL_GetTextureUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetThreadID
  .p2align 4
  .type SDL_GetThreadID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetThreadID
#endif
SDL_GetThreadID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetThreadName
  .p2align 4
  .type SDL_GetThreadName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetThreadName
#endif
SDL_GetThreadName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTicks
  .p2align 4
  .type SDL_GetTicks, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTicks
#endif
SDL_GetTicks:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTicks64
  .p2align 4
  .type SDL_GetTicks64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTicks64
#endif
SDL_GetTicks64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTouchDevice
  .p2align 4
  .type SDL_GetTouchDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTouchDevice
#endif
SDL_GetTouchDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTouchDeviceType
  .p2align 4
  .type SDL_GetTouchDeviceType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTouchDeviceType
#endif
SDL_GetTouchDeviceType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTouchFinger
  .p2align 4
  .type SDL_GetTouchFinger, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTouchFinger
#endif
SDL_GetTouchFinger:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetTouchName
  .p2align 4
  .type SDL_GetTouchName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetTouchName
#endif
SDL_GetTouchName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetVersion
  .p2align 4
  .type SDL_GetVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetVersion
#endif
SDL_GetVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetVideoDriver
  .p2align 4
  .type SDL_GetVideoDriver, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetVideoDriver
#endif
SDL_GetVideoDriver:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowBordersSize
  .p2align 4
  .type SDL_GetWindowBordersSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowBordersSize
#endif
SDL_GetWindowBordersSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowBrightness
  .p2align 4
  .type SDL_GetWindowBrightness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowBrightness
#endif
SDL_GetWindowBrightness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowData
  .p2align 4
  .type SDL_GetWindowData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowData
#endif
SDL_GetWindowData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowDisplayIndex
  .p2align 4
  .type SDL_GetWindowDisplayIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowDisplayIndex
#endif
SDL_GetWindowDisplayIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowDisplayMode
  .p2align 4
  .type SDL_GetWindowDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowDisplayMode
#endif
SDL_GetWindowDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowFlags
  .p2align 4
  .type SDL_GetWindowFlags, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowFlags
#endif
SDL_GetWindowFlags:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowFromID
  .p2align 4
  .type SDL_GetWindowFromID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowFromID
#endif
SDL_GetWindowFromID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowGammaRamp
  .p2align 4
  .type SDL_GetWindowGammaRamp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowGammaRamp
#endif
SDL_GetWindowGammaRamp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowGrab
  .p2align 4
  .type SDL_GetWindowGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowGrab
#endif
SDL_GetWindowGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowICCProfile
  .p2align 4
  .type SDL_GetWindowICCProfile, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowICCProfile
#endif
SDL_GetWindowICCProfile:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowID
  .p2align 4
  .type SDL_GetWindowID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowID
#endif
SDL_GetWindowID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowKeyboardGrab
  .p2align 4
  .type SDL_GetWindowKeyboardGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowKeyboardGrab
#endif
SDL_GetWindowKeyboardGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowMaximumSize
  .p2align 4
  .type SDL_GetWindowMaximumSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowMaximumSize
#endif
SDL_GetWindowMaximumSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowMinimumSize
  .p2align 4
  .type SDL_GetWindowMinimumSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowMinimumSize
#endif
SDL_GetWindowMinimumSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowMouseGrab
  .p2align 4
  .type SDL_GetWindowMouseGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowMouseGrab
#endif
SDL_GetWindowMouseGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowMouseRect
  .p2align 4
  .type SDL_GetWindowMouseRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowMouseRect
#endif
SDL_GetWindowMouseRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowOpacity
  .p2align 4
  .type SDL_GetWindowOpacity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowOpacity
#endif
SDL_GetWindowOpacity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowPixelFormat
  .p2align 4
  .type SDL_GetWindowPixelFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowPixelFormat
#endif
SDL_GetWindowPixelFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowPosition
  .p2align 4
  .type SDL_GetWindowPosition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowPosition
#endif
SDL_GetWindowPosition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowSize
  .p2align 4
  .type SDL_GetWindowSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowSize
#endif
SDL_GetWindowSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowSizeInPixels
  .p2align 4
  .type SDL_GetWindowSizeInPixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowSizeInPixels
#endif
SDL_GetWindowSizeInPixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowSurface
  .p2align 4
  .type SDL_GetWindowSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowSurface
#endif
SDL_GetWindowSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowTitle
  .p2align 4
  .type SDL_GetWindowTitle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowTitle
#endif
SDL_GetWindowTitle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetWindowWMInfo
  .p2align 4
  .type SDL_GetWindowWMInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetWindowWMInfo
#endif
SDL_GetWindowWMInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetYUVConversionMode
  .p2align 4
  .type SDL_GetYUVConversionMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetYUVConversionMode
#endif
SDL_GetYUVConversionMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_GetYUVConversionModeForResolution
  .p2align 4
  .type SDL_GetYUVConversionModeForResolution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_GetYUVConversionModeForResolution
#endif
SDL_GetYUVConversionModeForResolution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticClose
  .p2align 4
  .type SDL_HapticClose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticClose
#endif
SDL_HapticClose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticDestroyEffect
  .p2align 4
  .type SDL_HapticDestroyEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticDestroyEffect
#endif
SDL_HapticDestroyEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticEffectSupported
  .p2align 4
  .type SDL_HapticEffectSupported, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticEffectSupported
#endif
SDL_HapticEffectSupported:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticGetEffectStatus
  .p2align 4
  .type SDL_HapticGetEffectStatus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticGetEffectStatus
#endif
SDL_HapticGetEffectStatus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticIndex
  .p2align 4
  .type SDL_HapticIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticIndex
#endif
SDL_HapticIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticName
  .p2align 4
  .type SDL_HapticName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticName
#endif
SDL_HapticName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticNewEffect
  .p2align 4
  .type SDL_HapticNewEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticNewEffect
#endif
SDL_HapticNewEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticNumAxes
  .p2align 4
  .type SDL_HapticNumAxes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticNumAxes
#endif
SDL_HapticNumAxes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticNumEffects
  .p2align 4
  .type SDL_HapticNumEffects, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticNumEffects
#endif
SDL_HapticNumEffects:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticNumEffectsPlaying
  .p2align 4
  .type SDL_HapticNumEffectsPlaying, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticNumEffectsPlaying
#endif
SDL_HapticNumEffectsPlaying:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticOpen
  .p2align 4
  .type SDL_HapticOpen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticOpen
#endif
SDL_HapticOpen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticOpenFromJoystick
  .p2align 4
  .type SDL_HapticOpenFromJoystick, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticOpenFromJoystick
#endif
SDL_HapticOpenFromJoystick:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticOpenFromMouse
  .p2align 4
  .type SDL_HapticOpenFromMouse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticOpenFromMouse
#endif
SDL_HapticOpenFromMouse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticOpened
  .p2align 4
  .type SDL_HapticOpened, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticOpened
#endif
SDL_HapticOpened:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticPause
  .p2align 4
  .type SDL_HapticPause, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticPause
#endif
SDL_HapticPause:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticQuery
  .p2align 4
  .type SDL_HapticQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticQuery
#endif
SDL_HapticQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticRumbleInit
  .p2align 4
  .type SDL_HapticRumbleInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticRumbleInit
#endif
SDL_HapticRumbleInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticRumblePlay
  .p2align 4
  .type SDL_HapticRumblePlay, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticRumblePlay
#endif
SDL_HapticRumblePlay:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticRumbleStop
  .p2align 4
  .type SDL_HapticRumbleStop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticRumbleStop
#endif
SDL_HapticRumbleStop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticRumbleSupported
  .p2align 4
  .type SDL_HapticRumbleSupported, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticRumbleSupported
#endif
SDL_HapticRumbleSupported:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticRunEffect
  .p2align 4
  .type SDL_HapticRunEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticRunEffect
#endif
SDL_HapticRunEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticSetAutocenter
  .p2align 4
  .type SDL_HapticSetAutocenter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticSetAutocenter
#endif
SDL_HapticSetAutocenter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticSetGain
  .p2align 4
  .type SDL_HapticSetGain, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticSetGain
#endif
SDL_HapticSetGain:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticStopAll
  .p2align 4
  .type SDL_HapticStopAll, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticStopAll
#endif
SDL_HapticStopAll:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticStopEffect
  .p2align 4
  .type SDL_HapticStopEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticStopEffect
#endif
SDL_HapticStopEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticUnpause
  .p2align 4
  .type SDL_HapticUnpause, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticUnpause
#endif
SDL_HapticUnpause:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HapticUpdateEffect
  .p2align 4
  .type SDL_HapticUpdateEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HapticUpdateEffect
#endif
SDL_HapticUpdateEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Has3DNow
  .p2align 4
  .type SDL_Has3DNow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Has3DNow
#endif
SDL_Has3DNow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasARMSIMD
  .p2align 4
  .type SDL_HasARMSIMD, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasARMSIMD
#endif
SDL_HasARMSIMD:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasAVX
  .p2align 4
  .type SDL_HasAVX, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasAVX
#endif
SDL_HasAVX:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasAVX2
  .p2align 4
  .type SDL_HasAVX2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasAVX2
#endif
SDL_HasAVX2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasAVX512F
  .p2align 4
  .type SDL_HasAVX512F, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasAVX512F
#endif
SDL_HasAVX512F:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasAltiVec
  .p2align 4
  .type SDL_HasAltiVec, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasAltiVec
#endif
SDL_HasAltiVec:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasClipboardText
  .p2align 4
  .type SDL_HasClipboardText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasClipboardText
#endif
SDL_HasClipboardText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasColorKey
  .p2align 4
  .type SDL_HasColorKey, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasColorKey
#endif
SDL_HasColorKey:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasEvent
  .p2align 4
  .type SDL_HasEvent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasEvent
#endif
SDL_HasEvent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasEvents
  .p2align 4
  .type SDL_HasEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasEvents
#endif
SDL_HasEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasIntersection
  .p2align 4
  .type SDL_HasIntersection, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasIntersection
#endif
SDL_HasIntersection:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasIntersectionF
  .p2align 4
  .type SDL_HasIntersectionF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasIntersectionF
#endif
SDL_HasIntersectionF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasLASX
  .p2align 4
  .type SDL_HasLASX, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasLASX
#endif
SDL_HasLASX:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasLSX
  .p2align 4
  .type SDL_HasLSX, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasLSX
#endif
SDL_HasLSX:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasMMX
  .p2align 4
  .type SDL_HasMMX, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasMMX
#endif
SDL_HasMMX:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasNEON
  .p2align 4
  .type SDL_HasNEON, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasNEON
#endif
SDL_HasNEON:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasPrimarySelectionText
  .p2align 4
  .type SDL_HasPrimarySelectionText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasPrimarySelectionText
#endif
SDL_HasPrimarySelectionText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasRDTSC
  .p2align 4
  .type SDL_HasRDTSC, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasRDTSC
#endif
SDL_HasRDTSC:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSSE
  .p2align 4
  .type SDL_HasSSE, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSSE
#endif
SDL_HasSSE:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSSE2
  .p2align 4
  .type SDL_HasSSE2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSSE2
#endif
SDL_HasSSE2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSSE3
  .p2align 4
  .type SDL_HasSSE3, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSSE3
#endif
SDL_HasSSE3:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSSE41
  .p2align 4
  .type SDL_HasSSE41, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSSE41
#endif
SDL_HasSSE41:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSSE42
  .p2align 4
  .type SDL_HasSSE42, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSSE42
#endif
SDL_HasSSE42:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasScreenKeyboardSupport
  .p2align 4
  .type SDL_HasScreenKeyboardSupport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasScreenKeyboardSupport
#endif
SDL_HasScreenKeyboardSupport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasSurfaceRLE
  .p2align 4
  .type SDL_HasSurfaceRLE, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasSurfaceRLE
#endif
SDL_HasSurfaceRLE:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HasWindowSurface
  .p2align 4
  .type SDL_HasWindowSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HasWindowSurface
#endif
SDL_HasWindowSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_HideWindow
  .p2align 4
  .type SDL_HideWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_HideWindow
#endif
SDL_HideWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Init
  .p2align 4
  .type SDL_Init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Init
#endif
SDL_Init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_InitSubSystem
  .p2align 4
  .type SDL_InitSubSystem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_InitSubSystem
#endif
SDL_InitSubSystem:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IntersectFRect
  .p2align 4
  .type SDL_IntersectFRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IntersectFRect
#endif
SDL_IntersectFRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IntersectFRectAndLine
  .p2align 4
  .type SDL_IntersectFRectAndLine, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IntersectFRectAndLine
#endif
SDL_IntersectFRectAndLine:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IntersectRect
  .p2align 4
  .type SDL_IntersectRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IntersectRect
#endif
SDL_IntersectRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IntersectRectAndLine
  .p2align 4
  .type SDL_IntersectRectAndLine, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IntersectRectAndLine
#endif
SDL_IntersectRectAndLine:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsGameController
  .p2align 4
  .type SDL_IsGameController, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsGameController
#endif
SDL_IsGameController:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsScreenKeyboardShown
  .p2align 4
  .type SDL_IsScreenKeyboardShown, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsScreenKeyboardShown
#endif
SDL_IsScreenKeyboardShown:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsScreenSaverEnabled
  .p2align 4
  .type SDL_IsScreenSaverEnabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsScreenSaverEnabled
#endif
SDL_IsScreenSaverEnabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsShapedWindow
  .p2align 4
  .type SDL_IsShapedWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsShapedWindow
#endif
SDL_IsShapedWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsTablet
  .p2align 4
  .type SDL_IsTablet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsTablet
#endif
SDL_IsTablet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsTextInputActive
  .p2align 4
  .type SDL_IsTextInputActive, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsTextInputActive
#endif
SDL_IsTextInputActive:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_IsTextInputShown
  .p2align 4
  .type SDL_IsTextInputShown, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_IsTextInputShown
#endif
SDL_IsTextInputShown:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickAttachVirtual
  .p2align 4
  .type SDL_JoystickAttachVirtual, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickAttachVirtual
#endif
SDL_JoystickAttachVirtual:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickAttachVirtualEx
  .p2align 4
  .type SDL_JoystickAttachVirtualEx, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickAttachVirtualEx
#endif
SDL_JoystickAttachVirtualEx:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickClose
  .p2align 4
  .type SDL_JoystickClose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickClose
#endif
SDL_JoystickClose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickCurrentPowerLevel
  .p2align 4
  .type SDL_JoystickCurrentPowerLevel, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickCurrentPowerLevel
#endif
SDL_JoystickCurrentPowerLevel:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickDetachVirtual
  .p2align 4
  .type SDL_JoystickDetachVirtual, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickDetachVirtual
#endif
SDL_JoystickDetachVirtual:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickEventState
  .p2align 4
  .type SDL_JoystickEventState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickEventState
#endif
SDL_JoystickEventState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickFromInstanceID
  .p2align 4
  .type SDL_JoystickFromInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickFromInstanceID
#endif
SDL_JoystickFromInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickFromPlayerIndex
  .p2align 4
  .type SDL_JoystickFromPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickFromPlayerIndex
#endif
SDL_JoystickFromPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetAttached
  .p2align 4
  .type SDL_JoystickGetAttached, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetAttached
#endif
SDL_JoystickGetAttached:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetAxis
  .p2align 4
  .type SDL_JoystickGetAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetAxis
#endif
SDL_JoystickGetAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetAxisInitialState
  .p2align 4
  .type SDL_JoystickGetAxisInitialState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetAxisInitialState
#endif
SDL_JoystickGetAxisInitialState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetBall
  .p2align 4
  .type SDL_JoystickGetBall, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetBall
#endif
SDL_JoystickGetBall:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetButton
  .p2align 4
  .type SDL_JoystickGetButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetButton
#endif
SDL_JoystickGetButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceGUID
  .p2align 4
  .type SDL_JoystickGetDeviceGUID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceGUID
#endif
SDL_JoystickGetDeviceGUID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceInstanceID
  .p2align 4
  .type SDL_JoystickGetDeviceInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceInstanceID
#endif
SDL_JoystickGetDeviceInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDevicePlayerIndex
  .p2align 4
  .type SDL_JoystickGetDevicePlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDevicePlayerIndex
#endif
SDL_JoystickGetDevicePlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceProduct
  .p2align 4
  .type SDL_JoystickGetDeviceProduct, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceProduct
#endif
SDL_JoystickGetDeviceProduct:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceProductVersion
  .p2align 4
  .type SDL_JoystickGetDeviceProductVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceProductVersion
#endif
SDL_JoystickGetDeviceProductVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceType
  .p2align 4
  .type SDL_JoystickGetDeviceType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceType
#endif
SDL_JoystickGetDeviceType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetDeviceVendor
  .p2align 4
  .type SDL_JoystickGetDeviceVendor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetDeviceVendor
#endif
SDL_JoystickGetDeviceVendor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetFirmwareVersion
  .p2align 4
  .type SDL_JoystickGetFirmwareVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetFirmwareVersion
#endif
SDL_JoystickGetFirmwareVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetGUID
  .p2align 4
  .type SDL_JoystickGetGUID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetGUID
#endif
SDL_JoystickGetGUID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetGUIDFromString
  .p2align 4
  .type SDL_JoystickGetGUIDFromString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetGUIDFromString
#endif
SDL_JoystickGetGUIDFromString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetGUIDString
  .p2align 4
  .type SDL_JoystickGetGUIDString, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetGUIDString
#endif
SDL_JoystickGetGUIDString:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetHat
  .p2align 4
  .type SDL_JoystickGetHat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetHat
#endif
SDL_JoystickGetHat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetPlayerIndex
  .p2align 4
  .type SDL_JoystickGetPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetPlayerIndex
#endif
SDL_JoystickGetPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetProduct
  .p2align 4
  .type SDL_JoystickGetProduct, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetProduct
#endif
SDL_JoystickGetProduct:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetProductVersion
  .p2align 4
  .type SDL_JoystickGetProductVersion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetProductVersion
#endif
SDL_JoystickGetProductVersion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetSerial
  .p2align 4
  .type SDL_JoystickGetSerial, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetSerial
#endif
SDL_JoystickGetSerial:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetType
  .p2align 4
  .type SDL_JoystickGetType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetType
#endif
SDL_JoystickGetType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickGetVendor
  .p2align 4
  .type SDL_JoystickGetVendor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickGetVendor
#endif
SDL_JoystickGetVendor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickHasLED
  .p2align 4
  .type SDL_JoystickHasLED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickHasLED
#endif
SDL_JoystickHasLED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickHasRumble
  .p2align 4
  .type SDL_JoystickHasRumble, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickHasRumble
#endif
SDL_JoystickHasRumble:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickHasRumbleTriggers
  .p2align 4
  .type SDL_JoystickHasRumbleTriggers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickHasRumbleTriggers
#endif
SDL_JoystickHasRumbleTriggers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickInstanceID
  .p2align 4
  .type SDL_JoystickInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickInstanceID
#endif
SDL_JoystickInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickIsHaptic
  .p2align 4
  .type SDL_JoystickIsHaptic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickIsHaptic
#endif
SDL_JoystickIsHaptic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickIsVirtual
  .p2align 4
  .type SDL_JoystickIsVirtual, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickIsVirtual
#endif
SDL_JoystickIsVirtual:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickName
  .p2align 4
  .type SDL_JoystickName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickName
#endif
SDL_JoystickName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickNameForIndex
  .p2align 4
  .type SDL_JoystickNameForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickNameForIndex
#endif
SDL_JoystickNameForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickNumAxes
  .p2align 4
  .type SDL_JoystickNumAxes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickNumAxes
#endif
SDL_JoystickNumAxes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickNumBalls
  .p2align 4
  .type SDL_JoystickNumBalls, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickNumBalls
#endif
SDL_JoystickNumBalls:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickNumButtons
  .p2align 4
  .type SDL_JoystickNumButtons, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickNumButtons
#endif
SDL_JoystickNumButtons:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickNumHats
  .p2align 4
  .type SDL_JoystickNumHats, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickNumHats
#endif
SDL_JoystickNumHats:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickOpen
  .p2align 4
  .type SDL_JoystickOpen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickOpen
#endif
SDL_JoystickOpen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickPath
  .p2align 4
  .type SDL_JoystickPath, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickPath
#endif
SDL_JoystickPath:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickPathForIndex
  .p2align 4
  .type SDL_JoystickPathForIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickPathForIndex
#endif
SDL_JoystickPathForIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickRumble
  .p2align 4
  .type SDL_JoystickRumble, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickRumble
#endif
SDL_JoystickRumble:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3288(%rip)
2:
  pushq $411
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickRumbleTriggers
  .p2align 4
  .type SDL_JoystickRumbleTriggers, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickRumbleTriggers
#endif
SDL_JoystickRumbleTriggers:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3296(%rip)
2:
  pushq $412
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSendEffect
  .p2align 4
  .type SDL_JoystickSendEffect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSendEffect
#endif
SDL_JoystickSendEffect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3304(%rip)
2:
  pushq $413
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSetLED
  .p2align 4
  .type SDL_JoystickSetLED, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSetLED
#endif
SDL_JoystickSetLED:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3312(%rip)
2:
  pushq $414
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSetPlayerIndex
  .p2align 4
  .type SDL_JoystickSetPlayerIndex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSetPlayerIndex
#endif
SDL_JoystickSetPlayerIndex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3320(%rip)
2:
  pushq $415
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSetVirtualAxis
  .p2align 4
  .type SDL_JoystickSetVirtualAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSetVirtualAxis
#endif
SDL_JoystickSetVirtualAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3328(%rip)
2:
  pushq $416
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSetVirtualButton
  .p2align 4
  .type SDL_JoystickSetVirtualButton, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSetVirtualButton
#endif
SDL_JoystickSetVirtualButton:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3336(%rip)
2:
  pushq $417
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickSetVirtualHat
  .p2align 4
  .type SDL_JoystickSetVirtualHat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickSetVirtualHat
#endif
SDL_JoystickSetVirtualHat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3344(%rip)
2:
  pushq $418
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_JoystickUpdate
  .p2align 4
  .type SDL_JoystickUpdate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_JoystickUpdate
#endif
SDL_JoystickUpdate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3352(%rip)
2:
  pushq $419
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LinuxSetThreadPriority
  .p2align 4
  .type SDL_LinuxSetThreadPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LinuxSetThreadPriority
#endif
SDL_LinuxSetThreadPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3360(%rip)
2:
  pushq $420
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LinuxSetThreadPriorityAndPolicy
  .p2align 4
  .type SDL_LinuxSetThreadPriorityAndPolicy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LinuxSetThreadPriorityAndPolicy
#endif
SDL_LinuxSetThreadPriorityAndPolicy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3368(%rip)
2:
  pushq $421
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadBMP_RW
  .p2align 4
  .type SDL_LoadBMP_RW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadBMP_RW
#endif
SDL_LoadBMP_RW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3376(%rip)
2:
  pushq $422
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadDollarTemplates
  .p2align 4
  .type SDL_LoadDollarTemplates, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadDollarTemplates
#endif
SDL_LoadDollarTemplates:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3384(%rip)
2:
  pushq $423
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadFile
  .p2align 4
  .type SDL_LoadFile, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadFile
#endif
SDL_LoadFile:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3392(%rip)
2:
  pushq $424
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadFile_RW
  .p2align 4
  .type SDL_LoadFile_RW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadFile_RW
#endif
SDL_LoadFile_RW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3400(%rip)
2:
  pushq $425
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadFunction
  .p2align 4
  .type SDL_LoadFunction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadFunction
#endif
SDL_LoadFunction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3408(%rip)
2:
  pushq $426
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadObject
  .p2align 4
  .type SDL_LoadObject, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadObject
#endif
SDL_LoadObject:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3416(%rip)
2:
  pushq $427
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LoadWAV_RW
  .p2align 4
  .type SDL_LoadWAV_RW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LoadWAV_RW
#endif
SDL_LoadWAV_RW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3424(%rip)
2:
  pushq $428
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockAudio
  .p2align 4
  .type SDL_LockAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockAudio
#endif
SDL_LockAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3432(%rip)
2:
  pushq $429
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockAudioDevice
  .p2align 4
  .type SDL_LockAudioDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockAudioDevice
#endif
SDL_LockAudioDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3440(%rip)
2:
  pushq $430
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockJoysticks
  .p2align 4
  .type SDL_LockJoysticks, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockJoysticks
#endif
SDL_LockJoysticks:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3448(%rip)
2:
  pushq $431
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockMutex
  .p2align 4
  .type SDL_LockMutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockMutex
#endif
SDL_LockMutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3456(%rip)
2:
  pushq $432
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockSensors
  .p2align 4
  .type SDL_LockSensors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockSensors
#endif
SDL_LockSensors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3464(%rip)
2:
  pushq $433
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockSurface
  .p2align 4
  .type SDL_LockSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockSurface
#endif
SDL_LockSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3472(%rip)
2:
  pushq $434
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockTexture
  .p2align 4
  .type SDL_LockTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockTexture
#endif
SDL_LockTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3480(%rip)
2:
  pushq $435
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LockTextureToSurface
  .p2align 4
  .type SDL_LockTextureToSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LockTextureToSurface
#endif
SDL_LockTextureToSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3488(%rip)
2:
  pushq $436
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Log
  .p2align 4
  .type SDL_Log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Log
#endif
SDL_Log:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3496(%rip)
2:
  pushq $437
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogCritical
  .p2align 4
  .type SDL_LogCritical, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogCritical
#endif
SDL_LogCritical:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3504(%rip)
2:
  pushq $438
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogDebug
  .p2align 4
  .type SDL_LogDebug, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogDebug
#endif
SDL_LogDebug:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3512(%rip)
2:
  pushq $439
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogError
  .p2align 4
  .type SDL_LogError, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogError
#endif
SDL_LogError:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3520(%rip)
2:
  pushq $440
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogGetOutputFunction
  .p2align 4
  .type SDL_LogGetOutputFunction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogGetOutputFunction
#endif
SDL_LogGetOutputFunction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3528(%rip)
2:
  pushq $441
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogGetPriority
  .p2align 4
  .type SDL_LogGetPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogGetPriority
#endif
SDL_LogGetPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3536(%rip)
2:
  pushq $442
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogInfo
  .p2align 4
  .type SDL_LogInfo, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogInfo
#endif
SDL_LogInfo:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3544(%rip)
2:
  pushq $443
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogMessage
  .p2align 4
  .type SDL_LogMessage, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogMessage
#endif
SDL_LogMessage:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3552(%rip)
2:
  pushq $444
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogMessageV
  .p2align 4
  .type SDL_LogMessageV, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogMessageV
#endif
SDL_LogMessageV:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3560(%rip)
2:
  pushq $445
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogResetPriorities
  .p2align 4
  .type SDL_LogResetPriorities, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogResetPriorities
#endif
SDL_LogResetPriorities:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3568(%rip)
2:
  pushq $446
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogSetAllPriority
  .p2align 4
  .type SDL_LogSetAllPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogSetAllPriority
#endif
SDL_LogSetAllPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3576(%rip)
2:
  pushq $447
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogSetOutputFunction
  .p2align 4
  .type SDL_LogSetOutputFunction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogSetOutputFunction
#endif
SDL_LogSetOutputFunction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3584(%rip)
2:
  pushq $448
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogSetPriority
  .p2align 4
  .type SDL_LogSetPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogSetPriority
#endif
SDL_LogSetPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3592(%rip)
2:
  pushq $449
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogVerbose
  .p2align 4
  .type SDL_LogVerbose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogVerbose
#endif
SDL_LogVerbose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3600(%rip)
2:
  pushq $450
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LogWarn
  .p2align 4
  .type SDL_LogWarn, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LogWarn
#endif
SDL_LogWarn:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3608(%rip)
2:
  pushq $451
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LowerBlit
  .p2align 4
  .type SDL_LowerBlit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LowerBlit
#endif
SDL_LowerBlit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3616(%rip)
2:
  pushq $452
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_LowerBlitScaled
  .p2align 4
  .type SDL_LowerBlitScaled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_LowerBlitScaled
#endif
SDL_LowerBlitScaled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3624(%rip)
2:
  pushq $453
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MapRGB
  .p2align 4
  .type SDL_MapRGB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MapRGB
#endif
SDL_MapRGB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3632(%rip)
2:
  pushq $454
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MapRGBA
  .p2align 4
  .type SDL_MapRGBA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MapRGBA
#endif
SDL_MapRGBA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3640(%rip)
2:
  pushq $455
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MasksToPixelFormatEnum
  .p2align 4
  .type SDL_MasksToPixelFormatEnum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MasksToPixelFormatEnum
#endif
SDL_MasksToPixelFormatEnum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3648(%rip)
2:
  pushq $456
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MaximizeWindow
  .p2align 4
  .type SDL_MaximizeWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MaximizeWindow
#endif
SDL_MaximizeWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3656(%rip)
2:
  pushq $457
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MemoryBarrierAcquireFunction
  .p2align 4
  .type SDL_MemoryBarrierAcquireFunction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MemoryBarrierAcquireFunction
#endif
SDL_MemoryBarrierAcquireFunction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3664(%rip)
2:
  pushq $458
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MemoryBarrierReleaseFunction
  .p2align 4
  .type SDL_MemoryBarrierReleaseFunction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MemoryBarrierReleaseFunction
#endif
SDL_MemoryBarrierReleaseFunction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3672(%rip)
2:
  pushq $459
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Metal_CreateView
  .p2align 4
  .type SDL_Metal_CreateView, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Metal_CreateView
#endif
SDL_Metal_CreateView:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3680(%rip)
2:
  pushq $460
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Metal_DestroyView
  .p2align 4
  .type SDL_Metal_DestroyView, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Metal_DestroyView
#endif
SDL_Metal_DestroyView:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3688(%rip)
2:
  pushq $461
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Metal_GetDrawableSize
  .p2align 4
  .type SDL_Metal_GetDrawableSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Metal_GetDrawableSize
#endif
SDL_Metal_GetDrawableSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3696(%rip)
2:
  pushq $462
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Metal_GetLayer
  .p2align 4
  .type SDL_Metal_GetLayer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Metal_GetLayer
#endif
SDL_Metal_GetLayer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3704(%rip)
2:
  pushq $463
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MinimizeWindow
  .p2align 4
  .type SDL_MinimizeWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MinimizeWindow
#endif
SDL_MinimizeWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3712(%rip)
2:
  pushq $464
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MixAudio
  .p2align 4
  .type SDL_MixAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MixAudio
#endif
SDL_MixAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3720(%rip)
2:
  pushq $465
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MixAudioFormat
  .p2align 4
  .type SDL_MixAudioFormat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MixAudioFormat
#endif
SDL_MixAudioFormat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3728(%rip)
2:
  pushq $466
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_MouseIsHaptic
  .p2align 4
  .type SDL_MouseIsHaptic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_MouseIsHaptic
#endif
SDL_MouseIsHaptic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3736(%rip)
2:
  pushq $467
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_NewAudioStream
  .p2align 4
  .type SDL_NewAudioStream, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_NewAudioStream
#endif
SDL_NewAudioStream:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3744(%rip)
2:
  pushq $468
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_NumHaptics
  .p2align 4
  .type SDL_NumHaptics, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_NumHaptics
#endif
SDL_NumHaptics:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3752(%rip)
2:
  pushq $469
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_NumJoysticks
  .p2align 4
  .type SDL_NumJoysticks, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_NumJoysticks
#endif
SDL_NumJoysticks:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3760(%rip)
2:
  pushq $470
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_NumSensors
  .p2align 4
  .type SDL_NumSensors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_NumSensors
#endif
SDL_NumSensors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3768(%rip)
2:
  pushq $471
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationDidBecomeActive
  .p2align 4
  .type SDL_OnApplicationDidBecomeActive, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationDidBecomeActive
#endif
SDL_OnApplicationDidBecomeActive:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3776(%rip)
2:
  pushq $472
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationDidEnterBackground
  .p2align 4
  .type SDL_OnApplicationDidEnterBackground, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationDidEnterBackground
#endif
SDL_OnApplicationDidEnterBackground:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3784(%rip)
2:
  pushq $473
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationDidReceiveMemoryWarning
  .p2align 4
  .type SDL_OnApplicationDidReceiveMemoryWarning, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationDidReceiveMemoryWarning
#endif
SDL_OnApplicationDidReceiveMemoryWarning:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3792(%rip)
2:
  pushq $474
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationWillEnterForeground
  .p2align 4
  .type SDL_OnApplicationWillEnterForeground, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationWillEnterForeground
#endif
SDL_OnApplicationWillEnterForeground:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3800(%rip)
2:
  pushq $475
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationWillResignActive
  .p2align 4
  .type SDL_OnApplicationWillResignActive, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationWillResignActive
#endif
SDL_OnApplicationWillResignActive:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3808(%rip)
2:
  pushq $476
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OnApplicationWillTerminate
  .p2align 4
  .type SDL_OnApplicationWillTerminate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OnApplicationWillTerminate
#endif
SDL_OnApplicationWillTerminate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3816(%rip)
2:
  pushq $477
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OpenAudio
  .p2align 4
  .type SDL_OpenAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OpenAudio
#endif
SDL_OpenAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3824(%rip)
2:
  pushq $478
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OpenAudioDevice
  .p2align 4
  .type SDL_OpenAudioDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OpenAudioDevice
#endif
SDL_OpenAudioDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3832(%rip)
2:
  pushq $479
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_OpenURL
  .p2align 4
  .type SDL_OpenURL, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_OpenURL
#endif
SDL_OpenURL:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3840(%rip)
2:
  pushq $480
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PauseAudio
  .p2align 4
  .type SDL_PauseAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PauseAudio
#endif
SDL_PauseAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3848(%rip)
2:
  pushq $481
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PauseAudioDevice
  .p2align 4
  .type SDL_PauseAudioDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PauseAudioDevice
#endif
SDL_PauseAudioDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3856(%rip)
2:
  pushq $482
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PeepEvents
  .p2align 4
  .type SDL_PeepEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PeepEvents
#endif
SDL_PeepEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3864(%rip)
2:
  pushq $483
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PixelFormatEnumToMasks
  .p2align 4
  .type SDL_PixelFormatEnumToMasks, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PixelFormatEnumToMasks
#endif
SDL_PixelFormatEnumToMasks:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3872(%rip)
2:
  pushq $484
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PollEvent
  .p2align 4
  .type SDL_PollEvent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PollEvent
#endif
SDL_PollEvent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3880(%rip)
2:
  pushq $485
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PremultiplyAlpha
  .p2align 4
  .type SDL_PremultiplyAlpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PremultiplyAlpha
#endif
SDL_PremultiplyAlpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3888(%rip)
2:
  pushq $486
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PumpEvents
  .p2align 4
  .type SDL_PumpEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PumpEvents
#endif
SDL_PumpEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3896(%rip)
2:
  pushq $487
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_PushEvent
  .p2align 4
  .type SDL_PushEvent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_PushEvent
#endif
SDL_PushEvent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3904(%rip)
2:
  pushq $488
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_QueryTexture
  .p2align 4
  .type SDL_QueryTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_QueryTexture
#endif
SDL_QueryTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3912(%rip)
2:
  pushq $489
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_QueueAudio
  .p2align 4
  .type SDL_QueueAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_QueueAudio
#endif
SDL_QueueAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3920(%rip)
2:
  pushq $490
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Quit
  .p2align 4
  .type SDL_Quit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Quit
#endif
SDL_Quit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3928(%rip)
2:
  pushq $491
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_QuitSubSystem
  .p2align 4
  .type SDL_QuitSubSystem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_QuitSubSystem
#endif
SDL_QuitSubSystem:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3936(%rip)
2:
  pushq $492
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWFromConstMem
  .p2align 4
  .type SDL_RWFromConstMem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWFromConstMem
#endif
SDL_RWFromConstMem:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3944(%rip)
2:
  pushq $493
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWFromFP
  .p2align 4
  .type SDL_RWFromFP, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWFromFP
#endif
SDL_RWFromFP:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3952(%rip)
2:
  pushq $494
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWFromFile
  .p2align 4
  .type SDL_RWFromFile, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWFromFile
#endif
SDL_RWFromFile:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3960(%rip)
2:
  pushq $495
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWFromMem
  .p2align 4
  .type SDL_RWFromMem, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWFromMem
#endif
SDL_RWFromMem:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3968(%rip)
2:
  pushq $496
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWclose
  .p2align 4
  .type SDL_RWclose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWclose
#endif
SDL_RWclose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3976(%rip)
2:
  pushq $497
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWread
  .p2align 4
  .type SDL_RWread, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWread
#endif
SDL_RWread:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3984(%rip)
2:
  pushq $498
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWseek
  .p2align 4
  .type SDL_RWseek, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWseek
#endif
SDL_RWseek:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+3992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+3992(%rip)
2:
  pushq $499
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWsize
  .p2align 4
  .type SDL_RWsize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWsize
#endif
SDL_RWsize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4000(%rip)
2:
  pushq $500
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWtell
  .p2align 4
  .type SDL_RWtell, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWtell
#endif
SDL_RWtell:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4008(%rip)
2:
  pushq $501
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RWwrite
  .p2align 4
  .type SDL_RWwrite, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RWwrite
#endif
SDL_RWwrite:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4016(%rip)
2:
  pushq $502
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RaiseWindow
  .p2align 4
  .type SDL_RaiseWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RaiseWindow
#endif
SDL_RaiseWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4024(%rip)
2:
  pushq $503
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadBE16
  .p2align 4
  .type SDL_ReadBE16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadBE16
#endif
SDL_ReadBE16:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4032(%rip)
2:
  pushq $504
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadBE32
  .p2align 4
  .type SDL_ReadBE32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadBE32
#endif
SDL_ReadBE32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4040(%rip)
2:
  pushq $505
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadBE64
  .p2align 4
  .type SDL_ReadBE64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadBE64
#endif
SDL_ReadBE64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4048(%rip)
2:
  pushq $506
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadLE16
  .p2align 4
  .type SDL_ReadLE16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadLE16
#endif
SDL_ReadLE16:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4056(%rip)
2:
  pushq $507
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadLE32
  .p2align 4
  .type SDL_ReadLE32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadLE32
#endif
SDL_ReadLE32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4064(%rip)
2:
  pushq $508
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadLE64
  .p2align 4
  .type SDL_ReadLE64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadLE64
#endif
SDL_ReadLE64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4072(%rip)
2:
  pushq $509
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReadU8
  .p2align 4
  .type SDL_ReadU8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReadU8
#endif
SDL_ReadU8:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4080(%rip)
2:
  pushq $510
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RecordGesture
  .p2align 4
  .type SDL_RecordGesture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RecordGesture
#endif
SDL_RecordGesture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4088(%rip)
2:
  pushq $511
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RegisterEvents
  .p2align 4
  .type SDL_RegisterEvents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RegisterEvents
#endif
SDL_RegisterEvents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4096(%rip)
2:
  pushq $512
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RemoveTimer
  .p2align 4
  .type SDL_RemoveTimer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RemoveTimer
#endif
SDL_RemoveTimer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4104(%rip)
2:
  pushq $513
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderClear
  .p2align 4
  .type SDL_RenderClear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderClear
#endif
SDL_RenderClear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4112(%rip)
2:
  pushq $514
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderCopy
  .p2align 4
  .type SDL_RenderCopy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderCopy
#endif
SDL_RenderCopy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4120(%rip)
2:
  pushq $515
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderCopyEx
  .p2align 4
  .type SDL_RenderCopyEx, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderCopyEx
#endif
SDL_RenderCopyEx:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4128(%rip)
2:
  pushq $516
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderCopyExF
  .p2align 4
  .type SDL_RenderCopyExF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderCopyExF
#endif
SDL_RenderCopyExF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4136(%rip)
2:
  pushq $517
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderCopyF
  .p2align 4
  .type SDL_RenderCopyF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderCopyF
#endif
SDL_RenderCopyF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4144(%rip)
2:
  pushq $518
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawLine
  .p2align 4
  .type SDL_RenderDrawLine, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawLine
#endif
SDL_RenderDrawLine:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4152(%rip)
2:
  pushq $519
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawLineF
  .p2align 4
  .type SDL_RenderDrawLineF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawLineF
#endif
SDL_RenderDrawLineF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4160(%rip)
2:
  pushq $520
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawLines
  .p2align 4
  .type SDL_RenderDrawLines, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawLines
#endif
SDL_RenderDrawLines:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4168(%rip)
2:
  pushq $521
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawLinesF
  .p2align 4
  .type SDL_RenderDrawLinesF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawLinesF
#endif
SDL_RenderDrawLinesF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4176(%rip)
2:
  pushq $522
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawPoint
  .p2align 4
  .type SDL_RenderDrawPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawPoint
#endif
SDL_RenderDrawPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4184(%rip)
2:
  pushq $523
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawPointF
  .p2align 4
  .type SDL_RenderDrawPointF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawPointF
#endif
SDL_RenderDrawPointF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4192(%rip)
2:
  pushq $524
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawPoints
  .p2align 4
  .type SDL_RenderDrawPoints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawPoints
#endif
SDL_RenderDrawPoints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4200(%rip)
2:
  pushq $525
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawPointsF
  .p2align 4
  .type SDL_RenderDrawPointsF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawPointsF
#endif
SDL_RenderDrawPointsF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4208(%rip)
2:
  pushq $526
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawRect
  .p2align 4
  .type SDL_RenderDrawRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawRect
#endif
SDL_RenderDrawRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4216(%rip)
2:
  pushq $527
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawRectF
  .p2align 4
  .type SDL_RenderDrawRectF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawRectF
#endif
SDL_RenderDrawRectF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4224(%rip)
2:
  pushq $528
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawRects
  .p2align 4
  .type SDL_RenderDrawRects, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawRects
#endif
SDL_RenderDrawRects:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4232(%rip)
2:
  pushq $529
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderDrawRectsF
  .p2align 4
  .type SDL_RenderDrawRectsF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderDrawRectsF
#endif
SDL_RenderDrawRectsF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4240(%rip)
2:
  pushq $530
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderFillRect
  .p2align 4
  .type SDL_RenderFillRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderFillRect
#endif
SDL_RenderFillRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4248(%rip)
2:
  pushq $531
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderFillRectF
  .p2align 4
  .type SDL_RenderFillRectF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderFillRectF
#endif
SDL_RenderFillRectF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4256(%rip)
2:
  pushq $532
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderFillRects
  .p2align 4
  .type SDL_RenderFillRects, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderFillRects
#endif
SDL_RenderFillRects:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4264(%rip)
2:
  pushq $533
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderFillRectsF
  .p2align 4
  .type SDL_RenderFillRectsF, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderFillRectsF
#endif
SDL_RenderFillRectsF:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4272(%rip)
2:
  pushq $534
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderFlush
  .p2align 4
  .type SDL_RenderFlush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderFlush
#endif
SDL_RenderFlush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4280(%rip)
2:
  pushq $535
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGeometry
  .p2align 4
  .type SDL_RenderGeometry, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGeometry
#endif
SDL_RenderGeometry:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4288(%rip)
2:
  pushq $536
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGeometryRaw
  .p2align 4
  .type SDL_RenderGeometryRaw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGeometryRaw
#endif
SDL_RenderGeometryRaw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4296(%rip)
2:
  pushq $537
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetClipRect
  .p2align 4
  .type SDL_RenderGetClipRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetClipRect
#endif
SDL_RenderGetClipRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4304(%rip)
2:
  pushq $538
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetIntegerScale
  .p2align 4
  .type SDL_RenderGetIntegerScale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetIntegerScale
#endif
SDL_RenderGetIntegerScale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4312(%rip)
2:
  pushq $539
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetLogicalSize
  .p2align 4
  .type SDL_RenderGetLogicalSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetLogicalSize
#endif
SDL_RenderGetLogicalSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4320(%rip)
2:
  pushq $540
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetMetalCommandEncoder
  .p2align 4
  .type SDL_RenderGetMetalCommandEncoder, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetMetalCommandEncoder
#endif
SDL_RenderGetMetalCommandEncoder:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4328(%rip)
2:
  pushq $541
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetMetalLayer
  .p2align 4
  .type SDL_RenderGetMetalLayer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetMetalLayer
#endif
SDL_RenderGetMetalLayer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4336(%rip)
2:
  pushq $542
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetScale
  .p2align 4
  .type SDL_RenderGetScale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetScale
#endif
SDL_RenderGetScale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4344(%rip)
2:
  pushq $543
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetViewport
  .p2align 4
  .type SDL_RenderGetViewport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetViewport
#endif
SDL_RenderGetViewport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4352(%rip)
2:
  pushq $544
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderGetWindow
  .p2align 4
  .type SDL_RenderGetWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderGetWindow
#endif
SDL_RenderGetWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4360(%rip)
2:
  pushq $545
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderIsClipEnabled
  .p2align 4
  .type SDL_RenderIsClipEnabled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderIsClipEnabled
#endif
SDL_RenderIsClipEnabled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4368(%rip)
2:
  pushq $546
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderLogicalToWindow
  .p2align 4
  .type SDL_RenderLogicalToWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderLogicalToWindow
#endif
SDL_RenderLogicalToWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4376(%rip)
2:
  pushq $547
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderPresent
  .p2align 4
  .type SDL_RenderPresent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderPresent
#endif
SDL_RenderPresent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4384(%rip)
2:
  pushq $548
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderReadPixels
  .p2align 4
  .type SDL_RenderReadPixels, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderReadPixels
#endif
SDL_RenderReadPixels:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4392(%rip)
2:
  pushq $549
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetClipRect
  .p2align 4
  .type SDL_RenderSetClipRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetClipRect
#endif
SDL_RenderSetClipRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4400(%rip)
2:
  pushq $550
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetIntegerScale
  .p2align 4
  .type SDL_RenderSetIntegerScale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetIntegerScale
#endif
SDL_RenderSetIntegerScale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4408(%rip)
2:
  pushq $551
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetLogicalSize
  .p2align 4
  .type SDL_RenderSetLogicalSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetLogicalSize
#endif
SDL_RenderSetLogicalSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4416(%rip)
2:
  pushq $552
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetScale
  .p2align 4
  .type SDL_RenderSetScale, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetScale
#endif
SDL_RenderSetScale:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4424(%rip)
2:
  pushq $553
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetVSync
  .p2align 4
  .type SDL_RenderSetVSync, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetVSync
#endif
SDL_RenderSetVSync:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4432(%rip)
2:
  pushq $554
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderSetViewport
  .p2align 4
  .type SDL_RenderSetViewport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderSetViewport
#endif
SDL_RenderSetViewport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4440(%rip)
2:
  pushq $555
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderTargetSupported
  .p2align 4
  .type SDL_RenderTargetSupported, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderTargetSupported
#endif
SDL_RenderTargetSupported:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4448(%rip)
2:
  pushq $556
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RenderWindowToLogical
  .p2align 4
  .type SDL_RenderWindowToLogical, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RenderWindowToLogical
#endif
SDL_RenderWindowToLogical:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4456(%rip)
2:
  pushq $557
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ReportAssertion
  .p2align 4
  .type SDL_ReportAssertion, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ReportAssertion
#endif
SDL_ReportAssertion:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4464(%rip)
2:
  pushq $558
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ResetAssertionReport
  .p2align 4
  .type SDL_ResetAssertionReport, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ResetAssertionReport
#endif
SDL_ResetAssertionReport:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4472(%rip)
2:
  pushq $559
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ResetHint
  .p2align 4
  .type SDL_ResetHint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ResetHint
#endif
SDL_ResetHint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4480(%rip)
2:
  pushq $560
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ResetHints
  .p2align 4
  .type SDL_ResetHints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ResetHints
#endif
SDL_ResetHints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4488(%rip)
2:
  pushq $561
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ResetKeyboard
  .p2align 4
  .type SDL_ResetKeyboard, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ResetKeyboard
#endif
SDL_ResetKeyboard:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4496(%rip)
2:
  pushq $562
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_RestoreWindow
  .p2align 4
  .type SDL_RestoreWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_RestoreWindow
#endif
SDL_RestoreWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4504(%rip)
2:
  pushq $563
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SIMDAlloc
  .p2align 4
  .type SDL_SIMDAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SIMDAlloc
#endif
SDL_SIMDAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4512(%rip)
2:
  pushq $564
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SIMDFree
  .p2align 4
  .type SDL_SIMDFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SIMDFree
#endif
SDL_SIMDFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4520(%rip)
2:
  pushq $565
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SIMDGetAlignment
  .p2align 4
  .type SDL_SIMDGetAlignment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SIMDGetAlignment
#endif
SDL_SIMDGetAlignment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4528(%rip)
2:
  pushq $566
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SIMDRealloc
  .p2align 4
  .type SDL_SIMDRealloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SIMDRealloc
#endif
SDL_SIMDRealloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4536(%rip)
2:
  pushq $567
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SaveAllDollarTemplates
  .p2align 4
  .type SDL_SaveAllDollarTemplates, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SaveAllDollarTemplates
#endif
SDL_SaveAllDollarTemplates:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4544(%rip)
2:
  pushq $568
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SaveBMP_RW
  .p2align 4
  .type SDL_SaveBMP_RW, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SaveBMP_RW
#endif
SDL_SaveBMP_RW:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4552(%rip)
2:
  pushq $569
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SaveDollarTemplate
  .p2align 4
  .type SDL_SaveDollarTemplate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SaveDollarTemplate
#endif
SDL_SaveDollarTemplate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4560(%rip)
2:
  pushq $570
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SemPost
  .p2align 4
  .type SDL_SemPost, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SemPost
#endif
SDL_SemPost:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4568(%rip)
2:
  pushq $571
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SemTryWait
  .p2align 4
  .type SDL_SemTryWait, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SemTryWait
#endif
SDL_SemTryWait:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4576(%rip)
2:
  pushq $572
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SemValue
  .p2align 4
  .type SDL_SemValue, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SemValue
#endif
SDL_SemValue:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4584(%rip)
2:
  pushq $573
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SemWait
  .p2align 4
  .type SDL_SemWait, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SemWait
#endif
SDL_SemWait:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4592(%rip)
2:
  pushq $574
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SemWaitTimeout
  .p2align 4
  .type SDL_SemWaitTimeout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SemWaitTimeout
#endif
SDL_SemWaitTimeout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4600(%rip)
2:
  pushq $575
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorClose
  .p2align 4
  .type SDL_SensorClose, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorClose
#endif
SDL_SensorClose:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4608(%rip)
2:
  pushq $576
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorFromInstanceID
  .p2align 4
  .type SDL_SensorFromInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorFromInstanceID
#endif
SDL_SensorFromInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4616(%rip)
2:
  pushq $577
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetData
  .p2align 4
  .type SDL_SensorGetData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetData
#endif
SDL_SensorGetData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4624(%rip)
2:
  pushq $578
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetDataWithTimestamp
  .p2align 4
  .type SDL_SensorGetDataWithTimestamp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetDataWithTimestamp
#endif
SDL_SensorGetDataWithTimestamp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4632(%rip)
2:
  pushq $579
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetDeviceInstanceID
  .p2align 4
  .type SDL_SensorGetDeviceInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetDeviceInstanceID
#endif
SDL_SensorGetDeviceInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4640(%rip)
2:
  pushq $580
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetDeviceName
  .p2align 4
  .type SDL_SensorGetDeviceName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetDeviceName
#endif
SDL_SensorGetDeviceName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4648(%rip)
2:
  pushq $581
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetDeviceNonPortableType
  .p2align 4
  .type SDL_SensorGetDeviceNonPortableType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetDeviceNonPortableType
#endif
SDL_SensorGetDeviceNonPortableType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4656(%rip)
2:
  pushq $582
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetDeviceType
  .p2align 4
  .type SDL_SensorGetDeviceType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetDeviceType
#endif
SDL_SensorGetDeviceType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4664(%rip)
2:
  pushq $583
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetInstanceID
  .p2align 4
  .type SDL_SensorGetInstanceID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetInstanceID
#endif
SDL_SensorGetInstanceID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4672(%rip)
2:
  pushq $584
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetName
  .p2align 4
  .type SDL_SensorGetName, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetName
#endif
SDL_SensorGetName:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4680(%rip)
2:
  pushq $585
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetNonPortableType
  .p2align 4
  .type SDL_SensorGetNonPortableType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetNonPortableType
#endif
SDL_SensorGetNonPortableType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4688(%rip)
2:
  pushq $586
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorGetType
  .p2align 4
  .type SDL_SensorGetType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorGetType
#endif
SDL_SensorGetType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4696(%rip)
2:
  pushq $587
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorOpen
  .p2align 4
  .type SDL_SensorOpen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorOpen
#endif
SDL_SensorOpen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4704(%rip)
2:
  pushq $588
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SensorUpdate
  .p2align 4
  .type SDL_SensorUpdate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SensorUpdate
#endif
SDL_SensorUpdate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4712(%rip)
2:
  pushq $589
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetAssertionHandler
  .p2align 4
  .type SDL_SetAssertionHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetAssertionHandler
#endif
SDL_SetAssertionHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4720(%rip)
2:
  pushq $590
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetClipRect
  .p2align 4
  .type SDL_SetClipRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetClipRect
#endif
SDL_SetClipRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4728(%rip)
2:
  pushq $591
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetClipboardText
  .p2align 4
  .type SDL_SetClipboardText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetClipboardText
#endif
SDL_SetClipboardText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4736(%rip)
2:
  pushq $592
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetColorKey
  .p2align 4
  .type SDL_SetColorKey, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetColorKey
#endif
SDL_SetColorKey:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4744(%rip)
2:
  pushq $593
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetCursor
  .p2align 4
  .type SDL_SetCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetCursor
#endif
SDL_SetCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4752(%rip)
2:
  pushq $594
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetError
  .p2align 4
  .type SDL_SetError, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetError
#endif
SDL_SetError:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4760(%rip)
2:
  pushq $595
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetEventFilter
  .p2align 4
  .type SDL_SetEventFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetEventFilter
#endif
SDL_SetEventFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4768(%rip)
2:
  pushq $596
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetHint
  .p2align 4
  .type SDL_SetHint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetHint
#endif
SDL_SetHint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4776(%rip)
2:
  pushq $597
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetHintWithPriority
  .p2align 4
  .type SDL_SetHintWithPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetHintWithPriority
#endif
SDL_SetHintWithPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4784(%rip)
2:
  pushq $598
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetMainReady
  .p2align 4
  .type SDL_SetMainReady, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetMainReady
#endif
SDL_SetMainReady:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4792(%rip)
2:
  pushq $599
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetMemoryFunctions
  .p2align 4
  .type SDL_SetMemoryFunctions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetMemoryFunctions
#endif
SDL_SetMemoryFunctions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4800(%rip)
2:
  pushq $600
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetModState
  .p2align 4
  .type SDL_SetModState, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetModState
#endif
SDL_SetModState:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4808(%rip)
2:
  pushq $601
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetPaletteColors
  .p2align 4
  .type SDL_SetPaletteColors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetPaletteColors
#endif
SDL_SetPaletteColors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4816(%rip)
2:
  pushq $602
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetPixelFormatPalette
  .p2align 4
  .type SDL_SetPixelFormatPalette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetPixelFormatPalette
#endif
SDL_SetPixelFormatPalette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4824(%rip)
2:
  pushq $603
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetPrimarySelectionText
  .p2align 4
  .type SDL_SetPrimarySelectionText, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetPrimarySelectionText
#endif
SDL_SetPrimarySelectionText:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4832(%rip)
2:
  pushq $604
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetRelativeMouseMode
  .p2align 4
  .type SDL_SetRelativeMouseMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetRelativeMouseMode
#endif
SDL_SetRelativeMouseMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4840(%rip)
2:
  pushq $605
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetRenderDrawBlendMode
  .p2align 4
  .type SDL_SetRenderDrawBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetRenderDrawBlendMode
#endif
SDL_SetRenderDrawBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4848(%rip)
2:
  pushq $606
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetRenderDrawColor
  .p2align 4
  .type SDL_SetRenderDrawColor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetRenderDrawColor
#endif
SDL_SetRenderDrawColor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4856(%rip)
2:
  pushq $607
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetRenderTarget
  .p2align 4
  .type SDL_SetRenderTarget, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetRenderTarget
#endif
SDL_SetRenderTarget:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4864(%rip)
2:
  pushq $608
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetSurfaceAlphaMod
  .p2align 4
  .type SDL_SetSurfaceAlphaMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetSurfaceAlphaMod
#endif
SDL_SetSurfaceAlphaMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4872(%rip)
2:
  pushq $609
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetSurfaceBlendMode
  .p2align 4
  .type SDL_SetSurfaceBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetSurfaceBlendMode
#endif
SDL_SetSurfaceBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4880(%rip)
2:
  pushq $610
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetSurfaceColorMod
  .p2align 4
  .type SDL_SetSurfaceColorMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetSurfaceColorMod
#endif
SDL_SetSurfaceColorMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4888(%rip)
2:
  pushq $611
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetSurfacePalette
  .p2align 4
  .type SDL_SetSurfacePalette, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetSurfacePalette
#endif
SDL_SetSurfacePalette:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4896(%rip)
2:
  pushq $612
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetSurfaceRLE
  .p2align 4
  .type SDL_SetSurfaceRLE, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetSurfaceRLE
#endif
SDL_SetSurfaceRLE:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4904(%rip)
2:
  pushq $613
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextInputRect
  .p2align 4
  .type SDL_SetTextInputRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextInputRect
#endif
SDL_SetTextInputRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4912(%rip)
2:
  pushq $614
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextureAlphaMod
  .p2align 4
  .type SDL_SetTextureAlphaMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextureAlphaMod
#endif
SDL_SetTextureAlphaMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4920(%rip)
2:
  pushq $615
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextureBlendMode
  .p2align 4
  .type SDL_SetTextureBlendMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextureBlendMode
#endif
SDL_SetTextureBlendMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4928(%rip)
2:
  pushq $616
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextureColorMod
  .p2align 4
  .type SDL_SetTextureColorMod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextureColorMod
#endif
SDL_SetTextureColorMod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4936(%rip)
2:
  pushq $617
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextureScaleMode
  .p2align 4
  .type SDL_SetTextureScaleMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextureScaleMode
#endif
SDL_SetTextureScaleMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4944(%rip)
2:
  pushq $618
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetTextureUserData
  .p2align 4
  .type SDL_SetTextureUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetTextureUserData
#endif
SDL_SetTextureUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4952(%rip)
2:
  pushq $619
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetThreadPriority
  .p2align 4
  .type SDL_SetThreadPriority, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetThreadPriority
#endif
SDL_SetThreadPriority:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4960(%rip)
2:
  pushq $620
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowAlwaysOnTop
  .p2align 4
  .type SDL_SetWindowAlwaysOnTop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowAlwaysOnTop
#endif
SDL_SetWindowAlwaysOnTop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4968(%rip)
2:
  pushq $621
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowBordered
  .p2align 4
  .type SDL_SetWindowBordered, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowBordered
#endif
SDL_SetWindowBordered:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4976(%rip)
2:
  pushq $622
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowBrightness
  .p2align 4
  .type SDL_SetWindowBrightness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowBrightness
#endif
SDL_SetWindowBrightness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4984(%rip)
2:
  pushq $623
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowData
  .p2align 4
  .type SDL_SetWindowData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowData
#endif
SDL_SetWindowData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+4992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+4992(%rip)
2:
  pushq $624
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowDisplayMode
  .p2align 4
  .type SDL_SetWindowDisplayMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowDisplayMode
#endif
SDL_SetWindowDisplayMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5000(%rip)
2:
  pushq $625
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowFullscreen
  .p2align 4
  .type SDL_SetWindowFullscreen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowFullscreen
#endif
SDL_SetWindowFullscreen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5008(%rip)
2:
  pushq $626
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowGammaRamp
  .p2align 4
  .type SDL_SetWindowGammaRamp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowGammaRamp
#endif
SDL_SetWindowGammaRamp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5016(%rip)
2:
  pushq $627
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowGrab
  .p2align 4
  .type SDL_SetWindowGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowGrab
#endif
SDL_SetWindowGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5024(%rip)
2:
  pushq $628
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowHitTest
  .p2align 4
  .type SDL_SetWindowHitTest, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowHitTest
#endif
SDL_SetWindowHitTest:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5032(%rip)
2:
  pushq $629
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowIcon
  .p2align 4
  .type SDL_SetWindowIcon, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowIcon
#endif
SDL_SetWindowIcon:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5040(%rip)
2:
  pushq $630
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowInputFocus
  .p2align 4
  .type SDL_SetWindowInputFocus, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowInputFocus
#endif
SDL_SetWindowInputFocus:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5048(%rip)
2:
  pushq $631
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowKeyboardGrab
  .p2align 4
  .type SDL_SetWindowKeyboardGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowKeyboardGrab
#endif
SDL_SetWindowKeyboardGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5056(%rip)
2:
  pushq $632
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowMaximumSize
  .p2align 4
  .type SDL_SetWindowMaximumSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowMaximumSize
#endif
SDL_SetWindowMaximumSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5064(%rip)
2:
  pushq $633
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowMinimumSize
  .p2align 4
  .type SDL_SetWindowMinimumSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowMinimumSize
#endif
SDL_SetWindowMinimumSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5072(%rip)
2:
  pushq $634
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowModalFor
  .p2align 4
  .type SDL_SetWindowModalFor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowModalFor
#endif
SDL_SetWindowModalFor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5080(%rip)
2:
  pushq $635
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowMouseGrab
  .p2align 4
  .type SDL_SetWindowMouseGrab, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowMouseGrab
#endif
SDL_SetWindowMouseGrab:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5088(%rip)
2:
  pushq $636
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowMouseRect
  .p2align 4
  .type SDL_SetWindowMouseRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowMouseRect
#endif
SDL_SetWindowMouseRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5096(%rip)
2:
  pushq $637
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowOpacity
  .p2align 4
  .type SDL_SetWindowOpacity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowOpacity
#endif
SDL_SetWindowOpacity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5104(%rip)
2:
  pushq $638
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowPosition
  .p2align 4
  .type SDL_SetWindowPosition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowPosition
#endif
SDL_SetWindowPosition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5112(%rip)
2:
  pushq $639
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowResizable
  .p2align 4
  .type SDL_SetWindowResizable, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowResizable
#endif
SDL_SetWindowResizable:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5120(%rip)
2:
  pushq $640
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowShape
  .p2align 4
  .type SDL_SetWindowShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowShape
#endif
SDL_SetWindowShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5128(%rip)
2:
  pushq $641
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowSize
  .p2align 4
  .type SDL_SetWindowSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowSize
#endif
SDL_SetWindowSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5136(%rip)
2:
  pushq $642
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetWindowTitle
  .p2align 4
  .type SDL_SetWindowTitle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetWindowTitle
#endif
SDL_SetWindowTitle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5144(%rip)
2:
  pushq $643
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SetYUVConversionMode
  .p2align 4
  .type SDL_SetYUVConversionMode, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SetYUVConversionMode
#endif
SDL_SetYUVConversionMode:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5152(%rip)
2:
  pushq $644
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ShowCursor
  .p2align 4
  .type SDL_ShowCursor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ShowCursor
#endif
SDL_ShowCursor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5160(%rip)
2:
  pushq $645
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ShowMessageBox
  .p2align 4
  .type SDL_ShowMessageBox, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ShowMessageBox
#endif
SDL_ShowMessageBox:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5168(%rip)
2:
  pushq $646
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ShowSimpleMessageBox
  .p2align 4
  .type SDL_ShowSimpleMessageBox, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ShowSimpleMessageBox
#endif
SDL_ShowSimpleMessageBox:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5176(%rip)
2:
  pushq $647
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ShowWindow
  .p2align 4
  .type SDL_ShowWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ShowWindow
#endif
SDL_ShowWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5184(%rip)
2:
  pushq $648
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SoftStretch
  .p2align 4
  .type SDL_SoftStretch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SoftStretch
#endif
SDL_SoftStretch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5192(%rip)
2:
  pushq $649
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_SoftStretchLinear
  .p2align 4
  .type SDL_SoftStretchLinear, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_SoftStretchLinear
#endif
SDL_SoftStretchLinear:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5200(%rip)
2:
  pushq $650
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_StartTextInput
  .p2align 4
  .type SDL_StartTextInput, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_StartTextInput
#endif
SDL_StartTextInput:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5208(%rip)
2:
  pushq $651
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_StopTextInput
  .p2align 4
  .type SDL_StopTextInput, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_StopTextInput
#endif
SDL_StopTextInput:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5216(%rip)
2:
  pushq $652
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_TLSCleanup
  .p2align 4
  .type SDL_TLSCleanup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_TLSCleanup
#endif
SDL_TLSCleanup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5224(%rip)
2:
  pushq $653
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_TLSCreate
  .p2align 4
  .type SDL_TLSCreate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_TLSCreate
#endif
SDL_TLSCreate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5232(%rip)
2:
  pushq $654
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_TLSGet
  .p2align 4
  .type SDL_TLSGet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_TLSGet
#endif
SDL_TLSGet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5240(%rip)
2:
  pushq $655
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_TLSSet
  .p2align 4
  .type SDL_TLSSet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_TLSSet
#endif
SDL_TLSSet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5248(%rip)
2:
  pushq $656
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ThreadID
  .p2align 4
  .type SDL_ThreadID, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ThreadID
#endif
SDL_ThreadID:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5256(%rip)
2:
  pushq $657
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_TryLockMutex
  .p2align 4
  .type SDL_TryLockMutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_TryLockMutex
#endif
SDL_TryLockMutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5264(%rip)
2:
  pushq $658
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnionFRect
  .p2align 4
  .type SDL_UnionFRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnionFRect
#endif
SDL_UnionFRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5272(%rip)
2:
  pushq $659
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnionRect
  .p2align 4
  .type SDL_UnionRect, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnionRect
#endif
SDL_UnionRect:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5280(%rip)
2:
  pushq $660
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnloadObject
  .p2align 4
  .type SDL_UnloadObject, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnloadObject
#endif
SDL_UnloadObject:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5288(%rip)
2:
  pushq $661
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockAudio
  .p2align 4
  .type SDL_UnlockAudio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockAudio
#endif
SDL_UnlockAudio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5296(%rip)
2:
  pushq $662
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockAudioDevice
  .p2align 4
  .type SDL_UnlockAudioDevice, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockAudioDevice
#endif
SDL_UnlockAudioDevice:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5304(%rip)
2:
  pushq $663
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockJoysticks
  .p2align 4
  .type SDL_UnlockJoysticks, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockJoysticks
#endif
SDL_UnlockJoysticks:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5312(%rip)
2:
  pushq $664
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockMutex
  .p2align 4
  .type SDL_UnlockMutex, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockMutex
#endif
SDL_UnlockMutex:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5320(%rip)
2:
  pushq $665
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockSensors
  .p2align 4
  .type SDL_UnlockSensors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockSensors
#endif
SDL_UnlockSensors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5328(%rip)
2:
  pushq $666
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockSurface
  .p2align 4
  .type SDL_UnlockSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockSurface
#endif
SDL_UnlockSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5336(%rip)
2:
  pushq $667
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UnlockTexture
  .p2align 4
  .type SDL_UnlockTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UnlockTexture
#endif
SDL_UnlockTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5344(%rip)
2:
  pushq $668
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpdateNVTexture
  .p2align 4
  .type SDL_UpdateNVTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpdateNVTexture
#endif
SDL_UpdateNVTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5352(%rip)
2:
  pushq $669
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpdateTexture
  .p2align 4
  .type SDL_UpdateTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpdateTexture
#endif
SDL_UpdateTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5360(%rip)
2:
  pushq $670
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpdateWindowSurface
  .p2align 4
  .type SDL_UpdateWindowSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpdateWindowSurface
#endif
SDL_UpdateWindowSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5368(%rip)
2:
  pushq $671
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpdateWindowSurfaceRects
  .p2align 4
  .type SDL_UpdateWindowSurfaceRects, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpdateWindowSurfaceRects
#endif
SDL_UpdateWindowSurfaceRects:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5376(%rip)
2:
  pushq $672
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpdateYUVTexture
  .p2align 4
  .type SDL_UpdateYUVTexture, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpdateYUVTexture
#endif
SDL_UpdateYUVTexture:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5384(%rip)
2:
  pushq $673
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpperBlit
  .p2align 4
  .type SDL_UpperBlit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpperBlit
#endif
SDL_UpperBlit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5392(%rip)
2:
  pushq $674
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_UpperBlitScaled
  .p2align 4
  .type SDL_UpperBlitScaled, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_UpperBlitScaled
#endif
SDL_UpperBlitScaled:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5400(%rip)
2:
  pushq $675
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_VideoInit
  .p2align 4
  .type SDL_VideoInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_VideoInit
#endif
SDL_VideoInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5408(%rip)
2:
  pushq $676
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_VideoQuit
  .p2align 4
  .type SDL_VideoQuit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_VideoQuit
#endif
SDL_VideoQuit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5416(%rip)
2:
  pushq $677
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_CreateSurface
  .p2align 4
  .type SDL_Vulkan_CreateSurface, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_CreateSurface
#endif
SDL_Vulkan_CreateSurface:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5424(%rip)
2:
  pushq $678
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_GetDrawableSize
  .p2align 4
  .type SDL_Vulkan_GetDrawableSize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_GetDrawableSize
#endif
SDL_Vulkan_GetDrawableSize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5432(%rip)
2:
  pushq $679
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_GetInstanceExtensions
  .p2align 4
  .type SDL_Vulkan_GetInstanceExtensions, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_GetInstanceExtensions
#endif
SDL_Vulkan_GetInstanceExtensions:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5440(%rip)
2:
  pushq $680
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_GetVkGetInstanceProcAddr
  .p2align 4
  .type SDL_Vulkan_GetVkGetInstanceProcAddr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_GetVkGetInstanceProcAddr
#endif
SDL_Vulkan_GetVkGetInstanceProcAddr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5448(%rip)
2:
  pushq $681
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_LoadLibrary
  .p2align 4
  .type SDL_Vulkan_LoadLibrary, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_LoadLibrary
#endif
SDL_Vulkan_LoadLibrary:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5456(%rip)
2:
  pushq $682
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_Vulkan_UnloadLibrary
  .p2align 4
  .type SDL_Vulkan_UnloadLibrary, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_Vulkan_UnloadLibrary
#endif
SDL_Vulkan_UnloadLibrary:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5464(%rip)
2:
  pushq $683
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WaitEvent
  .p2align 4
  .type SDL_WaitEvent, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WaitEvent
#endif
SDL_WaitEvent:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5472(%rip)
2:
  pushq $684
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WaitEventTimeout
  .p2align 4
  .type SDL_WaitEventTimeout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WaitEventTimeout
#endif
SDL_WaitEventTimeout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5480(%rip)
2:
  pushq $685
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WaitThread
  .p2align 4
  .type SDL_WaitThread, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WaitThread
#endif
SDL_WaitThread:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5488(%rip)
2:
  pushq $686
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WarpMouseGlobal
  .p2align 4
  .type SDL_WarpMouseGlobal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WarpMouseGlobal
#endif
SDL_WarpMouseGlobal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5496(%rip)
2:
  pushq $687
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WarpMouseInWindow
  .p2align 4
  .type SDL_WarpMouseInWindow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WarpMouseInWindow
#endif
SDL_WarpMouseInWindow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5504(%rip)
2:
  pushq $688
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WasInit
  .p2align 4
  .type SDL_WasInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WasInit
#endif
SDL_WasInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5512(%rip)
2:
  pushq $689
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteBE16
  .p2align 4
  .type SDL_WriteBE16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteBE16
#endif
SDL_WriteBE16:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5520(%rip)
2:
  pushq $690
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteBE32
  .p2align 4
  .type SDL_WriteBE32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteBE32
#endif
SDL_WriteBE32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5528(%rip)
2:
  pushq $691
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteBE64
  .p2align 4
  .type SDL_WriteBE64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteBE64
#endif
SDL_WriteBE64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5536(%rip)
2:
  pushq $692
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteLE16
  .p2align 4
  .type SDL_WriteLE16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteLE16
#endif
SDL_WriteLE16:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5544(%rip)
2:
  pushq $693
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteLE32
  .p2align 4
  .type SDL_WriteLE32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteLE32
#endif
SDL_WriteLE32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5552(%rip)
2:
  pushq $694
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteLE64
  .p2align 4
  .type SDL_WriteLE64, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteLE64
#endif
SDL_WriteLE64:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5560(%rip)
2:
  pushq $695
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_WriteU8
  .p2align 4
  .type SDL_WriteU8, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_WriteU8
#endif
SDL_WriteU8:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5568(%rip)
2:
  pushq $696
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_abs
  .p2align 4
  .type SDL_abs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_abs
#endif
SDL_abs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5576(%rip)
2:
  pushq $697
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_acos
  .p2align 4
  .type SDL_acos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_acos
#endif
SDL_acos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5584(%rip)
2:
  pushq $698
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_acosf
  .p2align 4
  .type SDL_acosf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_acosf
#endif
SDL_acosf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5592(%rip)
2:
  pushq $699
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_asin
  .p2align 4
  .type SDL_asin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_asin
#endif
SDL_asin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5600(%rip)
2:
  pushq $700
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_asinf
  .p2align 4
  .type SDL_asinf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_asinf
#endif
SDL_asinf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5608(%rip)
2:
  pushq $701
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_asprintf
  .p2align 4
  .type SDL_asprintf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_asprintf
#endif
SDL_asprintf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5616(%rip)
2:
  pushq $702
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atan
  .p2align 4
  .type SDL_atan, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atan
#endif
SDL_atan:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5624(%rip)
2:
  pushq $703
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atan2
  .p2align 4
  .type SDL_atan2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atan2
#endif
SDL_atan2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5632(%rip)
2:
  pushq $704
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atan2f
  .p2align 4
  .type SDL_atan2f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atan2f
#endif
SDL_atan2f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5640(%rip)
2:
  pushq $705
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atanf
  .p2align 4
  .type SDL_atanf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atanf
#endif
SDL_atanf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5648(%rip)
2:
  pushq $706
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atof
  .p2align 4
  .type SDL_atof, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atof
#endif
SDL_atof:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5656(%rip)
2:
  pushq $707
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_atoi
  .p2align 4
  .type SDL_atoi, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_atoi
#endif
SDL_atoi:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5664(%rip)
2:
  pushq $708
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_bsearch
  .p2align 4
  .type SDL_bsearch, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_bsearch
#endif
SDL_bsearch:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5672(%rip)
2:
  pushq $709
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_calloc
  .p2align 4
  .type SDL_calloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_calloc
#endif
SDL_calloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5680(%rip)
2:
  pushq $710
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ceil
  .p2align 4
  .type SDL_ceil, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ceil
#endif
SDL_ceil:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5688(%rip)
2:
  pushq $711
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ceilf
  .p2align 4
  .type SDL_ceilf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ceilf
#endif
SDL_ceilf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5696(%rip)
2:
  pushq $712
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_copysign
  .p2align 4
  .type SDL_copysign, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_copysign
#endif
SDL_copysign:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5704(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5704(%rip)
2:
  pushq $713
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_copysignf
  .p2align 4
  .type SDL_copysignf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_copysignf
#endif
SDL_copysignf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5712(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5712(%rip)
2:
  pushq $714
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_cos
  .p2align 4
  .type SDL_cos, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_cos
#endif
SDL_cos:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5720(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5720(%rip)
2:
  pushq $715
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_cosf
  .p2align 4
  .type SDL_cosf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_cosf
#endif
SDL_cosf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5728(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5728(%rip)
2:
  pushq $716
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_crc16
  .p2align 4
  .type SDL_crc16, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_crc16
#endif
SDL_crc16:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5736(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5736(%rip)
2:
  pushq $717
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_crc32
  .p2align 4
  .type SDL_crc32, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_crc32
#endif
SDL_crc32:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5744(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5744(%rip)
2:
  pushq $718
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_exp
  .p2align 4
  .type SDL_exp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_exp
#endif
SDL_exp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5752(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5752(%rip)
2:
  pushq $719
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_expf
  .p2align 4
  .type SDL_expf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_expf
#endif
SDL_expf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5760(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5760(%rip)
2:
  pushq $720
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_fabs
  .p2align 4
  .type SDL_fabs, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_fabs
#endif
SDL_fabs:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5768(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5768(%rip)
2:
  pushq $721
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_fabsf
  .p2align 4
  .type SDL_fabsf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_fabsf
#endif
SDL_fabsf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5776(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5776(%rip)
2:
  pushq $722
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_floor
  .p2align 4
  .type SDL_floor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_floor
#endif
SDL_floor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5784(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5784(%rip)
2:
  pushq $723
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_floorf
  .p2align 4
  .type SDL_floorf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_floorf
#endif
SDL_floorf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5792(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5792(%rip)
2:
  pushq $724
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_fmod
  .p2align 4
  .type SDL_fmod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_fmod
#endif
SDL_fmod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5800(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5800(%rip)
2:
  pushq $725
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_fmodf
  .p2align 4
  .type SDL_fmodf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_fmodf
#endif
SDL_fmodf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5808(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5808(%rip)
2:
  pushq $726
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_free
  .p2align 4
  .type SDL_free, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_free
#endif
SDL_free:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5816(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5816(%rip)
2:
  pushq $727
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_getenv
  .p2align 4
  .type SDL_getenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_getenv
#endif
SDL_getenv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5824(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5824(%rip)
2:
  pushq $728
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_ble_scan
  .p2align 4
  .type SDL_hid_ble_scan, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_ble_scan
#endif
SDL_hid_ble_scan:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5832(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5832(%rip)
2:
  pushq $729
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_close
  .p2align 4
  .type SDL_hid_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_close
#endif
SDL_hid_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5840(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5840(%rip)
2:
  pushq $730
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_device_change_count
  .p2align 4
  .type SDL_hid_device_change_count, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_device_change_count
#endif
SDL_hid_device_change_count:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5848(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5848(%rip)
2:
  pushq $731
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_enumerate
  .p2align 4
  .type SDL_hid_enumerate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_enumerate
#endif
SDL_hid_enumerate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5856(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5856(%rip)
2:
  pushq $732
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_exit
  .p2align 4
  .type SDL_hid_exit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_exit
#endif
SDL_hid_exit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5864(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5864(%rip)
2:
  pushq $733
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_free_enumeration
  .p2align 4
  .type SDL_hid_free_enumeration, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_free_enumeration
#endif
SDL_hid_free_enumeration:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5872(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5872(%rip)
2:
  pushq $734
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_get_feature_report
  .p2align 4
  .type SDL_hid_get_feature_report, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_get_feature_report
#endif
SDL_hid_get_feature_report:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5880(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5880(%rip)
2:
  pushq $735
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_get_indexed_string
  .p2align 4
  .type SDL_hid_get_indexed_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_get_indexed_string
#endif
SDL_hid_get_indexed_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5888(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5888(%rip)
2:
  pushq $736
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_get_manufacturer_string
  .p2align 4
  .type SDL_hid_get_manufacturer_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_get_manufacturer_string
#endif
SDL_hid_get_manufacturer_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5896(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5896(%rip)
2:
  pushq $737
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_get_product_string
  .p2align 4
  .type SDL_hid_get_product_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_get_product_string
#endif
SDL_hid_get_product_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5904(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5904(%rip)
2:
  pushq $738
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_get_serial_number_string
  .p2align 4
  .type SDL_hid_get_serial_number_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_get_serial_number_string
#endif
SDL_hid_get_serial_number_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5912(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5912(%rip)
2:
  pushq $739
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_init
  .p2align 4
  .type SDL_hid_init, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_init
#endif
SDL_hid_init:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5920(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5920(%rip)
2:
  pushq $740
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_open
  .p2align 4
  .type SDL_hid_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_open
#endif
SDL_hid_open:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5928(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5928(%rip)
2:
  pushq $741
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_open_path
  .p2align 4
  .type SDL_hid_open_path, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_open_path
#endif
SDL_hid_open_path:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5936(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5936(%rip)
2:
  pushq $742
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_read
  .p2align 4
  .type SDL_hid_read, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_read
#endif
SDL_hid_read:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5944(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5944(%rip)
2:
  pushq $743
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_read_timeout
  .p2align 4
  .type SDL_hid_read_timeout, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_read_timeout
#endif
SDL_hid_read_timeout:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5952(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5952(%rip)
2:
  pushq $744
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_send_feature_report
  .p2align 4
  .type SDL_hid_send_feature_report, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_send_feature_report
#endif
SDL_hid_send_feature_report:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5960(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5960(%rip)
2:
  pushq $745
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_set_nonblocking
  .p2align 4
  .type SDL_hid_set_nonblocking, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_set_nonblocking
#endif
SDL_hid_set_nonblocking:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5968(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5968(%rip)
2:
  pushq $746
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_hid_write
  .p2align 4
  .type SDL_hid_write, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_hid_write
#endif
SDL_hid_write:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5976(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5976(%rip)
2:
  pushq $747
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_iconv
  .p2align 4
  .type SDL_iconv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_iconv
#endif
SDL_iconv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5984(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5984(%rip)
2:
  pushq $748
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_iconv_close
  .p2align 4
  .type SDL_iconv_close, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_iconv_close
#endif
SDL_iconv_close:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+5992(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+5992(%rip)
2:
  pushq $749
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_iconv_open
  .p2align 4
  .type SDL_iconv_open, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_iconv_open
#endif
SDL_iconv_open:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6000(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6000(%rip)
2:
  pushq $750
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_iconv_string
  .p2align 4
  .type SDL_iconv_string, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_iconv_string
#endif
SDL_iconv_string:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6008(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6008(%rip)
2:
  pushq $751
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isalnum
  .p2align 4
  .type SDL_isalnum, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isalnum
#endif
SDL_isalnum:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6016(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6016(%rip)
2:
  pushq $752
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isalpha
  .p2align 4
  .type SDL_isalpha, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isalpha
#endif
SDL_isalpha:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6024(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6024(%rip)
2:
  pushq $753
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isblank
  .p2align 4
  .type SDL_isblank, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isblank
#endif
SDL_isblank:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6032(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6032(%rip)
2:
  pushq $754
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_iscntrl
  .p2align 4
  .type SDL_iscntrl, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_iscntrl
#endif
SDL_iscntrl:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6040(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6040(%rip)
2:
  pushq $755
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isdigit
  .p2align 4
  .type SDL_isdigit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isdigit
#endif
SDL_isdigit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6048(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6048(%rip)
2:
  pushq $756
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isgraph
  .p2align 4
  .type SDL_isgraph, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isgraph
#endif
SDL_isgraph:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6056(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6056(%rip)
2:
  pushq $757
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_islower
  .p2align 4
  .type SDL_islower, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_islower
#endif
SDL_islower:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6064(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6064(%rip)
2:
  pushq $758
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isprint
  .p2align 4
  .type SDL_isprint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isprint
#endif
SDL_isprint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6072(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6072(%rip)
2:
  pushq $759
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ispunct
  .p2align 4
  .type SDL_ispunct, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ispunct
#endif
SDL_ispunct:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6080(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6080(%rip)
2:
  pushq $760
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isspace
  .p2align 4
  .type SDL_isspace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isspace
#endif
SDL_isspace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6088(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6088(%rip)
2:
  pushq $761
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isupper
  .p2align 4
  .type SDL_isupper, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isupper
#endif
SDL_isupper:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6096(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6096(%rip)
2:
  pushq $762
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_isxdigit
  .p2align 4
  .type SDL_isxdigit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_isxdigit
#endif
SDL_isxdigit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6104(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6104(%rip)
2:
  pushq $763
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_itoa
  .p2align 4
  .type SDL_itoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_itoa
#endif
SDL_itoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6112(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6112(%rip)
2:
  pushq $764
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_lltoa
  .p2align 4
  .type SDL_lltoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_lltoa
#endif
SDL_lltoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6120(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6120(%rip)
2:
  pushq $765
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_log
  .p2align 4
  .type SDL_log, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_log
#endif
SDL_log:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6128(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6128(%rip)
2:
  pushq $766
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_log10
  .p2align 4
  .type SDL_log10, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_log10
#endif
SDL_log10:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6136(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6136(%rip)
2:
  pushq $767
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_log10f
  .p2align 4
  .type SDL_log10f, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_log10f
#endif
SDL_log10f:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6144(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6144(%rip)
2:
  pushq $768
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_logf
  .p2align 4
  .type SDL_logf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_logf
#endif
SDL_logf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6152(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6152(%rip)
2:
  pushq $769
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_lround
  .p2align 4
  .type SDL_lround, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_lround
#endif
SDL_lround:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6160(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6160(%rip)
2:
  pushq $770
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_lroundf
  .p2align 4
  .type SDL_lroundf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_lroundf
#endif
SDL_lroundf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6168(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6168(%rip)
2:
  pushq $771
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ltoa
  .p2align 4
  .type SDL_ltoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ltoa
#endif
SDL_ltoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6176(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6176(%rip)
2:
  pushq $772
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_malloc
  .p2align 4
  .type SDL_malloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_malloc
#endif
SDL_malloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6184(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6184(%rip)
2:
  pushq $773
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_memcmp
  .p2align 4
  .type SDL_memcmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_memcmp
#endif
SDL_memcmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6192(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6192(%rip)
2:
  pushq $774
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_memcpy
  .p2align 4
  .type SDL_memcpy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_memcpy
#endif
SDL_memcpy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6200(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6200(%rip)
2:
  pushq $775
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_memmove
  .p2align 4
  .type SDL_memmove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_memmove
#endif
SDL_memmove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6208(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6208(%rip)
2:
  pushq $776
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_memset
  .p2align 4
  .type SDL_memset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_memset
#endif
SDL_memset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6216(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6216(%rip)
2:
  pushq $777
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_pow
  .p2align 4
  .type SDL_pow, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_pow
#endif
SDL_pow:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6224(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6224(%rip)
2:
  pushq $778
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_powf
  .p2align 4
  .type SDL_powf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_powf
#endif
SDL_powf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6232(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6232(%rip)
2:
  pushq $779
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_qsort
  .p2align 4
  .type SDL_qsort, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_qsort
#endif
SDL_qsort:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6240(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6240(%rip)
2:
  pushq $780
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_realloc
  .p2align 4
  .type SDL_realloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_realloc
#endif
SDL_realloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6248(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6248(%rip)
2:
  pushq $781
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_round
  .p2align 4
  .type SDL_round, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_round
#endif
SDL_round:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6256(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6256(%rip)
2:
  pushq $782
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_roundf
  .p2align 4
  .type SDL_roundf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_roundf
#endif
SDL_roundf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6264(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6264(%rip)
2:
  pushq $783
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_scalbn
  .p2align 4
  .type SDL_scalbn, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_scalbn
#endif
SDL_scalbn:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6272(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6272(%rip)
2:
  pushq $784
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_scalbnf
  .p2align 4
  .type SDL_scalbnf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_scalbnf
#endif
SDL_scalbnf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6280(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6280(%rip)
2:
  pushq $785
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_setenv
  .p2align 4
  .type SDL_setenv, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_setenv
#endif
SDL_setenv:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6288(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6288(%rip)
2:
  pushq $786
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_sin
  .p2align 4
  .type SDL_sin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_sin
#endif
SDL_sin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6296(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6296(%rip)
2:
  pushq $787
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_sinf
  .p2align 4
  .type SDL_sinf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_sinf
#endif
SDL_sinf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6304(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6304(%rip)
2:
  pushq $788
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_snprintf
  .p2align 4
  .type SDL_snprintf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_snprintf
#endif
SDL_snprintf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6312(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6312(%rip)
2:
  pushq $789
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_sqrt
  .p2align 4
  .type SDL_sqrt, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_sqrt
#endif
SDL_sqrt:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6320(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6320(%rip)
2:
  pushq $790
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_sqrtf
  .p2align 4
  .type SDL_sqrtf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_sqrtf
#endif
SDL_sqrtf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6328(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6328(%rip)
2:
  pushq $791
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_sscanf
  .p2align 4
  .type SDL_sscanf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_sscanf
#endif
SDL_sscanf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6336(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6336(%rip)
2:
  pushq $792
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strcasecmp
  .p2align 4
  .type SDL_strcasecmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strcasecmp
#endif
SDL_strcasecmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6344(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6344(%rip)
2:
  pushq $793
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strcasestr
  .p2align 4
  .type SDL_strcasestr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strcasestr
#endif
SDL_strcasestr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6352(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6352(%rip)
2:
  pushq $794
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strchr
  .p2align 4
  .type SDL_strchr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strchr
#endif
SDL_strchr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6360(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6360(%rip)
2:
  pushq $795
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strcmp
  .p2align 4
  .type SDL_strcmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strcmp
#endif
SDL_strcmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6368(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6368(%rip)
2:
  pushq $796
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strdup
  .p2align 4
  .type SDL_strdup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strdup
#endif
SDL_strdup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6376(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6376(%rip)
2:
  pushq $797
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strlcat
  .p2align 4
  .type SDL_strlcat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strlcat
#endif
SDL_strlcat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6384(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6384(%rip)
2:
  pushq $798
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strlcpy
  .p2align 4
  .type SDL_strlcpy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strlcpy
#endif
SDL_strlcpy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6392(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6392(%rip)
2:
  pushq $799
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strlen
  .p2align 4
  .type SDL_strlen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strlen
#endif
SDL_strlen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6400(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6400(%rip)
2:
  pushq $800
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strlwr
  .p2align 4
  .type SDL_strlwr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strlwr
#endif
SDL_strlwr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6408(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6408(%rip)
2:
  pushq $801
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strncasecmp
  .p2align 4
  .type SDL_strncasecmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strncasecmp
#endif
SDL_strncasecmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6416(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6416(%rip)
2:
  pushq $802
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strncmp
  .p2align 4
  .type SDL_strncmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strncmp
#endif
SDL_strncmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6424(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6424(%rip)
2:
  pushq $803
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strrchr
  .p2align 4
  .type SDL_strrchr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strrchr
#endif
SDL_strrchr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6432(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6432(%rip)
2:
  pushq $804
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strrev
  .p2align 4
  .type SDL_strrev, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strrev
#endif
SDL_strrev:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6440(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6440(%rip)
2:
  pushq $805
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strstr
  .p2align 4
  .type SDL_strstr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strstr
#endif
SDL_strstr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6448(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6448(%rip)
2:
  pushq $806
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtod
  .p2align 4
  .type SDL_strtod, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtod
#endif
SDL_strtod:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6456(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6456(%rip)
2:
  pushq $807
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtokr
  .p2align 4
  .type SDL_strtokr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtokr
#endif
SDL_strtokr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6464(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6464(%rip)
2:
  pushq $808
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtol
  .p2align 4
  .type SDL_strtol, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtol
#endif
SDL_strtol:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6472(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6472(%rip)
2:
  pushq $809
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtoll
  .p2align 4
  .type SDL_strtoll, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtoll
#endif
SDL_strtoll:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6480(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6480(%rip)
2:
  pushq $810
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtoul
  .p2align 4
  .type SDL_strtoul, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtoul
#endif
SDL_strtoul:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6488(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6488(%rip)
2:
  pushq $811
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strtoull
  .p2align 4
  .type SDL_strtoull, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strtoull
#endif
SDL_strtoull:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6496(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6496(%rip)
2:
  pushq $812
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_strupr
  .p2align 4
  .type SDL_strupr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_strupr
#endif
SDL_strupr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6504(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6504(%rip)
2:
  pushq $813
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_tan
  .p2align 4
  .type SDL_tan, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_tan
#endif
SDL_tan:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6512(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6512(%rip)
2:
  pushq $814
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_tanf
  .p2align 4
  .type SDL_tanf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_tanf
#endif
SDL_tanf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6520(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6520(%rip)
2:
  pushq $815
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_tolower
  .p2align 4
  .type SDL_tolower, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_tolower
#endif
SDL_tolower:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6528(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6528(%rip)
2:
  pushq $816
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_toupper
  .p2align 4
  .type SDL_toupper, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_toupper
#endif
SDL_toupper:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6536(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6536(%rip)
2:
  pushq $817
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_trunc
  .p2align 4
  .type SDL_trunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_trunc
#endif
SDL_trunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6544(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6544(%rip)
2:
  pushq $818
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_truncf
  .p2align 4
  .type SDL_truncf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_truncf
#endif
SDL_truncf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6552(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6552(%rip)
2:
  pushq $819
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_uitoa
  .p2align 4
  .type SDL_uitoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_uitoa
#endif
SDL_uitoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6560(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6560(%rip)
2:
  pushq $820
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ulltoa
  .p2align 4
  .type SDL_ulltoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ulltoa
#endif
SDL_ulltoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6568(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6568(%rip)
2:
  pushq $821
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_ultoa
  .p2align 4
  .type SDL_ultoa, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_ultoa
#endif
SDL_ultoa:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6576(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6576(%rip)
2:
  pushq $822
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_utf8strlcpy
  .p2align 4
  .type SDL_utf8strlcpy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_utf8strlcpy
#endif
SDL_utf8strlcpy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6584(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6584(%rip)
2:
  pushq $823
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_utf8strlen
  .p2align 4
  .type SDL_utf8strlen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_utf8strlen
#endif
SDL_utf8strlen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6592(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6592(%rip)
2:
  pushq $824
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_utf8strnlen
  .p2align 4
  .type SDL_utf8strnlen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_utf8strnlen
#endif
SDL_utf8strnlen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6600(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6600(%rip)
2:
  pushq $825
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_vasprintf
  .p2align 4
  .type SDL_vasprintf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_vasprintf
#endif
SDL_vasprintf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6608(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6608(%rip)
2:
  pushq $826
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_vsnprintf
  .p2align 4
  .type SDL_vsnprintf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_vsnprintf
#endif
SDL_vsnprintf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6616(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6616(%rip)
2:
  pushq $827
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_vsscanf
  .p2align 4
  .type SDL_vsscanf, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_vsscanf
#endif
SDL_vsscanf:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6624(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6624(%rip)
2:
  pushq $828
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcscasecmp
  .p2align 4
  .type SDL_wcscasecmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcscasecmp
#endif
SDL_wcscasecmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6632(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6632(%rip)
2:
  pushq $829
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcscmp
  .p2align 4
  .type SDL_wcscmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcscmp
#endif
SDL_wcscmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6640(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6640(%rip)
2:
  pushq $830
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcsdup
  .p2align 4
  .type SDL_wcsdup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcsdup
#endif
SDL_wcsdup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6648(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6648(%rip)
2:
  pushq $831
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcslcat
  .p2align 4
  .type SDL_wcslcat, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcslcat
#endif
SDL_wcslcat:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6656(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6656(%rip)
2:
  pushq $832
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcslcpy
  .p2align 4
  .type SDL_wcslcpy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcslcpy
#endif
SDL_wcslcpy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6664(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6664(%rip)
2:
  pushq $833
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcslen
  .p2align 4
  .type SDL_wcslen, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcslen
#endif
SDL_wcslen:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6672(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6672(%rip)
2:
  pushq $834
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcsncasecmp
  .p2align 4
  .type SDL_wcsncasecmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcsncasecmp
#endif
SDL_wcsncasecmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6680(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6680(%rip)
2:
  pushq $835
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcsncmp
  .p2align 4
  .type SDL_wcsncmp, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcsncmp
#endif
SDL_wcsncmp:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6688(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6688(%rip)
2:
  pushq $836
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl SDL_wcsstr
  .p2align 4
  .type SDL_wcsstr, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden SDL_wcsstr
#endif
SDL_wcsstr:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libSDL2_so_tramp_table+6696(%rip)
  je 2f
1:
  jmp *_libSDL2_so_tramp_table+6696(%rip)
2:
  pushq $837
  .cfi_adjust_cfa_offset 8
  call _libSDL2_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

