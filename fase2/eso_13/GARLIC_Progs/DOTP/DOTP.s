	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"DOTP.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"********************************\000"
	.align	2
.LC1:
	.ascii	"*                              *\000"
	.align	2
.LC2:
	.ascii	"*      DOTP  -  PID (%d)        *\000"
	.align	2
.LC3:
	.ascii	"********************************\012\000"
	.align	2
.LC4:
	.ascii	"Se van a generar dos vectores\012con valores aleato"
	.ascii	"rios [-10..10]\012\000"
	.align	2
.LC5:
	.ascii	"La longitud de los vectores es:\012\000"
	.align	2
.LC6:
	.ascii	"1+2^arg --> 1+2^%d = %d\012\000"
	.align	2
.LC7:
	.ascii	"\012Contenido del vector 1:\012\000"
	.align	2
.LC8:
	.ascii	"[\000"
	.align	2
.LC9:
	.ascii	",\000"
	.align	2
.LC10:
	.ascii	"%d\000"
	.align	2
.LC11:
	.ascii	"-%d\000"
	.align	2
.LC12:
	.ascii	"]\012\000"
	.align	2
.LC13:
	.ascii	"\012Contenido del vector 2:\012\000"
	.align	2
.LC14:
	.ascii	"\012Producto escalar resultante: -%d\012\000"
	.align	2
.LC15:
	.ascii	"\012Producto escalar resultante: %d\012\000"
	.align	2
