	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"PERF.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"********************************\000"
	.align	2
.LC1:
	.ascii	"*                              *\000"
	.align	2
.LC2:
	.ascii	"*      PERF  -  PID (%d)        *\000"
	.align	2
.LC3:
	.ascii	"\012Buscando num perf entre [0, %d]...\012\000"
	.align	2
.LC4:
	.ascii	"Numeros encontrados:\012\011{\000"
	.align	2
.LC5:
	.ascii	", \000"
	.align	2
.LC6:
	.ascii	"%d\000"
	.align	2
.LC7:
	.ascii	"}\012Busqueda finalizada. Total = %d\000"
	.align	2
.LC8:
	.ascii	"\012Programa PERF terminado\012\000"
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
	ldr	r0, .L10
	bl	GARLIC_printf
	ldr	r0, .L10+4
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L10+8
	bl	GARLIC_printf
	ldr	r0, .L10+4
	bl	GARLIC_printf
	ldr	r0, .L10
	bl	GARLIC_printf
	ldr	r3, [sp, #4]
	add	r3, r3, #10
	mov	r2, #1
	lsl	r3, r2, r3
	str	r3, [sp, #20]
	mov	r3, #0
	str	r3, [sp, #32]
	ldr	r1, [sp, #20]
	ldr	r0, .L10+12
	bl	GARLIC_printf
	ldr	r0, .L10+16
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #36]
	b	.L2
.L8:
	mov	r3, #0
	str	r3, [sp, #28]
	mov	r3, #1
	str	r3, [sp, #24]
	b	.L3
.L5:
	ldr	r1, [sp, #24]
	add	r3, sp, #12
	add	r2, sp, #16
	ldr	r0, [sp, #36]
	bl	GARLIC_divmod
	ldr	r3, [sp, #12]
	cmp	r3, #0
	bne	.L4
	ldr	r2, [sp, #28]
	ldr	r3, [sp, #24]
	add	r3, r2, r3
	str	r3, [sp, #28]
.L4:
	ldr	r3, [sp, #24]
	add	r3, r3, #1
	str	r3, [sp, #24]
.L3:
	ldr	r3, [sp, #24]
	lsl	r3, r3, #1
	mov	r2, r3
	ldr	r3, [sp, #36]
	cmp	r2, r3
	bls	.L5
	ldr	r2, [sp, #28]
	ldr	r3, [sp, #36]
	cmp	r2, r3
	bne	.L6
	ldr	r3, [sp, #28]
	cmp	r3, #0
	beq	.L6
	ldr	r3, [sp, #32]
	cmp	r3, #0
	beq	.L7
	ldr	r0, .L10+20
	bl	GARLIC_printf
.L7:
	ldr	r1, [sp, #36]
	ldr	r0, .L10+24
	bl	GARLIC_printf
	ldr	r3, [sp, #32]
	add	r3, r3, #1
	str	r3, [sp, #32]
.L6:
	ldr	r3, [sp, #36]
	add	r3, r3, #1
	str	r3, [sp, #36]
.L2:
	ldr	r2, [sp, #36]
	ldr	r3, [sp, #20]
	cmp	r2, r3
	bls	.L8
	ldr	r1, [sp, #32]
	ldr	r0, .L10+28
	bl	GARLIC_printf
	ldr	r0, .L10+32
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #44
	@ sp needed
	ldr	pc, [sp], #4
.L11:
	.align	2
.L10:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
