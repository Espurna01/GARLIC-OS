	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"DPAS.c"
	.comm	dias,40,4
	.comm	meses,40,4
	.global	anys
	.data
	.align	2
	.type	anys, %object
	.size	anys, 40
anys:
	.word	2
	.word	3
	.word	5
	.word	7
	.word	11
	.word	13
	.word	17
	.word	19
	.word	23
	.word	29
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
	ldr	r0, .L9
	bl	GARLIC_printf
	ldr	r0, .L9+4
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L9+8
	bl	GARLIC_printf
	ldr	r0, .L9+4
	bl	GARLIC_printf
	ldr	r0, .L9+12
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #36]
	b	.L4
.L7:
	ldr	r2, .L9+16
	ldr	r3, [sp, #36]
	ldr	r0, [r2, r3, lsl #2]
	add	r3, sp, #20
	add	r2, sp, #8
	mov	r1, #19
	bl	GARLIC_divmod
	ldr	r2, .L9+16
	ldr	r3, [sp, #36]
	ldr	r0, [r2, r3, lsl #2]
	add	r3, sp, #16
	add	r2, sp, #8
	mov	r1, #4
	bl	GARLIC_divmod
	ldr	r2, .L9+16
	ldr	r3, [sp, #36]
	ldr	r0, [r2, r3, lsl #2]
	add	r3, sp, #12
	add	r2, sp, #8
	mov	r1, #7
	bl	GARLIC_divmod
	ldr	r2, [sp, #20]
	mov	r3, r2
	lsl	r3, r3, #3
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	add	r3, r3, #24
	str	r3, [sp, #32]
	add	r3, sp, #12
	add	r2, sp, #8
	mov	r1, #30
	ldr	r0, [sp, #32]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	str	r3, [sp, #32]
	ldr	r3, [sp, #12]
	lsl	r1, r3, #1
	ldr	r2, [sp, #32]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	add	r2, r1, r3
	ldr	r3, [sp, #16]
	add	r3, r2, r3
	lsl	r3, r3, #1
	add	r3, r3, #5
	str	r3, [sp, #28]
	add	r3, sp, #12
	add	r2, sp, #8
	mov	r1, #7
	ldr	r0, [sp, #28]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	str	r3, [sp, #28]
	ldr	r2, [sp, #32]
	ldr	r3, [sp, #28]
	add	r3, r2, r3
	add	r3, r3, #22
	str	r3, [sp, #24]
	ldr	r1, .L9+20
	ldr	r3, [sp, #36]
	ldr	r2, [sp, #24]
	str	r2, [r1, r3, lsl #2]
	ldr	r3, [sp, #24]
	cmp	r3, #31
	bhi	.L5
	ldr	r2, .L9+16
	ldr	r3, [sp, #36]
	ldr	r3, [r2, r3, lsl #2]
	ldr	r2, [sp, #24]
	mov	r1, r3
	ldr	r0, .L9+24
	bl	GARLIC_printf
	ldr	r2, .L9+28
	ldr	r3, [sp, #36]
	mov	r1, #3
	str	r1, [r2, r3, lsl #2]
	b	.L6
.L5:
	ldr	r3, [sp, #24]
	sub	r3, r3, #31
	str	r3, [sp, #24]
	ldr	r2, .L9+16
	ldr	r3, [sp, #36]
	ldr	r3, [r2, r3, lsl #2]
	ldr	r2, [sp, #24]
	mov	r1, r3
	ldr	r0, .L9+32
	bl	GARLIC_printf
	ldr	r2, .L9+28
	ldr	r3, [sp, #36]
	mov	r1, #4
	str	r1, [r2, r3, lsl #2]
.L6:
	ldr	r0, .L9+36
	bl	GARLIC_printf
	ldr	r3, [sp, #36]
	add	r3, r3, #1
	str	r3, [sp, #36]
.L4:
	ldr	r3, [sp, #36]
	cmp	r3, #9
	ble	.L7
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #44
	@ sp needed
	ldr	pc, [sp], #4
.L10:
	.align	2
.L9:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	anys
	.word	dias
	.word	.LC4
	.word	meses
	.word	.LC5
	.word	.LC6
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
