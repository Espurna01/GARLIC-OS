@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	código de rutinas de soporte a la gestión de
@;							ventanas gráficas (versión 2.0)
@;
@;==============================================================================

NVENT	= 16					@; número de ventanas totales
PPART	= 4					@; número de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 2				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; número de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; número de filas totales (en pantalla)

WBUFS_LEN = 68				@; longitud de cada buffer de ventana (64+4)

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
	push {r3-r8, lr}
	
	mov r8, r0
	
	bl _gg_calcularDesplVentana
	
	@; desplazamiento de fila actual en ventana
	mov r4, #PCOLS
	mla r7, r1, r4, r0		@; r7 = filaAct * PCOLS + despl. ventana
	
	@; sumamos despl. filaAct en ventana a la dirección del mapa bg2A
	ldr r3, =bg2Amap
	ldr r3, [r3]			@; cargamos la dirección del mapa de bg2A
	mov r7, r7, lsl #1		@; adaptación nº baldosas a bytes (1 baldosa --> 2 bytes)
	add r3, r7				@; r3 = dirección del mapa + despl. total
	
	ldr  r4, =_gd_wbfs		@; dirección del vector de WBFS
	mov r5, #WBUFS_LEN
	mul r6, r5, r8			@; nos situamos en la posición del vector
							@; correspondiente a nuestra ventana
	add r4, r6				
	add r4, #4 				@; r4 = posicion inicial pChars (16 bits bajos)
	
	mov r7, r2, lsl #1
	@; Guardamos las baldosas en la dirección de mapa indicada
	mov r5, #0				@; indice del bucle (chars añadidos)
.Lescribir:
	ldrh r6, [r4, r5]		@; r6 = _gd_wbfs[v].pChars[i]
	strh r6, [r3]			@; guardamos el índice de baldosa en la dirección calculada del mapa
	add r5, #2				@; incrementamos contador
	add r3, #2				@; avanzamos posición en el mapa (al ser halfword sumamos 2)
	cmp r5, r7				@; comprobamos carácteres a escribir
	blo .Lescribir			@; en caso de queden carácteres por escribir se efectuará otra iteración
	
	pop {r3-r8, pc}


	.global _gg_desplazar
	@; Rutina para desplazar una posición hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la última fila
	@;Parámetros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r1-r7, lr}
	
	bl _gg_calcularDesplVentana
	
	@; sumamos desplazamiento a la dirección del mapa bg2A
	ldr r1, =bg2Amap
	ldr r1, [r1]			@; cargamos la dirección del mapa de bg2A
	mov r4, r0, lsl #1		@; adaptación nº baldosas a bytes (1 baldosa --> 2 bytes)
	add r1, r4				@; r1 = dirección del mapa + despl. total
	mov r2, r1
	mov r5, #PCOLS
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
	
	
	.global _gg_escribirLineaTabla
	@; escribe los campos básicos de una linea de la tabla correspondiente al
	@; zócalo indicado por parámetro con el color especificado; los campos
	@; son: número de zócalo, PID, keyName y dirección inicial
	@;Parámetros:
	@;	R0 (z)		->	número de zócalo
	@;	R1 (color)	->	número de color (de 0 a 3)
