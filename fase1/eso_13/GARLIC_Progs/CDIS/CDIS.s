	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"CDIS.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"********************************\000"
	.align	2
.LC1:
	.ascii	"*                              *\000"
	.align	2
.LC2:
	.ascii	"*      CDIS  -  PID (%d)        *\000"
	.align	2
.LC3:
	.ascii	"Calculant metres (aleatori)...\012\000"
	.align	2
.LC4:
	.ascii	"Calcul finalitzat.\012\000"
	.align	2
.LC5:
	.ascii	"\012Numero de metres: %d\012\000"
	.align	2
.LC6:
	.ascii	"\012Calculant conversio a milles...\012\000"
	.align	2
.LC7:
	.ascii	"%d metres = %d.\000"
	.align	2
.LC8:
	.ascii	"%d milles\012\000"
	.align	2
.LC9:
	.ascii	"\012Calculant conversio a iardes...\012\000"
	.align	2
.LC10:
	.ascii	"%d iardes\012\000"
	.align	2
.LC11:
	.ascii	"\012Calculant conversio a peus...\012\000"
	.align	2
.LC12:
	.ascii	"%d peus\012\000"
	.align	2
.LC13:
	.ascii	"Final programa CDIS\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #36
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
	ldr	r0, .L7
	bl	GARLIC_printf
	ldr	r3, [sp, #4]
	add	r3, r3, #1
	str	r3, [sp, #4]
	mov	r3, #1
	str	r3, [sp, #24]
	mov	r3, #0
	str	r3, [sp, #28]
	b	.L4
.L5:
	mov	r3, #10
	str	r3, [sp, #24]
	ldr	r3, [sp, #28]
	add	r3, r3, #1
	str	r3, [sp, #28]
.L4:
	ldr	r3, [sp, #4]
	ldr	r2, [sp, #28]
	cmp	r2, r3
	bcc	.L5
	ldr	r0, .L7+12
	bl	GARLIC_printf
	bl	GARLIC_random
	mov	r3, r0
	mov	r0, r3
	add	r3, sp, #8
	add	r2, sp, #16
	ldr	r1, [sp, #24]
	bl	GARLIC_divmod
	ldr	r0, .L7+16
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	mov	r1, r3
	ldr	r0, .L7+20
	bl	GARLIC_printf
	ldr	r0, .L7+24
	bl	GARLIC_printf
	ldr	r2, [sp, #8]
	mov	r3, r2
	lsl	r3, r3, #5
	sub	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [sp, #20]
	add	r3, sp, #12
	add	r2, sp, #16
	ldr	r1, .L7+28
	ldr	r0, [sp, #20]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L7+32
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	mov	r0, r3
	bl	mostrar_zeros
	ldr	r3, [sp, #12]
	mov	r1, r3
	ldr	r0, .L7+36
	bl	GARLIC_printf
	ldr	r0, .L7+40
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	ldr	r2, .L7+44
	mul	r3, r2, r3
	str	r3, [sp, #20]
	add	r3, sp, #12
	add	r2, sp, #16
	ldr	r1, .L7+28
	ldr	r0, [sp, #20]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L7+32
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	mov	r0, r3
	bl	mostrar_zeros
	ldr	r3, [sp, #12]
	mov	r1, r3
	ldr	r0, .L7+48
	bl	GARLIC_printf
	ldr	r0, .L7+52
	bl	GARLIC_printf
	ldr	r3, [sp, #8]
	ldr	r2, .L7+56
	mul	r3, r2, r3
	str	r3, [sp, #20]
	add	r3, sp, #12
	add	r2, sp, #16
	ldr	r1, .L7+28
	ldr	r0, [sp, #20]
	bl	GARLIC_divmod
	ldr	r3, [sp, #8]
	ldr	r2, [sp, #16]
	mov	r1, r3
	ldr	r0, .L7+32
	bl	GARLIC_printf
	ldr	r3, [sp, #12]
	mov	r0, r3
	bl	mostrar_zeros
	ldr	r3, [sp, #12]
	mov	r1, r3
	ldr	r0, .L7+60
	bl	GARLIC_printf
	ldr	r0, .L7+64
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #36
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
	.word	100000
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	109361
	.word	.LC10
	.word	.LC11
	.word	328084
	.word	.LC12
	.word	.LC13
	.size	_start, .-_start
	.section	.rodata
	.align	2
.LC14:
	.ascii	"0\000"
	.text
	.align	2
	.global	mostrar_zeros
	.syntax unified
	.arm
	.fpu softvfp
	.type	mostrar_zeros, %function
mostrar_zeros:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #28
	str	r0, [sp, #4]
	mov	r3, #0
	str	r3, [sp, #20]
	mov	r3, #1
	str	r3, [sp, #16]
	ldr	r0, [sp, #4]
	add	r3, sp, #8
	add	r2, sp, #12
	ldr	r1, [sp, #16]
	bl	GARLIC_divmod
	b	.L10
.L11:
	ldr	r2, [sp, #16]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [sp, #16]
	ldr	r3, [sp, #20]
	add	r3, r3, #1
	str	r3, [sp, #20]
	ldr	r0, [sp, #4]
	add	r3, sp, #8
	add	r2, sp, #12
	ldr	r1, [sp, #16]
	bl	GARLIC_divmod
.L10:
	ldr	r3, [sp, #12]
	cmp	r3, #0
	bne	.L11
	ldr	r3, [sp, #20]
	cmp	r3, #4
	bhi	.L15
	ldr	r3, [sp, #20]
	rsb	r3, r3, #5
	str	r3, [sp, #20]
	b	.L13
.L14:
	ldr	r0, .L16
	bl	GARLIC_printf
	ldr	r3, [sp, #20]
	sub	r3, r3, #1
	str	r3, [sp, #20]
.L13:
	ldr	r3, [sp, #20]
	cmp	r3, #0
	bne	.L14
.L15:
	nop
	add	sp, sp, #28
	@ sp needed
	ldr	pc, [sp], #4
.L17:
	.align	2
.L16:
	.word	.LC14
	.size	mostrar_zeros, .-mostrar_zeros
	.ident	"GCC: (devkitARM release 46) 6.3.0"
