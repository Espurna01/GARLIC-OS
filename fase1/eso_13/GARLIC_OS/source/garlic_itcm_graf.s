@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 1.0)
@;
@;==============================================================================

NVENT	= 4					@; número de ventanas totales
PPART	= 2					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 1				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 36				@; longitud de cada buffer de ventana (32+4)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gg_escribirLinea
	@; Rutina para escribir toda una linea de caracteres almacenada en el
	@; buffer de la ventana especificada;
	@;Parámetros:
	@;	R0: ventana a actualizar (int v)
	@;	R1: fila actual (int f)
	@;	R2: número de caracteres a escribir (int n)
_gg_escribirLinea:
	push {r3-r7, lr}
	
	@; desplazamiento de columnas
	mov r4, #VCOLS
	and r3, r0, #L2_PPART	@; r3 = v % PPART
	mul r5, r4, r3			@; r5 = VCOLS * (v % PPART) 
	
	@; desplazamiento de filas
	mov r4, #VFILS
	mov r6, r0, lsr #L2_PPART	@; r6 = v / PPART
	mul r3, r6, r4			@; r3 = (v / PPART) * VFILS
	mov r6, #PCOLS
	mul r4, r3, r6			@; r4 = (v / PPART) * VFILS * PCOLS
	
	@; desplazamiento de ventana
	add r3, r4, r5			@; r3 = despl. filas + despl. columnas
	
	@; desplazamiento de fila actual en ventana
	mla r7, r1, r6, r3		@; r7 = filaAct * PCOLS + despl. ventana
	
	@; sumamos despl. filaAct en ventana a la dirección del mapa bg2A
	ldr r3, =bg2Amap
	ldr r3, [r3]			@; cargamos la dirección del mapa de bg2A
	mov r7, r7, lsl #1				@; adaptación nº baldosas a bytes (1 baldosa --> 2 bytes)
	add r3, r7				@; r3 = dirección del mapa + despl. total
	
	ldr  r4, =_gd_wbfs		@; dirección del vector de WBFS
	mov r5, #WBUFS_LEN
	mul r6, r5, r0			@; nos situamos en la posición del vector
							@; correspondiente a nuestra ventana
	add r4, r6				
	add r4, #4 				@; r4 = posicion inicial pChars (16 bits bajos)
	
	@; Guardamos las baldosas en la dirección de mapa indicada
	mov r5, #0				@; indice del bucle (chars añadidos)
.Lescribir:
	ldrb r6, [r4, r5]		@; r6 = _gd_wbfs[v].pChars[i]
	sub r6, #32				@; restamos 32 al código ASCII para obtener indice de baldosa
	strh r6, [r3]			@; guardamos el índice de baldosa en la dirección calculada del mapa
	add r5, #1				@; incrementamos contador
	add r3, #2				@; avanzamos posición en el mapa (al ser halfword sumamos 2)
	cmp r5, r2				@; comprobamos carácteres a escribir
	blo .Lescribir			@; en caso de queden carácteres por escribir se efectuará otra iteración
	
	pop {r3-r7, pc}


	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r1-r7, lr}
	
	@; desplazamiento columnas
	mov r1, #VCOLS
	and r2, r0, #L2_PPART	@; r2 = v % PPART
	mul r3, r1, r2			@; r3 = VCOLS * (v % PPART)
	
	@; desplazamiento filas
	mov r1, #VFILS
	mov r4, r0, lsr #L2_PPART	@; r4 = v / PPART
	mul r2, r4, r1			@; r2 = (v / PPART) * VFILS
	mov r5, #PCOLS
	mul r6, r2, r5			@; r6 = (v / PPART) * VFILS * PCOLS
	
	@; desplazamiento de ventana
	add r4, r6, r3			@; despl. filas + despl. columnas
	
	@; sumamos desplazamiento a la dirección del mapa bg2A
	ldr r1, =bg2Amap
	ldr r1, [r1]			@; cargamos la dirección del mapa de bg2A
	mov r4, r4, lsl #1				@; adaptación nº baldosas a bytes (1 baldosa --> 2 bytes)
	add r1, r4				@; r1 = dirección del mapa + despl. total
	mov r2, r1
	mov r5, r5, lsl #1			
	add r2, r5				@; r2 = fila actual + despl. de una fila
	
	mov r3, #VFILS
.Ldespl_inicio:
	mov r4, #0				@; indice del bucle
	mov r7, #VCOLS
	
.Ldespl_siguiente:
	ldrh r6, [r2, r4]		@; r6 = fila_sig[i]
	strh r6, [r1, r4]		@; fila_act[i] = r6
	sub r7, #1
	add r4, #2				@; indice de baldosa --> halfword (avanzar 2 posiciones)
	cmp r7, #0
	bhi .Ldespl_siguiente
	
	add r1, r5				@; avanzamos fila actual
	add r2, r5				@; avanzamos fila siguiente
	sub r3, #1				
	cmp r3, #0
	bhi .Ldespl_inicio		@; si (filas > 0) cambiamos de fila
	@; sino --> hemos llegado a la fila final
	sub r1, r5				@; restablecemos fila actual		
	sub r2, r5				@; restablecemos fila siguiente

	mov r3, #0
	mov r4, #0	
	mov r7, #VCOLS
.Ldespl_final:			@; ponemos espacios en blanco hasta llegar al final de la fila
	strh r3, [r1, r4]
	sub r7, #1
	add r4, #2				
	cmp r7, #0
	bhi .Ldespl_final

	pop {r1-r7, pc}

.end

