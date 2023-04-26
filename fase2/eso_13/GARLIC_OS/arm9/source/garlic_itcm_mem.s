@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 2.0)
@;
@;==============================================================================

NUM_FRANJAS = 768
INI_MEM_PROC = 0x01002000


.section .dtcm,"wa",%progbits
	.align 2

	.global _gm_zocMem
_gm_zocMem:	.space NUM_FRANJAS			@; vector de ocupación de franjas mem.


.section .itcm,"ax",%progbits

	.arm
	.align 2


.global _gm_reubicar
	@; Rutina de soporte a _gm_cargarPrograma(), que interpreta los 'relocs'
	@; de un fichero ELF, contenido en un buffer *fileBuf, y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, a partir de las direcciones de memoria destino de código
	@; (dest_code) y datos (dest_data), y según el valor de las direcciones de
	@; las referencias a reubicar y de las direcciones de inicio de los
	@; segmentos de código (pAddr_code) y datos (pAddr_data)
	@;Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento de código (unsigned int pAddr_code)
	@; R2: dirección de destino en la memoria (unsigned int *dest_code)
	@; R3: dirección de inicio de segmento de datos (unsigned int pAddr_data)
	@; (pila): dirección de destino en la memoria (unsigned int *dest_data)
	@;Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
	push {r0-r12, lr}
	sub r2, r1				@;Valor para reubicar code (r2)
	ldr r12, [sp, #56]		@;Cargamos (unsigned int *dest_data)
	sub r12, r3				@;Valor para reubicar data (r12)
	
	@;Cálculo de los offsets de e_shoff, e_shsize i e_shnum:
	ldr r4, [r0, #32] 		@;Offset primera tabla de secciones
							@;e_shoff = 16 char* de e_ident + 2 half + 3 word = 16 + 2*2 + 3*4 = 32 bytes //falta hacer defines?
							
	ldrh r10, [r0, #46]		@;Tamaño de las tablas
							@;e_shsize = 16 char* de e_ident + 6 half + 5 word = 16 + 6*2 + 4*4 = 44 bytes
							
	ldrh r5, [r0, #48]		@;Cantidad de tablas
							@;e_shnum = 16 char* de e_ident + 6 half + 5 word = 16 + 6*2 + 5*4 = 48 bytes
	add r4, r0
.LforSecciones:
	ldr r9, [r4, #4]		@;Tipo de la sección, offset=4, salto el primer word
	cmp r9, #9
	bne .LNoReloc			@;Si es reloc la tratamos
	ldr r6, [r4, #16]		@;Cargo el offset de la sección i accedo
	ldr r7, [r4, #20]		@;Cargo el tamaño de la sección
	ldr r8, [r4, #36]		@;Cargo el tamaño del reloc (8 bytes casi siempre)
	add r6, r0
.LforRelocs:
	ldr r9, [r6, #4]		@;Cargamos el campo info del reloc
	and r9, #0b11111111		@;Limpiamos los bits altos (solo 8 bajos)
	cmp r9, #2				@;Queremos los de tipo 2, sino salta al siguiente
	bne .LNoReubica
	ldr r9, [r6]			@;Cargamos el offset del reloc 
	add r9, r2				@;Convertimos offset malloc a offset en mem
	ldr r1, [r9]			@;Cargamos el valor del reloc
	cmp r3, #0
	addeq r1, r2			@;Cambiamos en valor del reloc si solo hay 1 segmento
	beq .L1seg
	cmp r1, r3				@;Si son 2, Comprovamos el rango de la direccion, codigo o datos
	addlo r1, r2			
	addhs r1, r12
.L1seg:
	str r1, [r9]			@;Guargamos el reloc
.LNoReubica:
	sub r7, r8				@;Restamos el tamaño del reloc del total de la sección
	add r6, r8				@;El offset del siguiente reloc es: offset actual + tamaño de reloc
	cmp r7, #0				@;Si no es el último, repetimos
	bne .LforRelocs
.LNoReloc:
	sub r5, #1			
	add r4, r10				@;El offset de la siguiente tabla es: offset actual + tamaño de tabla
	cmp r5, #0				@;Decrementamos el num de secciones, si es la última, acabamos
	bne .LforSecciones
	pop {r0-r12, pc}


	.global _gm_reservarMem
	@; Rutina para reservar un conjunto de franjas de memoria libres
	@; consecutivas que proporcionen un espacio suficiente para albergar
	@; el tamaño de un segmento de código o datos del proceso (según indique
	@; tipo_seg), asignado al número de zócalo que se pasa por parámetro;
	@; también se encargará de invocar a la rutina _gm_pintarFranjas(), para
	@; representar gráficamente la ocupación de la memoria de procesos;
	@; la rutina devuelve la primera dirección del espacio reservado; 
	@; en el caso de que no quede un espacio de memoria consecutivo del
	@; tamaño requerido, devuelve cero.
	@;Parámetros:
	@;	R0: el número de zócalo que reserva la memoria
	@;	R1: el tamaño en bytes que se quiere reservar
	@;	R2: el tipo de segmento reservado (0 -> código, 1 -> datos)
	@;Resultado:
	@;	R0: dirección inicial de memoria reservada (0 si no es posible)
_gm_reservarMem:
	push {r1-r7, lr}
	mov r3, r2					@;Registros: r2: vector de mem		r3:tipo de segm		r4:cargar valor mem	
	ldr r2, =#_gm_zocMem
	mov r6, r1
	mov r5, #0					@;r5:indice bucle de zanjas		r6:Contador libres consecutivos, restamos tamaño de franja		r7;total consecutivas
	mov r7, #0
.Lbucle_franja:
	cmp r5, #NUM_FRANJAS
	moveq r0, #0
	beq .Lfinal_reservar		@;Comprovación de final, si es la última franja acaba i devuelve 0
	ldrb r4, [r2, r5]			@;Carga el zocalo que està en la franja
	add r5, #1
	cmp r4, #0 					@;Si está libre, restamos al tamaño que falta y sumamos al total de consecutivas
	subeq r6, #32
	addeq r7, #1
	movne r6, r1				@;Si está ocupado, reiniciamos el tamaño restante y las consecutivas
	movne r7, #0
	cmp r6, #0					@;Si ya no quedan bytes para almacenar, pintamos, sino sigue el bucle
	bgt .Lbucle_franja
	mov r6, r2
	mov r2, r7					@;Total consecutivas
	rsb r7, r5					
	mov r1, r7					@;Indice inicial de franja (actual-consecutivas)
.LEscriuMatriu:
	strb r0, [r6, r7]			@;Guarda en la matriz todas las consecutivas
	add r7, #1
	cmp r7, r5
	blo .LEscriuMatriu
	bl _gm_pintarFranjas		@;Pinta franjas r0:zocalo r1:Inicio r2:Consecutivas r3:data o code
	mov r2, #32
	ldr r3, =#INI_MEM_PROC
	mla r0, r1, r2, r3 			@;Devuelve la direccion de inicio de franja, donde se tendrá que copiar el prog
.Lfinal_reservar:
	pop {r1-r7, pc}


	.global _gm_liberarMem
	@; Rutina para liberar todas las franjas de memoria asignadas al proceso
	@; del zócalo indicado por parámetro; también se encargará de invocar a la
	@; rutina _gm_pintarFranjas(), para actualizar la representación gráfica
	@; de la ocupación de la memoria de procesos.
	@;Parámetros:
	@;	R0: el número de zócalo que libera la memoria
_gm_liberarMem:
	push {r0-r6, lr}
	mov r5, #-1				@;Inicializaciones: r2:Franjas consecutivas	  r3:matriz    r1:inice primera     r5:incice de bucle del vector
	mov r1, #0
	mov r2, #0
	mov r6, #17
	ldr r3, =_gm_zocMem
.Lbucle_nextf:
	add r5, #1
	ldrb r4, [r3, r5]
	cmp r4, r6				@;Comprueba si ha cambiado de num de zocalo
	bne .Llibera_pinta
.Lfin_pinta:	
	mov r6, r4
	cmp r5, #NUM_FRANJAS	@;Comprueba final
	beq .Lfinal_liberar
	cmp r0, r4				@;Salta a la sigüiente
	bne .Lbucle_nextf
	mov r4, #0
	strb r4, [r3, r5]
	cmp r1, #0				@;Si es la primera, guarda inicio, además suma consecutivas
	moveq r1, r5
	add r2, #1
	b .Lbucle_nextf
.Llibera_pinta:				
	cmp r6, r0				@;Si el cambio no es del que queremos borrar no pintamos
	bne .Lfin_pinta
	mov r6, r0				@;Guarda registros
	mov r0, #0
	mov r3, #0				@;R3 a 0 para que borre todos, no ajedrezado
	bl _gm_pintarFranjas
	mov r0, r6				@;Restaura regs
	ldr r3, =_gm_zocMem
	mov r2, #0				@;Reinicia contadores de consec i de primero
	mov r1, #0
	b .Lfin_pinta
.Lfinal_liberar:
	pop {r0-r6,pc}


	.global _gm_pintarFranjas
	@; Rutina para para pintar las franjas verticales correspondientes a un
	@; conjunto de franjas consecutivas de memoria asignadas a un segmento
	@; (de código o datos) del zócalo indicado por parámetro.
	@;Parámetros:
	@;	R0: el número de zócalo que reserva la memoria (0 para borrar)
	@;	R1: el índice inicial de las franjas
	@;	R2: el número de franjas a pintar
	@;	R3: el tipo de segmento reservado (0 -> código, 1 -> datos)
_gm_pintarFranjas:

	push {r0-r9, lr}
	ldr r4, =0x620c000		@;Inicio del mapa Submap charbase(0x6204000) más offset 512*64 = 0x8000
	ldr r5,=_gs_colZoc
	ldrb r0, [r5, r0]		@;cargo el color en r0
	and r5, r1, #0b111		@;Offset en baldosa inicial
	lsr r1, #3				@;Baldosa inicial
	cmp r3, #0				@;Ajedrezado o completo
	moveq r3, r0
	movne r3, #0
	tst r5, #1
	bne .LPintaNomesUn
.Linici_bucle_pinta:
	mov r7, #0x40
	mla r7, r1, r7, r5		@;Me situo al principio de la baldosa
	add r7, #0x10			@;Me situo en la fila 3
	
	orr r6, r0, r3, lsl #8
	strh r6, [r4, r7]		@;Pinto y paso a la siguiente fila x3
	add r7, #8
	
	orr r6, r3, r0, lsl #8
	strh r6, [r4, r7]
	add r7, #8
	
	orr r6, r0, r3, lsl #8
	strh r6, [r4, r7]		@;Pinto y paso a la siguiente fila x3
	add r7, #8
	
	orr r6, r3, r0, lsl #8
	strh r6, [r4, r7]
	
	add r5, #2				@;Siguiente franja, ajusto baldosa y offset
	cmp r5, #8
	moveq r5, #0
	addeq r1, #1
	sub r2, #2				@;Comprovación de final
	cmp r2, #1
	beq .LPintaNomesUn
	bhi .Linici_bucle_pinta
	b .LAcabaPintar
.LPintaNomesUn:
	mov r7, #0x40
	mla r7, r1, r7, r5		@;Me situo al principio de la baldosa
	add r7, #0x10			@;Me situo en la fila 3
	cmp r2, #1					@;Cas de pintar ultim bit, bit baix, sino primer bit, bit alt
	moveq r8, #0xFF00			@;Mascara per bits 
	movne r8, #0xFF
	mov r9, #4
.LBuclePintaUn:
	ldrh r6, [r4, r7]
	and r6, r8					@;Limpio bits donde pongo el color
	cmp r8, #0xFF 
	orreq r6, r0, lsl #8
	orrne r6, r0
	strh r6, [r4, r7]		@;Pinto y paso a la siguiente fila x3
	add r7, #8
	cmp r3, r0				@;Caso de ajedrezado cambio de paridad
	movne r6, r0
	movne r0, r3
	movne r3, r6
	sub r9, #1
	cmp r9, #0
	bne .LBuclePintaUn
	cmp r2, #1
	beq .LAcabaPintar
	sub r2, #1
	add r5, #1				@;Siguiente franja, ajusto baldosa y offset
	cmp r5, #8
	moveq r5, #0
	addeq r1, #1
	b .Linici_bucle_pinta
.LAcabaPintar:
	pop {r0-r9, pc}


	.global _gm_rsiTIMER1
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la representa-
	@; ción de la pila y el estado de los procesos activos.
	@; Posiciones por fila: 23 y 24 para pila, 26 para estado
	@; Pilas de 128 posiciones / 17 representaciones de ocupación
_gm_rsiTIMER1:
	push {r0-r6,lr}
	mov r1, #0						@; Zocalo
	mov r2, #0						@; Baldosa zocalo vacio, negra
	mov r3, #52						@; Columna del estado, (columna 26 x 2)
	ldr r0, =0x6200100
	@; Bucle para poner todas las posiciones a negro
	.LpintaNegro:
	strh r2, [r0, r3]
	add r3, #64						@; Siguiente fila (32x2)
	add r1, #1						@; zócalo 
	cmp r1, #16						@; ¿último zocalo?
	blo .LpintaNegro
	
	@; Representación letras en función del estado del programa
	.LzocalosReady:
	ldr r1, =_gd_qReady
	ldr r3, =_gd_nReady
	ldr r2, [r3]					@; Número de procesos a Ready
	mov r4, #0x39					@; Baldosa de Y blanca
	.LbucleZocalosReady:
	sub r2, #1						@; Contador
	ldr r3, [r1, r2]				@; Zocalo Ready
	mov r3, r3, lsr #24						
	add r3, r0, r3, lsl #6			@; inicio + zocalo*64 (Bxfila) --> half
	strh r4, [r3, #52]				@; Color blanco en fila del zócalo X, posición 52(E)
	cmp r2, #0						@; final?
	bge .LbucleZocalosReady
	
	.LzocalosTeclado:
	ldr r1, =_gd_qKbwait
	ldr r3, =_gd_nKbwait
	ldrb r2, [r3]					@; Número de procesos a teclado
	mov r4, #0x2B					@; Baldosa de K blanca
	.LbucleZocalosTeclado:
	sub r2, #1
	cmp r2, #0						@; Contador
	blt .LzocaloRun
	ldrb r3, [r1, r2]				@; Zocalo teclado, cola teclado bytes				
	add r3, r0, r3, lsl #6			@; inicio + zocalo*64 (Bxfila) --> half
	strh r4, [r3, #52]				@; Color blanco en fila del zócalo X, posición 52(E)
	b .LbucleZocalosTeclado
	
	.LzocaloRun:
	ldr r1, =_gd_pidz
	ldr r3, [r1]					@; Busco el zócalo que está en run
	and r3, #0b1111					@; 4 bits bajos --> zócalo
	add r3, r0, r3, lsl #6			@; offset + zocalo*64 (Bxfila) --> half
	mov r2, #0xb2					@; Color azul? 0x1b2?
	strh r2, [r3, #52]				@; Color azul en fila del zócalo X, posición 52(R)
	
	.LzocalosBlocked:
	ldr r1, =_gd_qDelay
	ldr r3, =_gd_nDelay
	ldr r2, [r3]					@; Número de procs Delayed
	mov r4, #0x22					@; Baldosa D blanca
	.LbucleZocalosBlocked:
	sub r2, #1
	cmp r2, #0						@; @; Contador
	blt .LPila
	ldr r3, [r1, r2]				@; Zocalo blocked
	lsr r3, #24						
	add r3, r0, r3, lsl #6			@; inicio + zocalo*64 (Bxfila) --> half
	strh r4, [r3, #52]				@; Color blanco en fila del zócalo X, posición 52(B)
	b .LbucleZocalosBlocked			@; final?
	
	@; Representación de la memoria con dos baldosas --> 17 niveles
	@; 128 words / 17 
	@; 9 de 8 y 8 de 7 --> alternas
	.LPila:
	ldr r1, =_gd_pcbs				@; PCBs activos
	ldr r2, =0xb003d00				@; Pila
	mov r5, #0
	ldr r4, [r1, #8]
	cmp r4, #0
	ldreq r4, =0xb003d00
	.Lcontinua:
	sub r3, r2, r4					@; Valores de ocup (entre 0 y 128)
	lsr r3, #2
	mov r4, #0
	.LforCalculaPila:				
	sub r3, #8
	add r4, #1
	cmp r3,	#0
	ble .LpintaPila
	sub r3, #7
	add r4, #1
	cmp r3,	#0
	bgt .LforCalculaPila
	.LpintaPila:
	cmp r4, #18
	movgt r4, #18				
	cmp r4, #9					
	addhi r4, #109
	addls r3, r4, #118
	movhi r3, #127
	movls r4, #119
	.LnoOcupado:	
	strh r3, [r0, #46]			@; Tiles
	strh r4, [r0, #48]
	add r5, #1
	cmp r5, #16
	bhs .LFin
	add r0, #64					
	add r1, #24					
	cmp r5, #1
	ldreq r2, =_gd_stacks		
	add r2, #512				
	ldr r4, [r1]				@; >0 ? ocupado?
	cmp r4, #0
	ldrne r4, [r1, #8]			@; Top pila
	bne .Lcontinua
	mov r3, #0
	mov r4, #0
	b .LnoOcupado
	.LFin:
	
	pop {r0-r6,pc}
	
.end