_gg_escribirLineaTabla:
	push {r0-r6, lr}

	mov r6, r0					@; r6 = nº zócalo
	mov r3, r1					@; r3 = color
	
	ldr r0, =_gd_pcbs			@; cargamos vector de PCBs
	mov r1, #24					@; tamaño de un PCB = 4B * 6 atributos
	
	@; desplazamiento de pcbs correspondiente al zócalo actual
	mul r4, r1, r6				
	add r5, r0, r4
	
	@; ESCRIBIMOS NÚMERO DE ZÓCALO
	sub sp, #4					@; creamos espacio en la pila
	mov r0, sp
	mov r1, #3					@; tamaño máx. núm. --> 16 (2 dígitos + centinela)
	mov r2, r6					@; r2 = num zócalo
	bl _gs_num2str_dec			@; (r0 = numstr zócalo, r1 = length, r2 = num zócalo)
	mov r0, sp
	add r1, r6, #4				@; nos situamos en la fila correspondiente
	mov r2, #1
	bl _gs_escribirStringSub	@; (r0 = *str zocalo, r1 = fila inicial, r2 = col inicial, r3 = color)
	add sp, #4
	
	@; comprobamos si hay que escribir más datos
	ldr r1, [r5, #0]			@; cargamos PID del proceso
	cmp r1, #0
	bne .LescribirDatos			@; si es diferente de 0 escribimos el PID en el espacio del zócalo
	
	cmp r6, #0					@; vemos si se trata del zócalo del SO
	beq .LescribirDatos			@; si es el caso, escribiremos su PID (0) y su keyname (GARL)
	
	@; borramos campos
	ldr r0, =espaisblanc		@; cargamos espacios en blanco
	add r1, r6, #4				@; nos situamos en la fila correspondiente
	
	mov r2, #4					@; PID
	bl _gs_escribirStringSub	@; (r0 = espacios en blanco, r1 = fil, r2 = col, r3 = color)
	
	mov r2, #9					@; keyname
	bl _gs_escribirStringSub	@; (r0 = espacios en blanco, r1 = fila, r2 = col, r3 = color)
	
	b .Lfin
	
.LescribirDatos:
	@; ESCRIBIMOS EL PID
	sub sp, #4					@; creamos espacio en la pila
	mov r0, sp
	mov r2, r1
	mov r1, #4					@; tamaño máx. núm. --> 999 (3 dígitos + centinela)
	bl _gs_num2str_dec			@; (r0 = numstr PID, r1 = length, r2 = num PDI)
	mov r0, sp
	add r1, r6, #4				@; nos situamos en la fila correspondiente
	mov r2, #5
	bl _gs_escribirStringSub	@; (r0 = *str, r1 = fila, r2 = columna PID, r3 = color)
	add sp, #4
	
	@; ESCRIBIMOS EL KEYNAME
	sub sp, #4					@; creamos espacio en la pila
	mov r0, sp
	ldr r1, [r5, #16]			@; cargamos el keyname
	str r1, [r0]				@; lo guardamos en r0
	add r1, r6, #4				@; nos situamos en la fila correspondiente
	mov r2, #9
	bl _gs_escribirStringSub	@; (r0 = *str, r1 = fila, r2 = col keyname, r3 = color)
	add sp, #4
	
.Lfin:

	pop {r0-r6, pc}
	
	
	.global _gg_escribirCar
	@; escribe un carácter (baldosa) en la posición de la ventana indicada,
	@; con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x de ventana (0..31)
	@;	R1 (vy)		->	coordenada y de ventana (0..23)
	@;	R2 (car)	->	código del caràcter, como número de baldosa (0..127)
	@;	R3 (color)	->	número de color del texto (de 0 a 3)
	@; pila (vent)	->	número de ventana (de 0 a 15)
_gg_escribirCar:
	push {r4-r7, lr}
	
	mov r7, r0
	
	ldr r4, [sp, #20]	@; obtenemos nº de ventana de la pila (sp + offset)
						@; 4 * (4 registros apilados + lr)
	mov r0, r4
	bl _gg_calcularDesplVentana
	
	@; calculamos la posicion de la coordenada
	mov r5, #PCOLS
	mla r6, r1, r5, r0			@; r6 = vy * PCOLS + despl. ventana (situamos en fila)		
	add r4, r6, r7				@; r4 = despl. fila + vx (situamos en columna)

	@; sumamos desplazamiento a la dirección del mapa bg2A
	ldr r5, =bg2Amap
	ldr r5, [r5]				@; cargamos la dirección del mapa de bg2A
	mov r4, r4, lsl #1			@; adaptación nº baldosas a bytes (1 ind. baldosa --> 2B)
	add r4, r5					@; r4 = despl. total + dirección mapa
	
	@; guardamos la baldosa en la posición del mapa calculada
	mov r6, r3, lsl #7			@; desplazamiento color --> color * 128
	add r6, r2					@; baldosa a escribir --> nº baldosa + despl. color
	strh r6, [r4]				@; baldosa guardada en posición
	
	pop {r4-r7, pc}
	
	
	.global _gg_escribirMat
	@; escribe una matriz de 8x8 carácteres a partir de una posición de la
	@; ventana indicada, con un color concreto;
	@;Parámetros:
	@;	R0 (vx)		->	coordenada x inicial de ventana (0..31)
	@;	R1 (vy)		->	coordenada y inicial de ventana (0..23)
	@;	R2 (m)		->	puntero a matriz 8x8 de códigos ASCII (dirección)
	@;	R3 (color)	->	número de color del texto (de 0 a 3)
	@; pila	(vent)	->	número de ventana (de 0 a 15)
_gg_escribirMat:
	push {r4-r8, lr}

	mov r8, r0
	
	ldr r4, [sp, #24]	@; obtenemos nº de ventana de la pila (sp + offset)
						@; 4 * (5 registros apilados + lr)
	mov r0, r4
	bl _gg_calcularDesplVentana
	
	@; calculamos la posicion de la coordenada
	mov r5, #PCOLS
	mla r6, r1, r5, r0			@; r6 = vy * PCOLS + despl. ventana (situamos en fila)		
	add r4, r6, r8				@; r4 = despl. fila + vx (situamos en columna)

	@; sumamos desplazamiento a la dirección del mapa bg2A
	ldr r5, =bg2Amap
	ldr r5, [r5]				@; cargamos la dirección del mapa de bg2A
	mov r4, r4, lsl #1			@; adaptación nº baldosas a bytes (1 ind. baldosa --> 2B)
	add r4, r5					@; r4 = despl. total + dirección mapa
	
	@; desplazamiento por color (color * 128)
	mov r6, r3, lsl #7
	
	@; ESCRIBIMOS LA MATRIZ
	mov r7, #0					@; elementos de una fila
	mov r8, #0					@; elementos totales
	b .LimprimirCar
	
.LnuevaFila:
	@; actualizamos posición del mapa e inicializamos índice de fila
	add r4, #240				@; pos siguiente mapa --> pos actual + (PCOLS - baldosas) * 2B/baldosa
	mov r7, #0					@; primer elemento de la fila
	
.LimprimirCar:
	ldrb r5, [r2, r8]			@; cargamos el carácter
	cmp r5, #0					@; comparamos con el valor centinela
	beq .LnextChar				@; si lo es, pasamos al siguiente carácter
	
	sub r5, #32					@; pasamos código ASCII  a código de baldosa
	add r5, r6					@; sumamos el índice del color
	strh r5, [r4]				@; guardamos ind. baldosa en pos. mapa correspondiente
	
.LnextChar:
	add r7, #1					@; aumentamos índice de elementos de la fila
	add r8, #1					@; aumentamos elementos totales
	add r4, #2					@; siguiente posición del mapa
	cmp r7, #8					@; comprobamos si hemos llegado al final de la fila
	blo .LimprimirCar			@; en caso negativo, seguimos escribiendo
	
	cmp r8, #64					@; comprobamos si hemos llegado al final de la matriz
	blo .LnuevaFila				@; en caso negativo, pasamos a la siguiente fila

	pop {r4-r8, pc}
	
	
	.global _gg_rsiTIMER2
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la 
	@; representación del PC actual.
_gg_rsiTIMER2:
	push {r0-r5, lr}

	ldr r5, =_gd_pcbs			@; cargamos vector de PCBs
	mov r4, #0					
	
.LcomprobarZocalo:
	ldr r2, [r5, #0]			@; cargamos PID del proceso
	cmp r2, #0					@; comprobamos si vale 0
	bne .LactualizarPC			@; en caso contrario, escribiremos el PC en el espacio del zócalo

	cmp r4, #0					@; comparamos nº zocalo con el del SO
	beq .LactualizarPC
	
	@; borramos campos
	ldr r0, =blancosPC
	add r1, r4, #4				@; nos colocamos en la fila correspondiente
	mov r2, #14					@; columna del PC
	mov r3, #0					@; color
	bl _gs_escribirStringSub	@; (r0 = espacios en blanco, r1 = fila, r2 = columna PC, r3 = color)
	b .LnextZocalo
	
.LactualizarPC:
	sub sp, #4					@; creamos espacio en la pila
	mov r0, sp					@; 
	mov r1, #9					@; longitud del número hexadecimal deseado
	ldr r2, [r5, #4]			@; PC num
	bl _gs_num2str_hex			@; (r0 = numstr PC, r1 = length, r2 = num PC)
	
	mov r0, sp
	add r1, r4, #4				@; nos colocamos en la fila correspondiente
	mov r2, #14					@; columna del PC
	mov r3, #0					@; color
	bl _gs_escribirStringSub	@; (r0 = *str pc, r1 = fila, r2 = columna PC, r3 = color)
	add sp, #4
	
.LnextZocalo:
	@; pasamos al siguiente zocalo
	add r5, #24					@; PCB del siguiente zócalo (6 atributos * 4B)
	add r4, #1					@; siguiente zócalo
	cmp r4, #16					@; comprobamos si hemos actualizado el PC de todos los zócalos
	blo .LcomprobarZocalo		@; en caso negativo, pasamos al siguiente
	
	pop {r0-r5, pc}
	
	
	
	
	@; _gg_calcularDesplVentana: RUTINA AUXILIAR
	@; calcula el desplazamiento correspondiente en la ventana objetivo
	@;
	@;Parámetros
	@; R0: ventana
	@;Resultado
	@; R0: desplazamiento de ventana
_gg_calcularDesplVentana:
	push {r1-r4, lr}

	@; desplazamiento columnas
	mov r1, #PPART
	sub r1, r1, #1
	and r2, r0, r1		   		@; r2 = v % PPART
	mov r1, #VCOLS
	mul r3, r1, r2				@; r3 = VCOLS * (v % PPART)
	
	@; desplazamiento filas
	mov r1, #VFILS
	mov r4, r0, lsr #L2_PPART	@; r4 = v / PPART
	mul r2, r4, r1				@; r2 = (v / PPART) * VFILS
	mov r1, #PCOLS
	mul r4, r2, r1				@; r4 = (v / PPART) * VFILS * PCOLS
	
	@; desplazamiento de ventana
	add r0, r4, r3				@; despl. filas + despl. columnas
	
	pop {r1-r4, pc}
	

.end
