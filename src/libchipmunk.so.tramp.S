/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .data

  .globl _libchipmunk_so_tramp_table
  .hidden _libchipmunk_so_tramp_table
  .align 8
_libchipmunk_so_tramp_table:
  .zero 3296

  .text

  .globl _libchipmunk_so_tramp_resolve
  .hidden _libchipmunk_so_tramp_resolve

  .globl _libchipmunk_so_save_regs_and_resolve
  .hidden _libchipmunk_so_save_regs_and_resolve
  .type _libchipmunk_so_save_regs_and_resolve, %function
_libchipmunk_so_save_regs_and_resolve:
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
  call _libchipmunk_so_tramp_resolve

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

  .globl cpArbiterApplyCachedImpulse
  .p2align 4
  .type cpArbiterApplyCachedImpulse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterApplyCachedImpulse
#endif
cpArbiterApplyCachedImpulse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+0(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+0(%rip)
2:
  pushq $0
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterApplyImpulse
  .p2align 4
  .type cpArbiterApplyImpulse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterApplyImpulse
#endif
cpArbiterApplyImpulse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+8(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+8(%rip)
2:
  pushq $1
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardBeginA
  .p2align 4
  .type cpArbiterCallWildcardBeginA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardBeginA
#endif
cpArbiterCallWildcardBeginA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+16(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+16(%rip)
2:
  pushq $2
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardBeginB
  .p2align 4
  .type cpArbiterCallWildcardBeginB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardBeginB
#endif
cpArbiterCallWildcardBeginB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+24(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+24(%rip)
2:
  pushq $3
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardPostSolveA
  .p2align 4
  .type cpArbiterCallWildcardPostSolveA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardPostSolveA
#endif
cpArbiterCallWildcardPostSolveA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+32(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+32(%rip)
2:
  pushq $4
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardPostSolveB
  .p2align 4
  .type cpArbiterCallWildcardPostSolveB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardPostSolveB
#endif
cpArbiterCallWildcardPostSolveB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+40(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+40(%rip)
2:
  pushq $5
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardPreSolveA
  .p2align 4
  .type cpArbiterCallWildcardPreSolveA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardPreSolveA
#endif
cpArbiterCallWildcardPreSolveA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+48(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+48(%rip)
2:
  pushq $6
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardPreSolveB
  .p2align 4
  .type cpArbiterCallWildcardPreSolveB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardPreSolveB
#endif
cpArbiterCallWildcardPreSolveB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+56(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+56(%rip)
2:
  pushq $7
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardSeparateA
  .p2align 4
  .type cpArbiterCallWildcardSeparateA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardSeparateA
#endif
cpArbiterCallWildcardSeparateA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+64(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+64(%rip)
2:
  pushq $8
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterCallWildcardSeparateB
  .p2align 4
  .type cpArbiterCallWildcardSeparateB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterCallWildcardSeparateB
#endif
cpArbiterCallWildcardSeparateB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+72(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+72(%rip)
2:
  pushq $9
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetBodies
  .p2align 4
  .type cpArbiterGetBodies, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetBodies
#endif
cpArbiterGetBodies:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+80(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+80(%rip)
2:
  pushq $10
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetContactPointSet
  .p2align 4
  .type cpArbiterGetContactPointSet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetContactPointSet
#endif
cpArbiterGetContactPointSet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+88(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+88(%rip)
2:
  pushq $11
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetCount
  .p2align 4
  .type cpArbiterGetCount, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetCount
#endif
cpArbiterGetCount:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+96(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+96(%rip)
2:
  pushq $12
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetDepth
  .p2align 4
  .type cpArbiterGetDepth, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetDepth
#endif
cpArbiterGetDepth:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+104(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+104(%rip)
2:
  pushq $13
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetFriction
  .p2align 4
  .type cpArbiterGetFriction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetFriction
#endif
cpArbiterGetFriction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+112(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+112(%rip)
2:
  pushq $14
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetNormal
  .p2align 4
  .type cpArbiterGetNormal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetNormal
#endif
cpArbiterGetNormal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+120(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+120(%rip)
2:
  pushq $15
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetPointA
  .p2align 4
  .type cpArbiterGetPointA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetPointA
#endif
cpArbiterGetPointA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+128(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+128(%rip)
2:
  pushq $16
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetPointB
  .p2align 4
  .type cpArbiterGetPointB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetPointB
#endif
cpArbiterGetPointB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+136(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+136(%rip)
2:
  pushq $17
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetRestitution
  .p2align 4
  .type cpArbiterGetRestitution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetRestitution
#endif
cpArbiterGetRestitution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+144(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+144(%rip)
2:
  pushq $18
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetShapes
  .p2align 4
  .type cpArbiterGetShapes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetShapes
#endif
cpArbiterGetShapes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+152(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+152(%rip)
2:
  pushq $19
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetSurfaceVelocity
  .p2align 4
  .type cpArbiterGetSurfaceVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetSurfaceVelocity
#endif
cpArbiterGetSurfaceVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+160(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+160(%rip)
2:
  pushq $20
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterGetUserData
  .p2align 4
  .type cpArbiterGetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterGetUserData
#endif
cpArbiterGetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+168(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+168(%rip)
2:
  pushq $21
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterIgnore
  .p2align 4
  .type cpArbiterIgnore, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterIgnore
#endif
cpArbiterIgnore:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+176(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+176(%rip)
2:
  pushq $22
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterInit
  .p2align 4
  .type cpArbiterInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterInit
#endif
cpArbiterInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+184(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+184(%rip)
2:
  pushq $23
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterIsFirstContact
  .p2align 4
  .type cpArbiterIsFirstContact, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterIsFirstContact
#endif
cpArbiterIsFirstContact:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+192(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+192(%rip)
2:
  pushq $24
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterIsRemoval
  .p2align 4
  .type cpArbiterIsRemoval, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterIsRemoval
#endif
cpArbiterIsRemoval:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+200(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+200(%rip)
2:
  pushq $25
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterPreStep
  .p2align 4
  .type cpArbiterPreStep, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterPreStep
#endif
cpArbiterPreStep:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+208(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+208(%rip)
2:
  pushq $26
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterSetContactPointSet
  .p2align 4
  .type cpArbiterSetContactPointSet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterSetContactPointSet
#endif
cpArbiterSetContactPointSet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+216(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+216(%rip)
2:
  pushq $27
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterSetFriction
  .p2align 4
  .type cpArbiterSetFriction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterSetFriction
#endif
cpArbiterSetFriction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+224(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+224(%rip)
2:
  pushq $28
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterSetRestitution
  .p2align 4
  .type cpArbiterSetRestitution, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterSetRestitution
#endif
cpArbiterSetRestitution:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+232(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+232(%rip)
2:
  pushq $29
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterSetSurfaceVelocity
  .p2align 4
  .type cpArbiterSetSurfaceVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterSetSurfaceVelocity
#endif
cpArbiterSetSurfaceVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+240(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+240(%rip)
2:
  pushq $30
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterSetUserData
  .p2align 4
  .type cpArbiterSetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterSetUserData
#endif
cpArbiterSetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+248(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+248(%rip)
2:
  pushq $31
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterTotalImpulse
  .p2align 4
  .type cpArbiterTotalImpulse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterTotalImpulse
#endif
cpArbiterTotalImpulse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+256(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+256(%rip)
2:
  pushq $32
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterTotalKE
  .p2align 4
  .type cpArbiterTotalKE, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterTotalKE
#endif
cpArbiterTotalKE:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+264(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+264(%rip)
2:
  pushq $33
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterUnthread
  .p2align 4
  .type cpArbiterUnthread, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterUnthread
#endif
cpArbiterUnthread:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+272(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+272(%rip)
2:
  pushq $34
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArbiterUpdate
  .p2align 4
  .type cpArbiterUpdate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArbiterUpdate
#endif
cpArbiterUpdate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+280(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+280(%rip)
2:
  pushq $35
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpAreaForCircle
  .p2align 4
  .type cpAreaForCircle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpAreaForCircle
#endif
cpAreaForCircle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+288(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+288(%rip)
2:
  pushq $36
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpAreaForPoly
  .p2align 4
  .type cpAreaForPoly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpAreaForPoly
#endif
cpAreaForPoly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+296(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+296(%rip)
2:
  pushq $37
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpAreaForSegment
  .p2align 4
  .type cpAreaForSegment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpAreaForSegment
#endif
cpAreaForSegment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+304(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+304(%rip)
2:
  pushq $38
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayContains
  .p2align 4
  .type cpArrayContains, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayContains
#endif
cpArrayContains:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+312(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+312(%rip)
2:
  pushq $39
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayDeleteObj
  .p2align 4
  .type cpArrayDeleteObj, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayDeleteObj
#endif
cpArrayDeleteObj:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+320(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+320(%rip)
2:
  pushq $40
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayFree
  .p2align 4
  .type cpArrayFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayFree
#endif
cpArrayFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+328(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+328(%rip)
2:
  pushq $41
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayFreeEach
  .p2align 4
  .type cpArrayFreeEach, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayFreeEach
#endif
cpArrayFreeEach:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+336(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+336(%rip)
2:
  pushq $42
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayNew
  .p2align 4
  .type cpArrayNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayNew
#endif
cpArrayNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+344(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+344(%rip)
2:
  pushq $43
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayPop
  .p2align 4
  .type cpArrayPop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayPop
#endif
cpArrayPop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+352(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+352(%rip)
2:
  pushq $44
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpArrayPush
  .p2align 4
  .type cpArrayPush, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpArrayPush
#endif
cpArrayPush:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+360(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+360(%rip)
2:
  pushq $45
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBBTreeAlloc
  .p2align 4
  .type cpBBTreeAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBBTreeAlloc
#endif
cpBBTreeAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+368(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+368(%rip)
2:
  pushq $46
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBBTreeInit
  .p2align 4
  .type cpBBTreeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBBTreeInit
#endif
cpBBTreeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+376(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+376(%rip)
2:
  pushq $47
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBBTreeNew
  .p2align 4
  .type cpBBTreeNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBBTreeNew
#endif
cpBBTreeNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+384(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+384(%rip)
2:
  pushq $48
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBBTreeOptimize
  .p2align 4
  .type cpBBTreeOptimize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBBTreeOptimize
#endif
cpBBTreeOptimize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+392(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+392(%rip)
2:
  pushq $49
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBBTreeSetVelocityFunc
  .p2align 4
  .type cpBBTreeSetVelocityFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBBTreeSetVelocityFunc
#endif
cpBBTreeSetVelocityFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+400(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+400(%rip)
2:
  pushq $50
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyAccumulateMassFromShapes
  .p2align 4
  .type cpBodyAccumulateMassFromShapes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyAccumulateMassFromShapes
#endif
cpBodyAccumulateMassFromShapes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+408(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+408(%rip)
2:
  pushq $51
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyActivate
  .p2align 4
  .type cpBodyActivate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyActivate
#endif
cpBodyActivate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+416(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+416(%rip)
2:
  pushq $52
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyActivateStatic
  .p2align 4
  .type cpBodyActivateStatic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyActivateStatic
#endif
cpBodyActivateStatic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+424(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+424(%rip)
2:
  pushq $53
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyAddShape
  .p2align 4
  .type cpBodyAddShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyAddShape
#endif
cpBodyAddShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+432(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+432(%rip)
2:
  pushq $54
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyAlloc
  .p2align 4
  .type cpBodyAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyAlloc
#endif
cpBodyAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+440(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+440(%rip)
2:
  pushq $55
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyApplyForceAtLocalPoint
  .p2align 4
  .type cpBodyApplyForceAtLocalPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyApplyForceAtLocalPoint
#endif
cpBodyApplyForceAtLocalPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+448(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+448(%rip)
2:
  pushq $56
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyApplyForceAtWorldPoint
  .p2align 4
  .type cpBodyApplyForceAtWorldPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyApplyForceAtWorldPoint
#endif
cpBodyApplyForceAtWorldPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+456(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+456(%rip)
2:
  pushq $57
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyApplyImpulseAtLocalPoint
  .p2align 4
  .type cpBodyApplyImpulseAtLocalPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyApplyImpulseAtLocalPoint
#endif
cpBodyApplyImpulseAtLocalPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+464(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+464(%rip)
2:
  pushq $58
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyApplyImpulseAtWorldPoint
  .p2align 4
  .type cpBodyApplyImpulseAtWorldPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyApplyImpulseAtWorldPoint
#endif
cpBodyApplyImpulseAtWorldPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+472(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+472(%rip)
2:
  pushq $59
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyDestroy
  .p2align 4
  .type cpBodyDestroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyDestroy
#endif
cpBodyDestroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+480(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+480(%rip)
2:
  pushq $60
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyEachArbiter
  .p2align 4
  .type cpBodyEachArbiter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyEachArbiter
#endif
cpBodyEachArbiter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+488(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+488(%rip)
2:
  pushq $61
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyEachConstraint
  .p2align 4
  .type cpBodyEachConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyEachConstraint
#endif
cpBodyEachConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+496(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+496(%rip)
2:
  pushq $62
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyEachShape
  .p2align 4
  .type cpBodyEachShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyEachShape
#endif
cpBodyEachShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+504(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+504(%rip)
2:
  pushq $63
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyFree
  .p2align 4
  .type cpBodyFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyFree
#endif
cpBodyFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+512(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+512(%rip)
2:
  pushq $64
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetAngle
  .p2align 4
  .type cpBodyGetAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetAngle
#endif
cpBodyGetAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+520(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+520(%rip)
2:
  pushq $65
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetAngularVelocity
  .p2align 4
  .type cpBodyGetAngularVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetAngularVelocity
#endif
cpBodyGetAngularVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+528(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+528(%rip)
2:
  pushq $66
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetCenterOfGravity
  .p2align 4
  .type cpBodyGetCenterOfGravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetCenterOfGravity
#endif
cpBodyGetCenterOfGravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+536(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+536(%rip)
2:
  pushq $67
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetForce
  .p2align 4
  .type cpBodyGetForce, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetForce
#endif
cpBodyGetForce:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+544(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+544(%rip)
2:
  pushq $68
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetMass
  .p2align 4
  .type cpBodyGetMass, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetMass
#endif
cpBodyGetMass:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+552(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+552(%rip)
2:
  pushq $69
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetMoment
  .p2align 4
  .type cpBodyGetMoment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetMoment
#endif
cpBodyGetMoment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+560(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+560(%rip)
2:
  pushq $70
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetPosition
  .p2align 4
  .type cpBodyGetPosition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetPosition
#endif
cpBodyGetPosition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+568(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+568(%rip)
2:
  pushq $71
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetRotation
  .p2align 4
  .type cpBodyGetRotation, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetRotation
#endif
cpBodyGetRotation:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+576(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+576(%rip)
2:
  pushq $72
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetSpace
  .p2align 4
  .type cpBodyGetSpace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetSpace
#endif
cpBodyGetSpace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+584(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+584(%rip)
2:
  pushq $73
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetTorque
  .p2align 4
  .type cpBodyGetTorque, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetTorque
#endif
cpBodyGetTorque:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+592(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+592(%rip)
2:
  pushq $74
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetType
  .p2align 4
  .type cpBodyGetType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetType
#endif
cpBodyGetType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+600(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+600(%rip)
2:
  pushq $75
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetUserData
  .p2align 4
  .type cpBodyGetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetUserData
#endif
cpBodyGetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+608(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+608(%rip)
2:
  pushq $76
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetVelocity
  .p2align 4
  .type cpBodyGetVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetVelocity
#endif
cpBodyGetVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+616(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+616(%rip)
2:
  pushq $77
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetVelocityAtLocalPoint
  .p2align 4
  .type cpBodyGetVelocityAtLocalPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetVelocityAtLocalPoint
#endif
cpBodyGetVelocityAtLocalPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+624(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+624(%rip)
2:
  pushq $78
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyGetVelocityAtWorldPoint
  .p2align 4
  .type cpBodyGetVelocityAtWorldPoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyGetVelocityAtWorldPoint
#endif
cpBodyGetVelocityAtWorldPoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+632(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+632(%rip)
2:
  pushq $79
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyInit
  .p2align 4
  .type cpBodyInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyInit
#endif
cpBodyInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+640(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+640(%rip)
2:
  pushq $80
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyIsSleeping
  .p2align 4
  .type cpBodyIsSleeping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyIsSleeping
#endif
cpBodyIsSleeping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+648(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+648(%rip)
2:
  pushq $81
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyKineticEnergy
  .p2align 4
  .type cpBodyKineticEnergy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyKineticEnergy
#endif
cpBodyKineticEnergy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+656(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+656(%rip)
2:
  pushq $82
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyLocalToWorld
  .p2align 4
  .type cpBodyLocalToWorld, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyLocalToWorld
#endif
cpBodyLocalToWorld:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+664(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+664(%rip)
2:
  pushq $83
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyNew
  .p2align 4
  .type cpBodyNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyNew
#endif
cpBodyNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+672(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+672(%rip)
2:
  pushq $84
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyNewKinematic
  .p2align 4
  .type cpBodyNewKinematic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyNewKinematic
#endif
cpBodyNewKinematic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+680(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+680(%rip)
2:
  pushq $85
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyNewStatic
  .p2align 4
  .type cpBodyNewStatic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyNewStatic
#endif
cpBodyNewStatic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+688(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+688(%rip)
2:
  pushq $86
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyRemoveConstraint
  .p2align 4
  .type cpBodyRemoveConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyRemoveConstraint
#endif
cpBodyRemoveConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+696(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+696(%rip)
2:
  pushq $87
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyRemoveShape
  .p2align 4
  .type cpBodyRemoveShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyRemoveShape
#endif
cpBodyRemoveShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+704(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+704(%rip)
2:
  pushq $88
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetAngle
  .p2align 4
  .type cpBodySetAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetAngle
#endif
cpBodySetAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+712(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+712(%rip)
2:
  pushq $89
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetAngularVelocity
  .p2align 4
  .type cpBodySetAngularVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetAngularVelocity
#endif
cpBodySetAngularVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+720(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+720(%rip)
2:
  pushq $90
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetCenterOfGravity
  .p2align 4
  .type cpBodySetCenterOfGravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetCenterOfGravity
#endif
cpBodySetCenterOfGravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+728(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+728(%rip)
2:
  pushq $91
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetForce
  .p2align 4
  .type cpBodySetForce, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetForce
#endif
cpBodySetForce:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+736(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+736(%rip)
2:
  pushq $92
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetMass
  .p2align 4
  .type cpBodySetMass, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetMass
#endif
cpBodySetMass:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+744(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+744(%rip)
2:
  pushq $93
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetMoment
  .p2align 4
  .type cpBodySetMoment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetMoment
#endif
cpBodySetMoment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+752(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+752(%rip)
2:
  pushq $94
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetPosition
  .p2align 4
  .type cpBodySetPosition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetPosition
#endif
cpBodySetPosition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+760(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+760(%rip)
2:
  pushq $95
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetPositionUpdateFunc
  .p2align 4
  .type cpBodySetPositionUpdateFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetPositionUpdateFunc
#endif
cpBodySetPositionUpdateFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+768(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+768(%rip)
2:
  pushq $96
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetTorque
  .p2align 4
  .type cpBodySetTorque, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetTorque
#endif
cpBodySetTorque:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+776(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+776(%rip)
2:
  pushq $97
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetType
  .p2align 4
  .type cpBodySetType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetType
#endif
cpBodySetType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+784(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+784(%rip)
2:
  pushq $98
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetUserData
  .p2align 4
  .type cpBodySetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetUserData
#endif
cpBodySetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+792(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+792(%rip)
2:
  pushq $99
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetVelocity
  .p2align 4
  .type cpBodySetVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetVelocity
#endif
cpBodySetVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+800(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+800(%rip)
2:
  pushq $100
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySetVelocityUpdateFunc
  .p2align 4
  .type cpBodySetVelocityUpdateFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySetVelocityUpdateFunc
#endif
cpBodySetVelocityUpdateFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+808(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+808(%rip)
2:
  pushq $101
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySleep
  .p2align 4
  .type cpBodySleep, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySleep
#endif
cpBodySleep:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+816(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+816(%rip)
2:
  pushq $102
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodySleepWithGroup
  .p2align 4
  .type cpBodySleepWithGroup, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodySleepWithGroup
#endif
cpBodySleepWithGroup:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+824(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+824(%rip)
2:
  pushq $103
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyUpdatePosition
  .p2align 4
  .type cpBodyUpdatePosition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyUpdatePosition
#endif
cpBodyUpdatePosition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+832(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+832(%rip)
2:
  pushq $104
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyUpdateVelocity
  .p2align 4
  .type cpBodyUpdateVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyUpdateVelocity
#endif
cpBodyUpdateVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+840(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+840(%rip)
2:
  pushq $105
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBodyWorldToLocal
  .p2align 4
  .type cpBodyWorldToLocal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBodyWorldToLocal
#endif
cpBodyWorldToLocal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+848(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+848(%rip)
2:
  pushq $106
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBoxShapeInit
  .p2align 4
  .type cpBoxShapeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBoxShapeInit
#endif
cpBoxShapeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+856(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+856(%rip)
2:
  pushq $107
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBoxShapeInit2
  .p2align 4
  .type cpBoxShapeInit2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBoxShapeInit2
#endif
cpBoxShapeInit2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+864(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+864(%rip)
2:
  pushq $108
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBoxShapeNew
  .p2align 4
  .type cpBoxShapeNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBoxShapeNew
#endif
cpBoxShapeNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+872(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+872(%rip)
2:
  pushq $109
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpBoxShapeNew2
  .p2align 4
  .type cpBoxShapeNew2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpBoxShapeNew2
#endif
cpBoxShapeNew2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+880(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+880(%rip)
2:
  pushq $110
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCentroidForPoly
  .p2align 4
  .type cpCentroidForPoly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCentroidForPoly
#endif
cpCentroidForPoly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+888(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+888(%rip)
2:
  pushq $111
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCheckAxis
  .p2align 4
  .type cpCheckAxis, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCheckAxis
#endif
cpCheckAxis:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+896(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+896(%rip)
2:
  pushq $112
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCheckPointGreater
  .p2align 4
  .type cpCheckPointGreater, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCheckPointGreater
#endif
cpCheckPointGreater:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+904(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+904(%rip)
2:
  pushq $113
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeAlloc
  .p2align 4
  .type cpCircleShapeAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeAlloc
#endif
cpCircleShapeAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+912(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+912(%rip)
2:
  pushq $114
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeGetOffset
  .p2align 4
  .type cpCircleShapeGetOffset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeGetOffset
#endif
cpCircleShapeGetOffset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+920(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+920(%rip)
2:
  pushq $115
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeGetRadius
  .p2align 4
  .type cpCircleShapeGetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeGetRadius
#endif
cpCircleShapeGetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+928(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+928(%rip)
2:
  pushq $116
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeInit
  .p2align 4
  .type cpCircleShapeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeInit
#endif
cpCircleShapeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+936(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+936(%rip)
2:
  pushq $117
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeNew
  .p2align 4
  .type cpCircleShapeNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeNew
#endif
cpCircleShapeNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+944(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+944(%rip)
2:
  pushq $118
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeSetOffset
  .p2align 4
  .type cpCircleShapeSetOffset, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeSetOffset
#endif
cpCircleShapeSetOffset:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+952(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+952(%rip)
2:
  pushq $119
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCircleShapeSetRadius
  .p2align 4
  .type cpCircleShapeSetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCircleShapeSetRadius
#endif
cpCircleShapeSetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+960(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+960(%rip)
2:
  pushq $120
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpCollide
  .p2align 4
  .type cpCollide, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpCollide
#endif
cpCollide:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+968(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+968(%rip)
2:
  pushq $121
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintDestroy
  .p2align 4
  .type cpConstraintDestroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintDestroy
#endif
cpConstraintDestroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+976(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+976(%rip)
2:
  pushq $122
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintFree
  .p2align 4
  .type cpConstraintFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintFree
#endif
cpConstraintFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+984(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+984(%rip)
2:
  pushq $123
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetBodyA
  .p2align 4
  .type cpConstraintGetBodyA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetBodyA
#endif
cpConstraintGetBodyA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+992(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+992(%rip)
2:
  pushq $124
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetBodyB
  .p2align 4
  .type cpConstraintGetBodyB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetBodyB
#endif
cpConstraintGetBodyB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1000(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1000(%rip)
2:
  pushq $125
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetCollideBodies
  .p2align 4
  .type cpConstraintGetCollideBodies, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetCollideBodies
#endif
cpConstraintGetCollideBodies:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1008(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1008(%rip)
2:
  pushq $126
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetErrorBias
  .p2align 4
  .type cpConstraintGetErrorBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetErrorBias
#endif
cpConstraintGetErrorBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1016(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1016(%rip)
2:
  pushq $127
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetImpulse
  .p2align 4
  .type cpConstraintGetImpulse, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetImpulse
#endif
cpConstraintGetImpulse:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1024(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1024(%rip)
2:
  pushq $128
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetMaxBias
  .p2align 4
  .type cpConstraintGetMaxBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetMaxBias
#endif
cpConstraintGetMaxBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1032(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1032(%rip)
2:
  pushq $129
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetMaxForce
  .p2align 4
  .type cpConstraintGetMaxForce, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetMaxForce
#endif
cpConstraintGetMaxForce:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1040(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1040(%rip)
2:
  pushq $130
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetPostSolveFunc
  .p2align 4
  .type cpConstraintGetPostSolveFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetPostSolveFunc
#endif
cpConstraintGetPostSolveFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1048(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1048(%rip)
2:
  pushq $131
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetPreSolveFunc
  .p2align 4
  .type cpConstraintGetPreSolveFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetPreSolveFunc
#endif
cpConstraintGetPreSolveFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1056(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1056(%rip)
2:
  pushq $132
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetSpace
  .p2align 4
  .type cpConstraintGetSpace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetSpace
#endif
cpConstraintGetSpace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1064(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1064(%rip)
2:
  pushq $133
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintGetUserData
  .p2align 4
  .type cpConstraintGetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintGetUserData
#endif
cpConstraintGetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1072(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1072(%rip)
2:
  pushq $134
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintInit
  .p2align 4
  .type cpConstraintInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintInit
#endif
cpConstraintInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1080(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1080(%rip)
2:
  pushq $135
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsDampedRotarySpring
  .p2align 4
  .type cpConstraintIsDampedRotarySpring, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsDampedRotarySpring
#endif
cpConstraintIsDampedRotarySpring:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1088(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1088(%rip)
2:
  pushq $136
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsDampedSpring
  .p2align 4
  .type cpConstraintIsDampedSpring, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsDampedSpring
#endif
cpConstraintIsDampedSpring:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1096(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1096(%rip)
2:
  pushq $137
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsGearJoint
  .p2align 4
  .type cpConstraintIsGearJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsGearJoint
#endif
cpConstraintIsGearJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1104(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1104(%rip)
2:
  pushq $138
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsGrooveJoint
  .p2align 4
  .type cpConstraintIsGrooveJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsGrooveJoint
#endif
cpConstraintIsGrooveJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1112(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1112(%rip)
2:
  pushq $139
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsPinJoint
  .p2align 4
  .type cpConstraintIsPinJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsPinJoint
#endif
cpConstraintIsPinJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1120(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1120(%rip)
2:
  pushq $140
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsPivotJoint
  .p2align 4
  .type cpConstraintIsPivotJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsPivotJoint
#endif
cpConstraintIsPivotJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1128(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1128(%rip)
2:
  pushq $141
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsRatchetJoint
  .p2align 4
  .type cpConstraintIsRatchetJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsRatchetJoint
#endif
cpConstraintIsRatchetJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1136(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1136(%rip)
2:
  pushq $142
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsRotaryLimitJoint
  .p2align 4
  .type cpConstraintIsRotaryLimitJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsRotaryLimitJoint
#endif
cpConstraintIsRotaryLimitJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1144(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1144(%rip)
2:
  pushq $143
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsSimpleMotor
  .p2align 4
  .type cpConstraintIsSimpleMotor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsSimpleMotor
#endif
cpConstraintIsSimpleMotor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1152(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1152(%rip)
2:
  pushq $144
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintIsSlideJoint
  .p2align 4
  .type cpConstraintIsSlideJoint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintIsSlideJoint
#endif
cpConstraintIsSlideJoint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1160(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1160(%rip)
2:
  pushq $145
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetCollideBodies
  .p2align 4
  .type cpConstraintSetCollideBodies, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetCollideBodies
#endif
cpConstraintSetCollideBodies:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1168(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1168(%rip)
2:
  pushq $146
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetErrorBias
  .p2align 4
  .type cpConstraintSetErrorBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetErrorBias
#endif
cpConstraintSetErrorBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1176(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1176(%rip)
2:
  pushq $147
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetMaxBias
  .p2align 4
  .type cpConstraintSetMaxBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetMaxBias
#endif
cpConstraintSetMaxBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1184(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1184(%rip)
2:
  pushq $148
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetMaxForce
  .p2align 4
  .type cpConstraintSetMaxForce, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetMaxForce
#endif
cpConstraintSetMaxForce:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1192(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1192(%rip)
2:
  pushq $149
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetPostSolveFunc
  .p2align 4
  .type cpConstraintSetPostSolveFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetPostSolveFunc
#endif
cpConstraintSetPostSolveFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1200(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1200(%rip)
2:
  pushq $150
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetPreSolveFunc
  .p2align 4
  .type cpConstraintSetPreSolveFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetPreSolveFunc
#endif
cpConstraintSetPreSolveFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1208(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1208(%rip)
2:
  pushq $151
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConstraintSetUserData
  .p2align 4
  .type cpConstraintSetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConstraintSetUserData
#endif
cpConstraintSetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1216(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1216(%rip)
2:
  pushq $152
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpContactBufferGetArray
  .p2align 4
  .type cpContactBufferGetArray, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpContactBufferGetArray
#endif
cpContactBufferGetArray:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1224(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1224(%rip)
2:
  pushq $153
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpConvexHull
  .p2align 4
  .type cpConvexHull, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpConvexHull
#endif
cpConvexHull:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1232(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1232(%rip)
2:
  pushq $154
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringAlloc
  .p2align 4
  .type cpDampedRotarySpringAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringAlloc
#endif
cpDampedRotarySpringAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1240(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1240(%rip)
2:
  pushq $155
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringGetDamping
  .p2align 4
  .type cpDampedRotarySpringGetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringGetDamping
#endif
cpDampedRotarySpringGetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1248(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1248(%rip)
2:
  pushq $156
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringGetRestAngle
  .p2align 4
  .type cpDampedRotarySpringGetRestAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringGetRestAngle
#endif
cpDampedRotarySpringGetRestAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1256(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1256(%rip)
2:
  pushq $157
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringGetSpringTorqueFunc
  .p2align 4
  .type cpDampedRotarySpringGetSpringTorqueFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringGetSpringTorqueFunc
#endif
cpDampedRotarySpringGetSpringTorqueFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1264(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1264(%rip)
2:
  pushq $158
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringGetStiffness
  .p2align 4
  .type cpDampedRotarySpringGetStiffness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringGetStiffness
#endif
cpDampedRotarySpringGetStiffness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1272(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1272(%rip)
2:
  pushq $159
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringInit
  .p2align 4
  .type cpDampedRotarySpringInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringInit
#endif
cpDampedRotarySpringInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1280(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1280(%rip)
2:
  pushq $160
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringNew
  .p2align 4
  .type cpDampedRotarySpringNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringNew
#endif
cpDampedRotarySpringNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1288(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1288(%rip)
2:
  pushq $161
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringSetDamping
  .p2align 4
  .type cpDampedRotarySpringSetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringSetDamping
#endif
cpDampedRotarySpringSetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1296(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1296(%rip)
2:
  pushq $162
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringSetRestAngle
  .p2align 4
  .type cpDampedRotarySpringSetRestAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringSetRestAngle
#endif
cpDampedRotarySpringSetRestAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1304(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1304(%rip)
2:
  pushq $163
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringSetSpringTorqueFunc
  .p2align 4
  .type cpDampedRotarySpringSetSpringTorqueFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringSetSpringTorqueFunc
#endif
cpDampedRotarySpringSetSpringTorqueFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1312(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1312(%rip)
2:
  pushq $164
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedRotarySpringSetStiffness
  .p2align 4
  .type cpDampedRotarySpringSetStiffness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedRotarySpringSetStiffness
#endif
cpDampedRotarySpringSetStiffness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1320(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1320(%rip)
2:
  pushq $165
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringAlloc
  .p2align 4
  .type cpDampedSpringAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringAlloc
#endif
cpDampedSpringAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1328(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1328(%rip)
2:
  pushq $166
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetAnchorA
  .p2align 4
  .type cpDampedSpringGetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetAnchorA
#endif
cpDampedSpringGetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1336(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1336(%rip)
2:
  pushq $167
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetAnchorB
  .p2align 4
  .type cpDampedSpringGetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetAnchorB
#endif
cpDampedSpringGetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1344(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1344(%rip)
2:
  pushq $168
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetDamping
  .p2align 4
  .type cpDampedSpringGetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetDamping
#endif
cpDampedSpringGetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1352(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1352(%rip)
2:
  pushq $169
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetRestLength
  .p2align 4
  .type cpDampedSpringGetRestLength, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetRestLength
#endif
cpDampedSpringGetRestLength:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1360(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1360(%rip)
2:
  pushq $170
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetSpringForceFunc
  .p2align 4
  .type cpDampedSpringGetSpringForceFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetSpringForceFunc
#endif
cpDampedSpringGetSpringForceFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1368(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1368(%rip)
2:
  pushq $171
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringGetStiffness
  .p2align 4
  .type cpDampedSpringGetStiffness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringGetStiffness
#endif
cpDampedSpringGetStiffness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1376(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1376(%rip)
2:
  pushq $172
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringInit
  .p2align 4
  .type cpDampedSpringInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringInit
#endif
cpDampedSpringInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1384(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1384(%rip)
2:
  pushq $173
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringNew
  .p2align 4
  .type cpDampedSpringNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringNew
#endif
cpDampedSpringNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1392(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1392(%rip)
2:
  pushq $174
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetAnchorA
  .p2align 4
  .type cpDampedSpringSetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetAnchorA
#endif
cpDampedSpringSetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1400(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1400(%rip)
2:
  pushq $175
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetAnchorB
  .p2align 4
  .type cpDampedSpringSetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetAnchorB
#endif
cpDampedSpringSetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1408(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1408(%rip)
2:
  pushq $176
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetDamping
  .p2align 4
  .type cpDampedSpringSetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetDamping
#endif
cpDampedSpringSetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1416(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1416(%rip)
2:
  pushq $177
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetRestLength
  .p2align 4
  .type cpDampedSpringSetRestLength, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetRestLength
#endif
cpDampedSpringSetRestLength:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1424(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1424(%rip)
2:
  pushq $178
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetSpringForceFunc
  .p2align 4
  .type cpDampedSpringSetSpringForceFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetSpringForceFunc
#endif
cpDampedSpringSetSpringForceFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1432(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1432(%rip)
2:
  pushq $179
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpDampedSpringSetStiffness
  .p2align 4
  .type cpDampedSpringSetStiffness, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpDampedSpringSetStiffness
#endif
cpDampedSpringSetStiffness:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1440(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1440(%rip)
2:
  pushq $180
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointAlloc
  .p2align 4
  .type cpGearJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointAlloc
#endif
cpGearJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1448(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1448(%rip)
2:
  pushq $181
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointGetPhase
  .p2align 4
  .type cpGearJointGetPhase, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointGetPhase
#endif
cpGearJointGetPhase:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1456(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1456(%rip)
2:
  pushq $182
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointGetRatio
  .p2align 4
  .type cpGearJointGetRatio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointGetRatio
#endif
cpGearJointGetRatio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1464(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1464(%rip)
2:
  pushq $183
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointInit
  .p2align 4
  .type cpGearJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointInit
#endif
cpGearJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1472(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1472(%rip)
2:
  pushq $184
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointNew
  .p2align 4
  .type cpGearJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointNew
#endif
cpGearJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1480(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1480(%rip)
2:
  pushq $185
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointSetPhase
  .p2align 4
  .type cpGearJointSetPhase, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointSetPhase
#endif
cpGearJointSetPhase:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1488(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1488(%rip)
2:
  pushq $186
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGearJointSetRatio
  .p2align 4
  .type cpGearJointSetRatio, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGearJointSetRatio
#endif
cpGearJointSetRatio:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1496(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1496(%rip)
2:
  pushq $187
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointAlloc
  .p2align 4
  .type cpGrooveJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointAlloc
#endif
cpGrooveJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1504(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1504(%rip)
2:
  pushq $188
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointGetAnchorB
  .p2align 4
  .type cpGrooveJointGetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointGetAnchorB
#endif
cpGrooveJointGetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1512(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1512(%rip)
2:
  pushq $189
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointGetGrooveA
  .p2align 4
  .type cpGrooveJointGetGrooveA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointGetGrooveA
#endif
cpGrooveJointGetGrooveA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1520(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1520(%rip)
2:
  pushq $190
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointGetGrooveB
  .p2align 4
  .type cpGrooveJointGetGrooveB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointGetGrooveB
#endif
cpGrooveJointGetGrooveB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1528(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1528(%rip)
2:
  pushq $191
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointInit
  .p2align 4
  .type cpGrooveJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointInit
#endif
cpGrooveJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1536(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1536(%rip)
2:
  pushq $192
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointNew
  .p2align 4
  .type cpGrooveJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointNew
#endif
cpGrooveJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1544(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1544(%rip)
2:
  pushq $193
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointSetAnchorB
  .p2align 4
  .type cpGrooveJointSetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointSetAnchorB
#endif
cpGrooveJointSetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1552(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1552(%rip)
2:
  pushq $194
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointSetGrooveA
  .p2align 4
  .type cpGrooveJointSetGrooveA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointSetGrooveA
#endif
cpGrooveJointSetGrooveA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1560(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1560(%rip)
2:
  pushq $195
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpGrooveJointSetGrooveB
  .p2align 4
  .type cpGrooveJointSetGrooveB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpGrooveJointSetGrooveB
#endif
cpGrooveJointSetGrooveB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1568(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1568(%rip)
2:
  pushq $196
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetCount
  .p2align 4
  .type cpHashSetCount, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetCount
#endif
cpHashSetCount:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1576(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1576(%rip)
2:
  pushq $197
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetEach
  .p2align 4
  .type cpHashSetEach, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetEach
#endif
cpHashSetEach:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1584(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1584(%rip)
2:
  pushq $198
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetFilter
  .p2align 4
  .type cpHashSetFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetFilter
#endif
cpHashSetFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1592(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1592(%rip)
2:
  pushq $199
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetFind
  .p2align 4
  .type cpHashSetFind, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetFind
#endif
cpHashSetFind:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1600(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1600(%rip)
2:
  pushq $200
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetFree
  .p2align 4
  .type cpHashSetFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetFree
#endif
cpHashSetFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1608(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1608(%rip)
2:
  pushq $201
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetInsert
  .p2align 4
  .type cpHashSetInsert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetInsert
#endif
cpHashSetInsert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1616(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1616(%rip)
2:
  pushq $202
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetNew
  .p2align 4
  .type cpHashSetNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetNew
#endif
cpHashSetNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1624(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1624(%rip)
2:
  pushq $203
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetRemove
  .p2align 4
  .type cpHashSetRemove, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetRemove
#endif
cpHashSetRemove:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1632(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1632(%rip)
2:
  pushq $204
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHashSetSetDefaultValue
  .p2align 4
  .type cpHashSetSetDefaultValue, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHashSetSetDefaultValue
#endif
cpHashSetSetDefaultValue:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1640(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1640(%rip)
2:
  pushq $205
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHastySpaceFree
  .p2align 4
  .type cpHastySpaceFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHastySpaceFree
#endif
cpHastySpaceFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1648(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1648(%rip)
2:
  pushq $206
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHastySpaceGetThreads
  .p2align 4
  .type cpHastySpaceGetThreads, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHastySpaceGetThreads
#endif
cpHastySpaceGetThreads:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1656(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1656(%rip)
2:
  pushq $207
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHastySpaceNew
  .p2align 4
  .type cpHastySpaceNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHastySpaceNew
#endif
cpHastySpaceNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1664(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1664(%rip)
2:
  pushq $208
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHastySpaceSetThreads
  .p2align 4
  .type cpHastySpaceSetThreads, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHastySpaceSetThreads
#endif
cpHastySpaceSetThreads:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1672(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1672(%rip)
2:
  pushq $209
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpHastySpaceStep
  .p2align 4
  .type cpHastySpaceStep, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpHastySpaceStep
#endif
cpHastySpaceStep:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1680(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1680(%rip)
2:
  pushq $210
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpLoopIndexes
  .p2align 4
  .type cpLoopIndexes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpLoopIndexes
#endif
cpLoopIndexes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1688(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1688(%rip)
2:
  pushq $211
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMarchHard
  .p2align 4
  .type cpMarchHard, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMarchHard
#endif
cpMarchHard:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1696(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1696(%rip)
2:
  pushq $212
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMarchSoft
  .p2align 4
  .type cpMarchSoft, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMarchSoft
#endif
cpMarchSoft:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1704(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1704(%rip)
2:
  pushq $213
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMessage
  .p2align 4
  .type cpMessage, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMessage
#endif
cpMessage:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1712(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1712(%rip)
2:
  pushq $214
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMomentForBox
  .p2align 4
  .type cpMomentForBox, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMomentForBox
#endif
cpMomentForBox:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1720(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1720(%rip)
2:
  pushq $215
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMomentForBox2
  .p2align 4
  .type cpMomentForBox2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMomentForBox2
#endif
cpMomentForBox2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1728(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1728(%rip)
2:
  pushq $216
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMomentForCircle
  .p2align 4
  .type cpMomentForCircle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMomentForCircle
#endif
cpMomentForCircle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1736(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1736(%rip)
2:
  pushq $217
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMomentForPoly
  .p2align 4
  .type cpMomentForPoly, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMomentForPoly
#endif
cpMomentForPoly:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1744(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1744(%rip)
2:
  pushq $218
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpMomentForSegment
  .p2align 4
  .type cpMomentForSegment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpMomentForSegment
#endif
cpMomentForSegment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1752(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1752(%rip)
2:
  pushq $219
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointAlloc
  .p2align 4
  .type cpPinJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointAlloc
#endif
cpPinJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1760(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1760(%rip)
2:
  pushq $220
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointGetAnchorA
  .p2align 4
  .type cpPinJointGetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointGetAnchorA
#endif
cpPinJointGetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1768(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1768(%rip)
2:
  pushq $221
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointGetAnchorB
  .p2align 4
  .type cpPinJointGetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointGetAnchorB
#endif
cpPinJointGetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1776(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1776(%rip)
2:
  pushq $222
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointGetDist
  .p2align 4
  .type cpPinJointGetDist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointGetDist
#endif
cpPinJointGetDist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1784(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1784(%rip)
2:
  pushq $223
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointInit
  .p2align 4
  .type cpPinJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointInit
#endif
cpPinJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1792(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1792(%rip)
2:
  pushq $224
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointNew
  .p2align 4
  .type cpPinJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointNew
#endif
cpPinJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1800(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1800(%rip)
2:
  pushq $225
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointSetAnchorA
  .p2align 4
  .type cpPinJointSetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointSetAnchorA
#endif
cpPinJointSetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1808(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1808(%rip)
2:
  pushq $226
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointSetAnchorB
  .p2align 4
  .type cpPinJointSetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointSetAnchorB
#endif
cpPinJointSetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1816(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1816(%rip)
2:
  pushq $227
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPinJointSetDist
  .p2align 4
  .type cpPinJointSetDist, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPinJointSetDist
#endif
cpPinJointSetDist:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1824(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1824(%rip)
2:
  pushq $228
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointAlloc
  .p2align 4
  .type cpPivotJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointAlloc
#endif
cpPivotJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1832(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1832(%rip)
2:
  pushq $229
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointGetAnchorA
  .p2align 4
  .type cpPivotJointGetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointGetAnchorA
#endif
cpPivotJointGetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1840(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1840(%rip)
2:
  pushq $230
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointGetAnchorB
  .p2align 4
  .type cpPivotJointGetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointGetAnchorB
#endif
cpPivotJointGetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1848(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1848(%rip)
2:
  pushq $231
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointInit
  .p2align 4
  .type cpPivotJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointInit
#endif
cpPivotJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1856(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1856(%rip)
2:
  pushq $232
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointNew
  .p2align 4
  .type cpPivotJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointNew
#endif
cpPivotJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1864(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1864(%rip)
2:
  pushq $233
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointNew2
  .p2align 4
  .type cpPivotJointNew2, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointNew2
#endif
cpPivotJointNew2:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1872(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1872(%rip)
2:
  pushq $234
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointSetAnchorA
  .p2align 4
  .type cpPivotJointSetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointSetAnchorA
#endif
cpPivotJointSetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1880(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1880(%rip)
2:
  pushq $235
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPivotJointSetAnchorB
  .p2align 4
  .type cpPivotJointSetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPivotJointSetAnchorB
#endif
cpPivotJointSetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1888(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1888(%rip)
2:
  pushq $236
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeAlloc
  .p2align 4
  .type cpPolyShapeAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeAlloc
#endif
cpPolyShapeAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1896(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1896(%rip)
2:
  pushq $237
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeGetCount
  .p2align 4
  .type cpPolyShapeGetCount, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeGetCount
#endif
cpPolyShapeGetCount:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1904(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1904(%rip)
2:
  pushq $238
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeGetRadius
  .p2align 4
  .type cpPolyShapeGetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeGetRadius
#endif
cpPolyShapeGetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1912(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1912(%rip)
2:
  pushq $239
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeGetVert
  .p2align 4
  .type cpPolyShapeGetVert, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeGetVert
#endif
cpPolyShapeGetVert:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1920(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1920(%rip)
2:
  pushq $240
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeInit
  .p2align 4
  .type cpPolyShapeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeInit
#endif
cpPolyShapeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1928(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1928(%rip)
2:
  pushq $241
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeInitRaw
  .p2align 4
  .type cpPolyShapeInitRaw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeInitRaw
#endif
cpPolyShapeInitRaw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1936(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1936(%rip)
2:
  pushq $242
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeNew
  .p2align 4
  .type cpPolyShapeNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeNew
#endif
cpPolyShapeNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1944(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1944(%rip)
2:
  pushq $243
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeNewRaw
  .p2align 4
  .type cpPolyShapeNewRaw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeNewRaw
#endif
cpPolyShapeNewRaw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1952(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1952(%rip)
2:
  pushq $244
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeSetRadius
  .p2align 4
  .type cpPolyShapeSetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeSetRadius
#endif
cpPolyShapeSetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1960(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1960(%rip)
2:
  pushq $245
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeSetVerts
  .p2align 4
  .type cpPolyShapeSetVerts, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeSetVerts
#endif
cpPolyShapeSetVerts:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1968(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1968(%rip)
2:
  pushq $246
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolyShapeSetVertsRaw
  .p2align 4
  .type cpPolyShapeSetVertsRaw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolyShapeSetVertsRaw
#endif
cpPolyShapeSetVertsRaw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1976(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1976(%rip)
2:
  pushq $247
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineConvexDecomposition
  .p2align 4
  .type cpPolylineConvexDecomposition, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineConvexDecomposition
#endif
cpPolylineConvexDecomposition:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1984(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1984(%rip)
2:
  pushq $248
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineFree
  .p2align 4
  .type cpPolylineFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineFree
#endif
cpPolylineFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+1992(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+1992(%rip)
2:
  pushq $249
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineIsClosed
  .p2align 4
  .type cpPolylineIsClosed, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineIsClosed
#endif
cpPolylineIsClosed:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2000(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2000(%rip)
2:
  pushq $250
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetAlloc
  .p2align 4
  .type cpPolylineSetAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetAlloc
#endif
cpPolylineSetAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2008(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2008(%rip)
2:
  pushq $251
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetCollectSegment
  .p2align 4
  .type cpPolylineSetCollectSegment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetCollectSegment
#endif
cpPolylineSetCollectSegment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2016(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2016(%rip)
2:
  pushq $252
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetDestroy
  .p2align 4
  .type cpPolylineSetDestroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetDestroy
#endif
cpPolylineSetDestroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2024(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2024(%rip)
2:
  pushq $253
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetFree
  .p2align 4
  .type cpPolylineSetFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetFree
#endif
cpPolylineSetFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2032(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2032(%rip)
2:
  pushq $254
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetInit
  .p2align 4
  .type cpPolylineSetInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetInit
#endif
cpPolylineSetInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2040(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2040(%rip)
2:
  pushq $255
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSetNew
  .p2align 4
  .type cpPolylineSetNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSetNew
#endif
cpPolylineSetNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2048(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2048(%rip)
2:
  pushq $256
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSimplifyCurves
  .p2align 4
  .type cpPolylineSimplifyCurves, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSimplifyCurves
#endif
cpPolylineSimplifyCurves:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2056(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2056(%rip)
2:
  pushq $257
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineSimplifyVertexes
  .p2align 4
  .type cpPolylineSimplifyVertexes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineSimplifyVertexes
#endif
cpPolylineSimplifyVertexes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2064(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2064(%rip)
2:
  pushq $258
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpPolylineToConvexHull
  .p2align 4
  .type cpPolylineToConvexHull, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpPolylineToConvexHull
#endif
cpPolylineToConvexHull:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2072(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2072(%rip)
2:
  pushq $259
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointAlloc
  .p2align 4
  .type cpRatchetJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointAlloc
#endif
cpRatchetJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2080(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2080(%rip)
2:
  pushq $260
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointGetAngle
  .p2align 4
  .type cpRatchetJointGetAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointGetAngle
#endif
cpRatchetJointGetAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2088(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2088(%rip)
2:
  pushq $261
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointGetPhase
  .p2align 4
  .type cpRatchetJointGetPhase, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointGetPhase
#endif
cpRatchetJointGetPhase:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2096(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2096(%rip)
2:
  pushq $262
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointGetRatchet
  .p2align 4
  .type cpRatchetJointGetRatchet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointGetRatchet
#endif
cpRatchetJointGetRatchet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2104(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2104(%rip)
2:
  pushq $263
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointInit
  .p2align 4
  .type cpRatchetJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointInit
#endif
cpRatchetJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2112(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2112(%rip)
2:
  pushq $264
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointNew
  .p2align 4
  .type cpRatchetJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointNew
#endif
cpRatchetJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2120(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2120(%rip)
2:
  pushq $265
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointSetAngle
  .p2align 4
  .type cpRatchetJointSetAngle, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointSetAngle
#endif
cpRatchetJointSetAngle:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2128(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2128(%rip)
2:
  pushq $266
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointSetPhase
  .p2align 4
  .type cpRatchetJointSetPhase, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointSetPhase
#endif
cpRatchetJointSetPhase:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2136(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2136(%rip)
2:
  pushq $267
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRatchetJointSetRatchet
  .p2align 4
  .type cpRatchetJointSetRatchet, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRatchetJointSetRatchet
#endif
cpRatchetJointSetRatchet:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2144(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2144(%rip)
2:
  pushq $268
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointAlloc
  .p2align 4
  .type cpRotaryLimitJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointAlloc
#endif
cpRotaryLimitJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2152(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2152(%rip)
2:
  pushq $269
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointGetMax
  .p2align 4
  .type cpRotaryLimitJointGetMax, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointGetMax
#endif
cpRotaryLimitJointGetMax:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2160(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2160(%rip)
2:
  pushq $270
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointGetMin
  .p2align 4
  .type cpRotaryLimitJointGetMin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointGetMin
#endif
cpRotaryLimitJointGetMin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2168(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2168(%rip)
2:
  pushq $271
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointInit
  .p2align 4
  .type cpRotaryLimitJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointInit
#endif
cpRotaryLimitJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2176(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2176(%rip)
2:
  pushq $272
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointNew
  .p2align 4
  .type cpRotaryLimitJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointNew
#endif
cpRotaryLimitJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2184(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2184(%rip)
2:
  pushq $273
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointSetMax
  .p2align 4
  .type cpRotaryLimitJointSetMax, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointSetMax
#endif
cpRotaryLimitJointSetMax:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2192(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2192(%rip)
2:
  pushq $274
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpRotaryLimitJointSetMin
  .p2align 4
  .type cpRotaryLimitJointSetMin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpRotaryLimitJointSetMin
#endif
cpRotaryLimitJointSetMin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2200(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2200(%rip)
2:
  pushq $275
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeAlloc
  .p2align 4
  .type cpSegmentShapeAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeAlloc
#endif
cpSegmentShapeAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2208(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2208(%rip)
2:
  pushq $276
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeGetA
  .p2align 4
  .type cpSegmentShapeGetA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeGetA
#endif
cpSegmentShapeGetA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2216(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2216(%rip)
2:
  pushq $277
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeGetB
  .p2align 4
  .type cpSegmentShapeGetB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeGetB
#endif
cpSegmentShapeGetB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2224(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2224(%rip)
2:
  pushq $278
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeGetNormal
  .p2align 4
  .type cpSegmentShapeGetNormal, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeGetNormal
#endif
cpSegmentShapeGetNormal:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2232(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2232(%rip)
2:
  pushq $279
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeGetRadius
  .p2align 4
  .type cpSegmentShapeGetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeGetRadius
#endif
cpSegmentShapeGetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2240(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2240(%rip)
2:
  pushq $280
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeInit
  .p2align 4
  .type cpSegmentShapeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeInit
#endif
cpSegmentShapeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2248(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2248(%rip)
2:
  pushq $281
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeNew
  .p2align 4
  .type cpSegmentShapeNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeNew
#endif
cpSegmentShapeNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2256(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2256(%rip)
2:
  pushq $282
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeSetEndpoints
  .p2align 4
  .type cpSegmentShapeSetEndpoints, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeSetEndpoints
#endif
cpSegmentShapeSetEndpoints:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2264(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2264(%rip)
2:
  pushq $283
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeSetNeighbors
  .p2align 4
  .type cpSegmentShapeSetNeighbors, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeSetNeighbors
#endif
cpSegmentShapeSetNeighbors:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2272(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2272(%rip)
2:
  pushq $284
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSegmentShapeSetRadius
  .p2align 4
  .type cpSegmentShapeSetRadius, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSegmentShapeSetRadius
#endif
cpSegmentShapeSetRadius:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2280(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2280(%rip)
2:
  pushq $285
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeCacheBB
  .p2align 4
  .type cpShapeCacheBB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeCacheBB
#endif
cpShapeCacheBB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2288(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2288(%rip)
2:
  pushq $286
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeDestroy
  .p2align 4
  .type cpShapeDestroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeDestroy
#endif
cpShapeDestroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2296(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2296(%rip)
2:
  pushq $287
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeFree
  .p2align 4
  .type cpShapeFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeFree
#endif
cpShapeFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2304(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2304(%rip)
2:
  pushq $288
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetArea
  .p2align 4
  .type cpShapeGetArea, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetArea
#endif
cpShapeGetArea:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2312(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2312(%rip)
2:
  pushq $289
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetBB
  .p2align 4
  .type cpShapeGetBB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetBB
#endif
cpShapeGetBB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2320(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2320(%rip)
2:
  pushq $290
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetBody
  .p2align 4
  .type cpShapeGetBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetBody
#endif
cpShapeGetBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2328(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2328(%rip)
2:
  pushq $291
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetCenterOfGravity
  .p2align 4
  .type cpShapeGetCenterOfGravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetCenterOfGravity
#endif
cpShapeGetCenterOfGravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2336(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2336(%rip)
2:
  pushq $292
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetCollisionType
  .p2align 4
  .type cpShapeGetCollisionType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetCollisionType
#endif
cpShapeGetCollisionType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2344(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2344(%rip)
2:
  pushq $293
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetDensity
  .p2align 4
  .type cpShapeGetDensity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetDensity
#endif
cpShapeGetDensity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2352(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2352(%rip)
2:
  pushq $294
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetElasticity
  .p2align 4
  .type cpShapeGetElasticity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetElasticity
#endif
cpShapeGetElasticity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2360(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2360(%rip)
2:
  pushq $295
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetFilter
  .p2align 4
  .type cpShapeGetFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetFilter
#endif
cpShapeGetFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2368(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2368(%rip)
2:
  pushq $296
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetFriction
  .p2align 4
  .type cpShapeGetFriction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetFriction
#endif
cpShapeGetFriction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2376(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2376(%rip)
2:
  pushq $297
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetMass
  .p2align 4
  .type cpShapeGetMass, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetMass
#endif
cpShapeGetMass:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2384(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2384(%rip)
2:
  pushq $298
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetMoment
  .p2align 4
  .type cpShapeGetMoment, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetMoment
#endif
cpShapeGetMoment:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2392(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2392(%rip)
2:
  pushq $299
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetSensor
  .p2align 4
  .type cpShapeGetSensor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetSensor
#endif
cpShapeGetSensor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2400(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2400(%rip)
2:
  pushq $300
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetSpace
  .p2align 4
  .type cpShapeGetSpace, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetSpace
#endif
cpShapeGetSpace:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2408(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2408(%rip)
2:
  pushq $301
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetSurfaceVelocity
  .p2align 4
  .type cpShapeGetSurfaceVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetSurfaceVelocity
#endif
cpShapeGetSurfaceVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2416(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2416(%rip)
2:
  pushq $302
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeGetUserData
  .p2align 4
  .type cpShapeGetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeGetUserData
#endif
cpShapeGetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2424(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2424(%rip)
2:
  pushq $303
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeInit
  .p2align 4
  .type cpShapeInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeInit
#endif
cpShapeInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2432(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2432(%rip)
2:
  pushq $304
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapePointQuery
  .p2align 4
  .type cpShapePointQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapePointQuery
#endif
cpShapePointQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2440(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2440(%rip)
2:
  pushq $305
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSegmentQuery
  .p2align 4
  .type cpShapeSegmentQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSegmentQuery
#endif
cpShapeSegmentQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2448(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2448(%rip)
2:
  pushq $306
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetBody
  .p2align 4
  .type cpShapeSetBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetBody
#endif
cpShapeSetBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2456(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2456(%rip)
2:
  pushq $307
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetCollisionType
  .p2align 4
  .type cpShapeSetCollisionType, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetCollisionType
#endif
cpShapeSetCollisionType:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2464(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2464(%rip)
2:
  pushq $308
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetDensity
  .p2align 4
  .type cpShapeSetDensity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetDensity
#endif
cpShapeSetDensity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2472(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2472(%rip)
2:
  pushq $309
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetElasticity
  .p2align 4
  .type cpShapeSetElasticity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetElasticity
#endif
cpShapeSetElasticity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2480(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2480(%rip)
2:
  pushq $310
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetFilter
  .p2align 4
  .type cpShapeSetFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetFilter
#endif
cpShapeSetFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2488(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2488(%rip)
2:
  pushq $311
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetFriction
  .p2align 4
  .type cpShapeSetFriction, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetFriction
#endif
cpShapeSetFriction:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2496(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2496(%rip)
2:
  pushq $312
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetMass
  .p2align 4
  .type cpShapeSetMass, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetMass
#endif
cpShapeSetMass:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2504(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2504(%rip)
2:
  pushq $313
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetSensor
  .p2align 4
  .type cpShapeSetSensor, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetSensor
#endif
cpShapeSetSensor:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2512(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2512(%rip)
2:
  pushq $314
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetSurfaceVelocity
  .p2align 4
  .type cpShapeSetSurfaceVelocity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetSurfaceVelocity
#endif
cpShapeSetSurfaceVelocity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2520(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2520(%rip)
2:
  pushq $315
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeSetUserData
  .p2align 4
  .type cpShapeSetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeSetUserData
#endif
cpShapeSetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2528(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2528(%rip)
2:
  pushq $316
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeUpdate
  .p2align 4
  .type cpShapeUpdate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeUpdate
#endif
cpShapeUpdate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2536(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2536(%rip)
2:
  pushq $317
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapeUpdateFunc
  .p2align 4
  .type cpShapeUpdateFunc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapeUpdateFunc
#endif
cpShapeUpdateFunc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2544(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2544(%rip)
2:
  pushq $318
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpShapesCollide
  .p2align 4
  .type cpShapesCollide, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpShapesCollide
#endif
cpShapesCollide:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2552(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2552(%rip)
2:
  pushq $319
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSimpleMotorAlloc
  .p2align 4
  .type cpSimpleMotorAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSimpleMotorAlloc
#endif
cpSimpleMotorAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2560(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2560(%rip)
2:
  pushq $320
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSimpleMotorGetRate
  .p2align 4
  .type cpSimpleMotorGetRate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSimpleMotorGetRate
#endif
cpSimpleMotorGetRate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2568(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2568(%rip)
2:
  pushq $321
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSimpleMotorInit
  .p2align 4
  .type cpSimpleMotorInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSimpleMotorInit
#endif
cpSimpleMotorInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2576(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2576(%rip)
2:
  pushq $322
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSimpleMotorNew
  .p2align 4
  .type cpSimpleMotorNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSimpleMotorNew
#endif
cpSimpleMotorNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2584(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2584(%rip)
2:
  pushq $323
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSimpleMotorSetRate
  .p2align 4
  .type cpSimpleMotorSetRate, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSimpleMotorSetRate
#endif
cpSimpleMotorSetRate:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2592(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2592(%rip)
2:
  pushq $324
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointAlloc
  .p2align 4
  .type cpSlideJointAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointAlloc
#endif
cpSlideJointAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2600(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2600(%rip)
2:
  pushq $325
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointGetAnchorA
  .p2align 4
  .type cpSlideJointGetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointGetAnchorA
#endif
cpSlideJointGetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2608(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2608(%rip)
2:
  pushq $326
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointGetAnchorB
  .p2align 4
  .type cpSlideJointGetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointGetAnchorB
#endif
cpSlideJointGetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2616(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2616(%rip)
2:
  pushq $327
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointGetMax
  .p2align 4
  .type cpSlideJointGetMax, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointGetMax
#endif
cpSlideJointGetMax:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2624(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2624(%rip)
2:
  pushq $328
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointGetMin
  .p2align 4
  .type cpSlideJointGetMin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointGetMin
#endif
cpSlideJointGetMin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2632(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2632(%rip)
2:
  pushq $329
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointInit
  .p2align 4
  .type cpSlideJointInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointInit
#endif
cpSlideJointInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2640(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2640(%rip)
2:
  pushq $330
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointNew
  .p2align 4
  .type cpSlideJointNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointNew
#endif
cpSlideJointNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2648(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2648(%rip)
2:
  pushq $331
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointSetAnchorA
  .p2align 4
  .type cpSlideJointSetAnchorA, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointSetAnchorA
#endif
cpSlideJointSetAnchorA:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2656(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2656(%rip)
2:
  pushq $332
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointSetAnchorB
  .p2align 4
  .type cpSlideJointSetAnchorB, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointSetAnchorB
#endif
cpSlideJointSetAnchorB:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2664(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2664(%rip)
2:
  pushq $333
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointSetMax
  .p2align 4
  .type cpSlideJointSetMax, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointSetMax
#endif
cpSlideJointSetMax:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2672(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2672(%rip)
2:
  pushq $334
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSlideJointSetMin
  .p2align 4
  .type cpSlideJointSetMin, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSlideJointSetMin
#endif
cpSlideJointSetMin:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2680(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2680(%rip)
2:
  pushq $335
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceActivateBody
  .p2align 4
  .type cpSpaceActivateBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceActivateBody
#endif
cpSpaceActivateBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2688(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2688(%rip)
2:
  pushq $336
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddBody
  .p2align 4
  .type cpSpaceAddBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddBody
#endif
cpSpaceAddBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2696(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2696(%rip)
2:
  pushq $337
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddCollisionHandler
  .p2align 4
  .type cpSpaceAddCollisionHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddCollisionHandler
#endif
cpSpaceAddCollisionHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2704(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2704(%rip)
2:
  pushq $338
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddConstraint
  .p2align 4
  .type cpSpaceAddConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddConstraint
#endif
cpSpaceAddConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2712(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2712(%rip)
2:
  pushq $339
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddDefaultCollisionHandler
  .p2align 4
  .type cpSpaceAddDefaultCollisionHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddDefaultCollisionHandler
#endif
cpSpaceAddDefaultCollisionHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2720(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2720(%rip)
2:
  pushq $340
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddPostStepCallback
  .p2align 4
  .type cpSpaceAddPostStepCallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddPostStepCallback
#endif
cpSpaceAddPostStepCallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2728(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2728(%rip)
2:
  pushq $341
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddShape
  .p2align 4
  .type cpSpaceAddShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddShape
#endif
cpSpaceAddShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2736(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2736(%rip)
2:
  pushq $342
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAddWildcardHandler
  .p2align 4
  .type cpSpaceAddWildcardHandler, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAddWildcardHandler
#endif
cpSpaceAddWildcardHandler:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2744(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2744(%rip)
2:
  pushq $343
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceAlloc
  .p2align 4
  .type cpSpaceAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceAlloc
#endif
cpSpaceAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2752(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2752(%rip)
2:
  pushq $344
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceArbiterSetFilter
  .p2align 4
  .type cpSpaceArbiterSetFilter, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceArbiterSetFilter
#endif
cpSpaceArbiterSetFilter:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2760(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2760(%rip)
2:
  pushq $345
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceBBQuery
  .p2align 4
  .type cpSpaceBBQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceBBQuery
#endif
cpSpaceBBQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2768(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2768(%rip)
2:
  pushq $346
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceCollideShapes
  .p2align 4
  .type cpSpaceCollideShapes, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceCollideShapes
#endif
cpSpaceCollideShapes:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2776(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2776(%rip)
2:
  pushq $347
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceContainsBody
  .p2align 4
  .type cpSpaceContainsBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceContainsBody
#endif
cpSpaceContainsBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2784(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2784(%rip)
2:
  pushq $348
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceContainsConstraint
  .p2align 4
  .type cpSpaceContainsConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceContainsConstraint
#endif
cpSpaceContainsConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2792(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2792(%rip)
2:
  pushq $349
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceContainsShape
  .p2align 4
  .type cpSpaceContainsShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceContainsShape
#endif
cpSpaceContainsShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2800(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2800(%rip)
2:
  pushq $350
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceDebugDraw
  .p2align 4
  .type cpSpaceDebugDraw, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceDebugDraw
#endif
cpSpaceDebugDraw:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2808(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2808(%rip)
2:
  pushq $351
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceDestroy
  .p2align 4
  .type cpSpaceDestroy, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceDestroy
#endif
cpSpaceDestroy:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2816(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2816(%rip)
2:
  pushq $352
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceEachBody
  .p2align 4
  .type cpSpaceEachBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceEachBody
#endif
cpSpaceEachBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2824(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2824(%rip)
2:
  pushq $353
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceEachConstraint
  .p2align 4
  .type cpSpaceEachConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceEachConstraint
#endif
cpSpaceEachConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2832(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2832(%rip)
2:
  pushq $354
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceEachShape
  .p2align 4
  .type cpSpaceEachShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceEachShape
#endif
cpSpaceEachShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2840(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2840(%rip)
2:
  pushq $355
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceFilterArbiters
  .p2align 4
  .type cpSpaceFilterArbiters, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceFilterArbiters
#endif
cpSpaceFilterArbiters:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2848(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2848(%rip)
2:
  pushq $356
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceFree
  .p2align 4
  .type cpSpaceFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceFree
#endif
cpSpaceFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2856(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2856(%rip)
2:
  pushq $357
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetCollisionBias
  .p2align 4
  .type cpSpaceGetCollisionBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetCollisionBias
#endif
cpSpaceGetCollisionBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2864(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2864(%rip)
2:
  pushq $358
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetCollisionPersistence
  .p2align 4
  .type cpSpaceGetCollisionPersistence, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetCollisionPersistence
#endif
cpSpaceGetCollisionPersistence:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2872(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2872(%rip)
2:
  pushq $359
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetCollisionSlop
  .p2align 4
  .type cpSpaceGetCollisionSlop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetCollisionSlop
#endif
cpSpaceGetCollisionSlop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2880(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2880(%rip)
2:
  pushq $360
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetCurrentTimeStep
  .p2align 4
  .type cpSpaceGetCurrentTimeStep, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetCurrentTimeStep
#endif
cpSpaceGetCurrentTimeStep:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2888(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2888(%rip)
2:
  pushq $361
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetDamping
  .p2align 4
  .type cpSpaceGetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetDamping
#endif
cpSpaceGetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2896(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2896(%rip)
2:
  pushq $362
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetGravity
  .p2align 4
  .type cpSpaceGetGravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetGravity
#endif
cpSpaceGetGravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2904(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2904(%rip)
2:
  pushq $363
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetIdleSpeedThreshold
  .p2align 4
  .type cpSpaceGetIdleSpeedThreshold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetIdleSpeedThreshold
#endif
cpSpaceGetIdleSpeedThreshold:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2912(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2912(%rip)
2:
  pushq $364
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetIterations
  .p2align 4
  .type cpSpaceGetIterations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetIterations
#endif
cpSpaceGetIterations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2920(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2920(%rip)
2:
  pushq $365
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetPostStepCallback
  .p2align 4
  .type cpSpaceGetPostStepCallback, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetPostStepCallback
#endif
cpSpaceGetPostStepCallback:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2928(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2928(%rip)
2:
  pushq $366
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetSleepTimeThreshold
  .p2align 4
  .type cpSpaceGetSleepTimeThreshold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetSleepTimeThreshold
#endif
cpSpaceGetSleepTimeThreshold:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2936(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2936(%rip)
2:
  pushq $367
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetStaticBody
  .p2align 4
  .type cpSpaceGetStaticBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetStaticBody
#endif
cpSpaceGetStaticBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2944(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2944(%rip)
2:
  pushq $368
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceGetUserData
  .p2align 4
  .type cpSpaceGetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceGetUserData
#endif
cpSpaceGetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2952(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2952(%rip)
2:
  pushq $369
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceHashAlloc
  .p2align 4
  .type cpSpaceHashAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceHashAlloc
#endif
cpSpaceHashAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2960(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2960(%rip)
2:
  pushq $370
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceHashInit
  .p2align 4
  .type cpSpaceHashInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceHashInit
#endif
cpSpaceHashInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2968(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2968(%rip)
2:
  pushq $371
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceHashNew
  .p2align 4
  .type cpSpaceHashNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceHashNew
#endif
cpSpaceHashNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2976(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2976(%rip)
2:
  pushq $372
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceHashResize
  .p2align 4
  .type cpSpaceHashResize, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceHashResize
#endif
cpSpaceHashResize:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2984(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2984(%rip)
2:
  pushq $373
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceInit
  .p2align 4
  .type cpSpaceInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceInit
#endif
cpSpaceInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+2992(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+2992(%rip)
2:
  pushq $374
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceIsLocked
  .p2align 4
  .type cpSpaceIsLocked, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceIsLocked
#endif
cpSpaceIsLocked:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3000(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3000(%rip)
2:
  pushq $375
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceLock
  .p2align 4
  .type cpSpaceLock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceLock
#endif
cpSpaceLock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3008(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3008(%rip)
2:
  pushq $376
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceNew
  .p2align 4
  .type cpSpaceNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceNew
#endif
cpSpaceNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3016(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3016(%rip)
2:
  pushq $377
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpacePointQuery
  .p2align 4
  .type cpSpacePointQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpacePointQuery
#endif
cpSpacePointQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3024(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3024(%rip)
2:
  pushq $378
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpacePointQueryNearest
  .p2align 4
  .type cpSpacePointQueryNearest, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpacePointQueryNearest
#endif
cpSpacePointQueryNearest:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3032(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3032(%rip)
2:
  pushq $379
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceProcessComponents
  .p2align 4
  .type cpSpaceProcessComponents, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceProcessComponents
#endif
cpSpaceProcessComponents:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3040(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3040(%rip)
2:
  pushq $380
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpacePushContacts
  .p2align 4
  .type cpSpacePushContacts, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpacePushContacts
#endif
cpSpacePushContacts:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3048(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3048(%rip)
2:
  pushq $381
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpacePushFreshContactBuffer
  .p2align 4
  .type cpSpacePushFreshContactBuffer, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpacePushFreshContactBuffer
#endif
cpSpacePushFreshContactBuffer:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3056(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3056(%rip)
2:
  pushq $382
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceReindexShape
  .p2align 4
  .type cpSpaceReindexShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceReindexShape
#endif
cpSpaceReindexShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3064(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3064(%rip)
2:
  pushq $383
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceReindexShapesForBody
  .p2align 4
  .type cpSpaceReindexShapesForBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceReindexShapesForBody
#endif
cpSpaceReindexShapesForBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3072(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3072(%rip)
2:
  pushq $384
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceReindexStatic
  .p2align 4
  .type cpSpaceReindexStatic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceReindexStatic
#endif
cpSpaceReindexStatic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3080(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3080(%rip)
2:
  pushq $385
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceRemoveBody
  .p2align 4
  .type cpSpaceRemoveBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceRemoveBody
#endif
cpSpaceRemoveBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3088(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3088(%rip)
2:
  pushq $386
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceRemoveConstraint
  .p2align 4
  .type cpSpaceRemoveConstraint, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceRemoveConstraint
#endif
cpSpaceRemoveConstraint:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3096(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3096(%rip)
2:
  pushq $387
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceRemoveShape
  .p2align 4
  .type cpSpaceRemoveShape, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceRemoveShape
#endif
cpSpaceRemoveShape:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3104(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3104(%rip)
2:
  pushq $388
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSegmentQuery
  .p2align 4
  .type cpSpaceSegmentQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSegmentQuery
#endif
cpSpaceSegmentQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3112(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3112(%rip)
2:
  pushq $389
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSegmentQueryFirst
  .p2align 4
  .type cpSpaceSegmentQueryFirst, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSegmentQueryFirst
#endif
cpSpaceSegmentQueryFirst:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3120(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3120(%rip)
2:
  pushq $390
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetCollisionBias
  .p2align 4
  .type cpSpaceSetCollisionBias, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetCollisionBias
#endif
cpSpaceSetCollisionBias:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3128(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3128(%rip)
2:
  pushq $391
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetCollisionPersistence
  .p2align 4
  .type cpSpaceSetCollisionPersistence, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetCollisionPersistence
#endif
cpSpaceSetCollisionPersistence:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3136(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3136(%rip)
2:
  pushq $392
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetCollisionSlop
  .p2align 4
  .type cpSpaceSetCollisionSlop, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetCollisionSlop
#endif
cpSpaceSetCollisionSlop:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3144(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3144(%rip)
2:
  pushq $393
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetDamping
  .p2align 4
  .type cpSpaceSetDamping, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetDamping
#endif
cpSpaceSetDamping:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3152(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3152(%rip)
2:
  pushq $394
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetGravity
  .p2align 4
  .type cpSpaceSetGravity, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetGravity
#endif
cpSpaceSetGravity:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3160(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3160(%rip)
2:
  pushq $395
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetIdleSpeedThreshold
  .p2align 4
  .type cpSpaceSetIdleSpeedThreshold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetIdleSpeedThreshold
#endif
cpSpaceSetIdleSpeedThreshold:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3168(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3168(%rip)
2:
  pushq $396
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetIterations
  .p2align 4
  .type cpSpaceSetIterations, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetIterations
#endif
cpSpaceSetIterations:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3176(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3176(%rip)
2:
  pushq $397
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetSleepTimeThreshold
  .p2align 4
  .type cpSpaceSetSleepTimeThreshold, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetSleepTimeThreshold
#endif
cpSpaceSetSleepTimeThreshold:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3184(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3184(%rip)
2:
  pushq $398
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetStaticBody
  .p2align 4
  .type cpSpaceSetStaticBody, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetStaticBody
#endif
cpSpaceSetStaticBody:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3192(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3192(%rip)
2:
  pushq $399
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceSetUserData
  .p2align 4
  .type cpSpaceSetUserData, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceSetUserData
#endif
cpSpaceSetUserData:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3200(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3200(%rip)
2:
  pushq $400
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceShapeQuery
  .p2align 4
  .type cpSpaceShapeQuery, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceShapeQuery
#endif
cpSpaceShapeQuery:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3208(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3208(%rip)
2:
  pushq $401
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceStep
  .p2align 4
  .type cpSpaceStep, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceStep
#endif
cpSpaceStep:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3216(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3216(%rip)
2:
  pushq $402
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceUnlock
  .p2align 4
  .type cpSpaceUnlock, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceUnlock
#endif
cpSpaceUnlock:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3224(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3224(%rip)
2:
  pushq $403
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpaceUseSpatialHash
  .p2align 4
  .type cpSpaceUseSpatialHash, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpaceUseSpatialHash
#endif
cpSpaceUseSpatialHash:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3232(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3232(%rip)
2:
  pushq $404
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpatialIndexCollideStatic
  .p2align 4
  .type cpSpatialIndexCollideStatic, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpatialIndexCollideStatic
#endif
cpSpatialIndexCollideStatic:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3240(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3240(%rip)
2:
  pushq $405
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpatialIndexFree
  .p2align 4
  .type cpSpatialIndexFree, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpatialIndexFree
#endif
cpSpatialIndexFree:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3248(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3248(%rip)
2:
  pushq $406
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSpatialIndexInit
  .p2align 4
  .type cpSpatialIndexInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSpatialIndexInit
#endif
cpSpatialIndexInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3256(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3256(%rip)
2:
  pushq $407
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSweep1DAlloc
  .p2align 4
  .type cpSweep1DAlloc, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSweep1DAlloc
#endif
cpSweep1DAlloc:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3264(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3264(%rip)
2:
  pushq $408
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSweep1DInit
  .p2align 4
  .type cpSweep1DInit, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSweep1DInit
#endif
cpSweep1DInit:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3272(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3272(%rip)
2:
  pushq $409
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

/*
 * Copyright 2018-2022 Yury Gribov
 *
 * The MIT License (MIT)
 *
 * Use of this source code is governed by MIT license that can be
 * found in the LICENSE.txt file.
 */

  .globl cpSweep1DNew
  .p2align 4
  .type cpSweep1DNew, %function
#ifndef IMPLIB_EXPORT_SHIMS
  .hidden cpSweep1DNew
#endif
cpSweep1DNew:
  .cfi_startproc
  .cfi_def_cfa_offset 8  // Return address
  // Intel opt. manual says to
  // "make the fall-through code following a conditional branch be the likely target for a branch with a forward target"
  // to hint static predictor.
  cmpq $0, _libchipmunk_so_tramp_table+3280(%rip)
  je 2f
1:
  jmp *_libchipmunk_so_tramp_table+3280(%rip)
2:
  pushq $410
  .cfi_adjust_cfa_offset 8
  call _libchipmunk_so_save_regs_and_resolve
  addq $8, %rsp
  .cfi_adjust_cfa_offset -8
  jmp 1b
  .cfi_endproc

