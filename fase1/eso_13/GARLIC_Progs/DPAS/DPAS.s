	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"DPAS.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"********************************\000"
	.align	2
.LC1:
	.ascii	"*                              *\000"
	.align	2
.LC2:
	.ascii	"*      DPAS  -  PID (%d)        *\000"
	.align	2
.LC3:
	.ascii	"********************************\012\000"
	.align	2
.LC4:
	.ascii	"En el any %d el Domingo de Pascua cae en el dia %d "
	.ascii	"de marzo\012\000"
	.align	2
.LC5:
	.ascii	"En el any %d el Domingo de Pascua cae en el dia %d "
	.ascii	"de abril\012\000"
	.align	2
.LC6:
	.ascii	"\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #44
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [sp, #4]
	b	.L3
.L2:
	ldr	r3, [sp, #4]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [sp, #4]
.L3:
	ldr	r3, [sp, #4]
	add	r3, r3, #5
	mov	r2, #1
	lsl	r3, r2, r3
	str	r3, [sp, #4]
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	ldr	r1, [sp, #4]
	add	r3, sp, #8
	add	r2, sp, #12
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	add	r3, r3, #1888
	add	r3, r3, #12
	str	r3, [sp, #8]
	ldr	r0, .L7
	bl	GARLIC_printf
	ldr	r0, .L7+4
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L7+8
	bl	GARLIC_printf
	ldr	r0, .L7+4
	bl	GARLIC_printf
	ldr	r0, .L7+12
	bl	GARLIC_printf
	ldr	r0, [sp, #8]
	add	r3, sp, #24
	add	r2, sp, #12
	mov	r1, #19
	bl	GARLIC_divmod
	ldr	r0, [sp, #8]
	add	r3, sp, #20
	add	r2, sp, #12
	mov	r1, #4
	bl	GARLIC_divmod
	ldr	r0, [sp, #8]
	add	r3, sp, #16
	add	r2, sp, #12
	mov	r1, #7
	bl	GARLIC_divmod
	ldr	r2, [sp, #24]
	mov	r3, r2
	lsl	r3, r3, #3
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	add	r3, r3, #24
	str	r3, [sp, #36]
	add	r3, sp, #16
	add	r2, sp, #12
	mov	r1, #30
	ldr	r0, [sp, #36]
	bl	GARLIC_divmod
	ldr	r3, [sp, #12]
	str	r3, [sp, #36]
	ldr	r3, [sp, #16]
	lsl	r1, r3, #1
	ldr	r2, [sp, #36]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	add	r2, r1, r3
	ldr	r3, [sp, #20]
	add	r3, r2, r3
	lsl	r3, r3, #1
	add	r3, r3, #5
	str	r3, [sp, #32]
	add	r3, sp, #16
	add	r2, sp, #12
	mov	r1, #7
	ldr	r0, [sp, #32]
	bl	GARLIC_divmod
	ldr	r3, [sp, #12]
	str	r3, [sp, #32]
	ldr	r2, [sp, #36]
	ldr	r3, [sp, #32]
	add	r3, r2, r3
	add	r3, r3, #22
	str	r3, [sp, #28]
	ldr	r3, [sp, #28]
	cmp	r3, #31
	bhi	.L4
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #28]
	mov	r1, r3
	ldr	r0, .L7+16
	bl	GARLIC_printf
	b	.L5
.L4:
	ldr	r3, [sp, #28]
	sub	r3, r3, #31
	str	r3, [sp, #28]
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #28]
	mov	r1, r3
	ldr	r0, .L7+20
	bl	GARLIC_printf
.L5:
	ldr	r0, .L7+24
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #44
	@ sp needed
	ldr	pc, [sp], #4
.L8:
	.align	2
.L7:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