.LC16:
	.ascii	"\012Programa DOTP terminado\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 56
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	add	fp, sp, #32
	sub	sp, sp, #60
	str	r0, [fp, #-80]
	ldr	r3, [fp, #-80]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [fp, #-80]
	b	.L3
.L2:
	ldr	r3, [fp, #-80]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [fp, #-80]
.L3:
	ldr	r0, .L23
	bl	GARLIC_printf
	ldr	r0, .L23+4
	bl	GARLIC_printf
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L23+8
	bl	GARLIC_printf
	ldr	r0, .L23+4
	bl	GARLIC_printf
	ldr	r0, .L23+12
	bl	GARLIC_printf
	ldr	r0, .L23+16
	bl	GARLIC_printf
	mov	r3, #1
	str	r3, [fp, #-44]
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L4
.L5:
	mov	r3, #2
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L4:
	ldr	r3, [fp, #-80]
	ldr	r2, [fp, #-40]
	cmp	r2, r3
	bcc	.L5
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-52]
	ldr	r1, [fp, #-52]
	mov	r3, sp
	mov	r10, r3
	mov	r3, r1
	sub	r3, r3, #1
	str	r3, [fp, #-56]
	mov	r2, r1
	mov	r3, #0
	lsl	r0, r3, #5
	str	r0, [fp, #-88]
	ldr	r0, [fp, #-88]
	orr	r0, r0, r2, lsr #27
	str	r0, [fp, #-88]
	lsl	r3, r2, #5
	str	r3, [fp, #-92]
	mov	r2, r1
	mov	r3, #0
	lsl	r9, r3, #5
	orr	r9, r9, r2, lsr #27
	lsl	r8, r2, #5
	lsl	r3, r1, #2
	add	r3, r3, #3
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #3
	lsr	r3, r3, #2
	lsl	r3, r3, #2
	str	r3, [fp, #-60]
	ldr	r1, [fp, #-52]
	mov	r3, r1
	sub	r3, r3, #1
	str	r3, [fp, #-64]
	mov	r2, r1
	mov	r3, #0
	lsl	r7, r3, #5
	orr	r7, r7, r2, lsr #27
	lsl	r6, r2, #5
	mov	r2, r1
	mov	r3, #0
	lsl	r5, r3, #5
	orr	r5, r5, r2, lsr #27
	lsl	r4, r2, #5
	lsl	r3, r1, #2
	add	r3, r3, #3
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #3
	lsr	r3, r3, #2
	lsl	r3, r3, #2
	str	r3, [fp, #-68]
	ldr	r0, .L23+20
	bl	GARLIC_printf
	ldr	r2, [fp, #-52]
	ldr	r1, [fp, #-80]
	ldr	r0, .L23+24
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-48]
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L6
.L7:
	bl	GARLIC_random
	mov	r1, r0
	ldr	r3, .L23+28
	smull	r2, r3, r1, r3
	asr	r2, r3, #3
	asr	r3, r1, #31
	sub	r2, r2, r3
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #2
	sub	r2, r1, r3
	sub	r3, r2, #10
	mov	r1, r3
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	str	r1, [r3, r2, lsl #2]
	bl	GARLIC_random
	mov	r1, r0
	ldr	r3, .L23+28
	smull	r2, r3, r1, r3
	asr	r2, r3, #3
	asr	r3, r1, #31
	sub	r2, r2, r3
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #2
	sub	r2, r1, r3
	sub	r3, r2, #10
	mov	r1, r3
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-40]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	ldr	r3, [r3, r2, lsl #2]
	ldr	r2, [fp, #-68]
	ldr	r1, [fp, #-40]
	ldr	r2, [r2, r1, lsl #2]
	mul	r3, r2, r3
	str	r3, [fp, #-72]
	ldr	r2, [fp, #-48]
	ldr	r3, [fp, #-72]
	add	r3, r2, r3
	str	r3, [fp, #-48]
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L6:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	bcc	.L7
	ldr	r0, .L23+32
	bl	GARLIC_printf
	ldr	r0, .L23+36
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L8
.L13:
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	ldr	r3, [r3, r2, lsl #2]
	cmp	r3, #10
	bhi	.L9
	ldr	r3, [fp, #-40]
	cmp	r3, #0
	beq	.L10
	ldr	r0, .L23+40
	bl	GARLIC_printf
.L10:
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L23+44
	bl	GARLIC_printf
	b	.L11
.L9:
	ldr	r3, [fp, #-40]
	cmp	r3, #0
	beq	.L12
	ldr	r0, .L23+40
	bl	GARLIC_printf
.L12:
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	ldr	r3, [r3, r2, lsl #2]
	rsb	r1, r3, #0
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-60]
	ldr	r2, [fp, #-40]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L23+48
	bl	GARLIC_printf
.L11:
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L8:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	bcc	.L13
	ldr	r0, .L23+52
	bl	GARLIC_printf
	ldr	r0, .L23+56
	bl	GARLIC_printf
	ldr	r0, .L23+36
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-44]
	b	.L14
.L19:
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-44]
	ldr	r3, [r3, r2, lsl #2]
	cmp	r3, #10
	bhi	.L15
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	beq	.L16
	ldr	r0, .L23+40
	bl	GARLIC_printf
.L16:
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-44]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L23+44
	bl	GARLIC_printf
	b	.L17
.L15:
	ldr	r3, [fp, #-44]
	cmp	r3, #0
	beq	.L18
	ldr	r0, .L23+40
	bl	GARLIC_printf
.L18:
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-44]
	ldr	r3, [r3, r2, lsl #2]
	rsb	r1, r3, #0
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-44]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-68]
	ldr	r2, [fp, #-44]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L23+48
	bl	GARLIC_printf
.L17:
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-44]
.L14:
	ldr	r2, [fp, #-44]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	bcc	.L19
	ldr	r0, .L23+52
	bl	GARLIC_printf
	ldr	r3, [fp, #-48]
	cmp	r3, #900
	bls	.L20
	ldr	r3, [fp, #-48]
	rsb	r3, r3, #0
	str	r3, [fp, #-48]
	ldr	r1, [fp, #-48]
	ldr	r0, .L23+60
	bl	GARLIC_printf
	b	.L21
.L20:
	ldr	r1, [fp, #-48]
	ldr	r0, .L23+64
	bl	GARLIC_printf
.L21:
	ldr	r0, .L23+68
	bl	GARLIC_printf
	mov	r3, #0
	mov	sp, r10
	mov	r0, r3
	sub	sp, fp, #32
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}
.L24:
	.align	2
.L23:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	1717986919
	.word	.LC7
	.word	.LC8
	.word	.LC9
	.word	.LC10
	.word	.LC11
	.word	.LC12
	.word	.LC13
	.word	.LC14
	.word	.LC15
	.word	.LC16
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
