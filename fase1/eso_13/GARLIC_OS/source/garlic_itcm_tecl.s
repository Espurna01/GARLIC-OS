@;==============================================================================
@;
@;	"garlic_itcm_tecl.s":	c�digo de las rutinas relativas a la gesti�n
@;							del teclado
@;
@;==============================================================================

CURSOR = 13				@; Codigo baldosa cursor

.section .dtcm,"wa",%progbits
	
	interrupcions: .byte 0	@; 
	pidstr: .space 6		@; string pid (5 caracteres + centinela)

.section .itcm,"ax",%progbits	

	.arm
	.align 2
	
@; Activa el bit de display del teclat
_gt_showKB:
	push {r0, r1, lr}
	ldr r0, =0x04001000		@; B DISPCNT 0x04001000
	ldr r1, [r0]
	orr r1, #512			@;Bit 8: Display BG1
	str r1, [r0]
	pop {r0, r1, pc}
	
@; Desactiva el bit de display del teclat
_gt_hideKB:
	push {r0, r1, lr}
	ldr r0, =0x04001000		@; B DISPCNT 0x04001000
	ldr r1, [r0]
	bic r1, #512			@;Bit 8: Display BG1
	str r1, [r0]
	pop {r0, r1, pc}

@; Canvia el n�mero de zocalo y el PID de la interfice del teclado
_gt_zocPid:
	push {r0-r5, lr}
	ldr r0, =_gd_zocIAddr
	ldr r5, [r0]
	mov r3, #0						@; Valores iniciales del zocalo	
	cmp r2, #10
	bhs .Lzoc2digits
	b .Lzoc1digit
.Lzoc2digits:
	sub r3, r2, #10					@; r3 = r2 - 10
	mov r4, #17						@; Zocalo = [0, 15]
	add r3, #16						@; Ajustar codigo baldosa
	b .Lcanviar_zoc
.Lzoc1digit:
	mov r3, r2
	mov r4, #16						@; Codi baldosa '0'
	add r3, #16
.Lcanviar_zoc:
	@;mov r4, r4, lsl #16				@; Ajustar para word
	@;orr r3, r4						@; Indicebaldosa('0') = 16 
	strh r4, [r5]
	strh r3, [r5, #2]				
	
	mov r3, r2						@; R3: num zocalo
	
	ldr r4, =_gd_pcbs			
	mov r5, #24
	mul r3, r5, r3
	ldr r0, =pidstr					@; R0: str
	mov r1, #6						@; R1: length str
	ldr r2, [r4, r3]				@; R2: _gd_stacks[z].pid
	
	bl _gs_num2str_dec
	
	cmp r0, #0
	bne .Lzocpiderr

	ldr r0, =_gd_zocIAddr
	ldr r5, [r0]
	mov r1, #24
	ldr r2, =pidstr
	mov r3, #4
	ldrb r4, [r2, r3]				@; ascii str
.Lpid:
	sub r4, #32						@; r4 - ascii('0') + baldosa('0')
	strh r4, [r5, r1]
	sub r1, #2
	sub r3, #1
	ldrb r4, [r2, r3]
	cmp r4, #' '
	beq .Lsortirpid
	cmp r3, #0
	bge .Lpid

.Lzocpiderr:
.Lsortirpid:	
	pop {r0-r5, pc}

	.global _gt_getstring
@; Rutina que copia la string entrada por el teclado a la string del
@; proceso que la ha pedido. Devuelve el n�mero de caracteres leido 
@; Parametros:
@; R0: string -> direcci�n base del vector de caracteres (bytes)
@; R1: max_char -> n�mero m�ximo de caracteres del vector
@; R2: zocalo -> n�mero de z�calo del proceso invocador
_gt_getstring:
	push {r1-r10, lr}
	ldr r3, =0x04001000				@; DISP CNT SUB 0x04001000
	ldr r4, [r3]
	tst r4, #512
	bne .LKBOn 						@; bit a 0
	
	bl _gt_showKB
	ldr r3, =0x04000132			@; IRQ_KEYS
	ldrh r4, [r3]	
	mov r5, #0x4000		
	orr r4, r5					@; activar bit14 i START
	strh r4, [r3]				@; activar interrupcions de teclat
	
	bl _gt_zocPid				@; Canviar zocalo i PID
	
	push {r0-r1}				@; Salvo arguments
	mov r0, #3					@; TIMER3
	mov r1, #1					@; activar
	bl _gt_switchTimerX			@; parpadeig
	pop {r0-r1}					@; recupero arguments

.LKBOn:
	ldr r3, =_gd_kbwait				@; R3: direccion cola
	ldr r5, =_gd_nkbwait			
	ldrb r4, [r5]					@; R4: numero de elementos en la cola
	strb r2, [r3, r4]				@; guardar zocalo actual
	
	ldr r9, =_gd_maxIndex			@; R9: indices max de la cola
	sub r8, r1, #1					@; Guardar el indice max correspondiente
	strb r8, [r9, r4]				@; del proceso
	
	add r4, #1
	strb r4, [r5]					@; Actualizar nkbwait
	
	ldr r7, =_gd_kbsignal		@; Variable se�al que comprova si l'usuari ha acabat
	mov r8, #1
	mov r8, r8, lsl r2				@; Mascara del bit n
	
.Lwait:
	bl _gp_WaitForVBlank
	ldrh r6, [r7]
	tst r6, r8
	beq .Lwait 					@; (S� se puede interrumpir !!!)
	
	bic r6, r8
	strh r6, [r7]
	
	ldr r2, =_gd_string			@; R2: direccion string 
	ldr r7, =_gd_strIAddr		@; R7: direccion string INTERFICIE
	ldr r8, =_gd_index			@; r8: posicion cursor
	
	mov r10, #0					@; R10: 0
	ldrb r4, [r8]				@; R4: cursor del teclado
	mov r3, #0					@; Index string
	@;add r1, #1					@; r1: maxchar + centinela
	
.LcopiarStr:
	ldrb r6, [r2, r3]			@; Leer codigo baldosa string
	add r6, #32					@; Transformar baldosa -> ASCII
	strb r6, [r0, r3]			@; Guardar caracter en string de entrada
	strb r10, [r2, r3]			@; Restaurar codigo baldosa string
	add r3, #1					@; Incrementar indice
	cmp r3, r4					@; Comparo con el indice con el cursor
	bls .LcopiarStr				@; Si salto aqui faltan posiciones para copiar
	
	cmp r3, r1					@; Comparo con el maxchar
	beq .LfiCopiar				@; Salida si cursor == maxchar 
								@; Se han copiado y borrado maxchar caracteres	

	mov r4, r3					@; R4: indice actual
.Lborrar:	
	strb r10, [r2, r4]			@; Restaurar codigo baldosa string
	add r4, #1					@; Incrementar indice
	cmp r4, r1					@; Comparar con maxchar
	blo .Lborrar				@; Saltar si no se ha llegado a maxchar - 1
	
.LfiCopiar:
	mov r4, #0
	strb r4, [r0, r3]			@; A�adir el \0 al final del str
	
	mov r0, r3					@; R3: Caracteres copiados
	
	ldr r4, =_gd_kbwait			@; R4: direccion cola
	ldrb r1, [r5]				@; R1: Numero procesos en la cola
	
	cmp r1, #0					
	beq .Lend_gt_getstring		@; Si no hay procesos en la cola no hace falta
								@; desplazarlos
	
	mov r2, #1					@; Counter 
	mov r3, #0					@; Counter - 1

.LdesplazarKBwait:				@; Bucle que desplaza todos los elementos
	ldrb r5, [r4, r2]			@; Leer numero de zocalo de proceso
	strb r5, [r4, r3]			@; Guardar numero de zocalo de proceso
	ldrb r5, [r9, r2]			@; Leer numero de maxIndex de proceso
	strb r5, [r9, r3]			@; Leer numero de maxIndex de proceso
	add r2, #1
	add r3, #1
	cmp r2, r1					@; R1: numero de procesos en la cola
	bls .LdesplazarKBwait
	
.Lend_gt_getstring:
	mov r3, #0
	strb r3, [r8]				@; R8: direccion de _gt_index
	
	pop {r1-r10, pc}	
	
	
@; Rutina que gestiona los inputs del teclado, la frequencia de lectura
@; viene determinada por el timer activo actual (0.5hz/2hz)
_gt_processInput:
	push {r1-r2, r6-r7, lr}
	
	mov r6, #0
	ldr r7, =0x04000130				@; REG_KEYINPUT
	ldrh r7, [r7]
	mvn r7, r7						@; Bits a 1 teclas pulsadas
	
	tst r7, #0x0007					@; Mascara para inc, dec y borrar
	beq .Lnotecla
	
	ldr r0, =_gd_strIAddr
	ldr r0, [r0]				@; R2: Posicio incial del caracter del cursor
	ldr r1, =_gd_index
	ldrb r1, [r1]				@; R1: Index de la cadena de caracters 
	
	mov r1, r1, lsl #1			@; son hwords el indice tiene que saltar de 2 en 2
								@; R0: DIRECCION _gd_index
	ldrh r2, [r0, r1]			@; caracter en esa posicion
	
	tst r7, #0x0001
	beq .LtestB
	
	add r2, #1				@; Tecla A pulsada inc valor baldosa
	cmp r2, #94				@; Desfase de valor
	movhi r2, #0			

.LtestB:
	tst r7, #0x0002
	beq .LtestSELECT
	
	sub r2, #1				@; Tecla B pulsada dec valor baldosa	
	cmp r2, #0				@; Desfase de valor
	movlt r2, #94			

.LtestSELECT:
	tst r7, #0x0004
	beq .LnoSELECT	

	mov r2, #0				@; Baldosa transparente
	bl _gt_moveL			@; Mover cursor a la izq

	.LnoSELECT:
	strh r2, [r0, r1]			@; R2: caracter modificado
	ldr r0, =_gd_string
	mov r1, r1, lsr #1			@; index tiene que saltar de 1 en 1 son bytes
	strb r2, [r0, r1]			@; Actualizar string

	add r6, #1					@; Input relevante para autorepeat
.Lnotecla:
	tst r7, #0x0030			@; Mascara teclas
	beq .Lnopad
	
	tst r7, #0x0010			@; Mascara Right
	blne _gt_moveR
	
	tst r7, #0x0020			@; Mascara Left
	blne _gt_moveL	
	
	add r6, #1				@; Input relevante si es 2 el input es de distinto
.Lnopad:	
	tst r7, #0x0008
	blne _gt_endstrSTART
	
.Lfi:
	mov r0, r6
	pop {r1-r2, r6-r7, pc}

	
@;Rutina que mueve el cursor del teclado hacia la derecha
_gt_moveR:
	push {r0-r5, lr}

	ldr r0, =_gd_index
	ldrb r1, [r0]			@; r1 = index 
	mov r1, r1, lsl #1		@; halfwords
	
	ldr r5, =_gd_maxIndex	@; max index
	ldrb r5, [r5]
	mov r5, r5, lsl #1
	
	ldr r2, =_gd_curIAddr	@; Pos inicial
	ldr r2, [r2]
	ldrh r3, [r2, r1]		@; R3 = cargar baldosa cursor '-'
	mov r4, #0				@; baldosa transparent
	strh r4, [r2, r1]		@; guardar index actual a transparent
	add r1, #2				@; incrementar index 
	cmp r1, r5				@; controlar max 
	movhi r1, #0
	strh r3, [r2, r1]		@; moure index
	mov r1, r1, lsr #1
	strb r1, [r0]			@; actualitzar index

	pop {r0-r5, pc}
	
@;Rutina que mueve el cursor del teclado hacia la izquierda
_gt_moveL:
	push {r0-r5, lr}
	
	ldr r0, =_gd_index
	ldrb r1, [r0]			@; r1 = index 
	mov r1, r1, lsl #1		@; halfwords
	
	ldr r5, =_gd_maxIndex	@; max index
	ldrb r5, [r5]
	mov r5, r5, lsl #1
	
	ldr r2, =_gd_curIAddr	@; BG3
	ldr r2, [r2]
	ldrh r3, [r2, r1]		@; R3 = cargar baldosa cursor '|'
	mov r4, #0				@; baldosa transparent
	strh r4, [r2, r1]		@; guardar index actual a transparent
	sub r1, #2				@; decrementar index 
	cmp r1, #0				@; controlar min
	movlt r1, r5
	strh r3, [r2, r1]		@; moure index
	mov r1, r1, lsr #1
	strb r1, [r0]			@; actualitzar index

	pop {r0-r5, pc}

	
@;Rutina que cambia el bit de _gd_kbsignal i reinicia la interfaz o la oculta
_gt_endstrSTART:
	push {r0-r5, lr}
	
	ldr r0, =_gd_kbwait
	ldrb r1, [r0]				@; carregar n�m. s�cul del primer proc�s de la cua teclat
	
	ldr r2, =_gd_kbsignal
	ldrh r3, [r2]				@; R3: kbsignal
	mov r4, #1					
	mov r4, r4, lsl r1			@; Bit 1 en la posicion r1
	orr r3, r4	
	strh r3, [r2]				@; Activar bit
	
	ldr r2, =_gd_strIAddr		
	ldr r1, [r2]				@; R1: Direccio de la string de la VRAM 
	ldr r5, =_gd_maxIndex
	ldrb r4, [r5]				@; R5: direccion memoria max index
	mov r4, r4, lsl #1			@; R4: maxIndex del cursor * 2
	mov r2, #0					@; R2: Index de la taula
	mov r3, #0					@; R3: Valor baldosa
	
.LreiniciarInterficie:
	strh r3, [r1, r2]
	add r2, #2
	cmp r2, r4
	ble .LreiniciarInterficie
	
	ldr r2, =_gd_curIAddr		
	ldr r1, [r2]				@; R1: direccion del cursor VRAM
	ldr r2, =_gd_index
	ldrb r5, [r2]				@; R5: index
	mov r5, r5, lsl #1
	strh r3, [r1, r5]			@; Reiniciar cursor
	
	mov r2, #CURSOR				@; Baldosa('-') = 13
	strh r2, [r1]				
	
	ldr r2, =_gd_nkbwait	
	ldrb r3, [r2]				@; R3: Numero de procesos esperant al teclat
	sub r3, #1					@; Pitjar START = Process acabat
	strb r3, [r2]				@; Actualizar num de procesos
	
	cmp r3, #0
	bne .LreiniciarZocPID
	
	bl _gt_hideKB				@; Si es 0 ocultar teclado
	
	ldr r0, =0x04000132			@; IRQ_KEYS
	ldrh r1, [r0]			
	bic r1, #0x4000				@; desactivar bit14
	strh r1, [r0]				@; desactivar interrupcions de teclat

	mov r0, #3					@; TIMER3
	mov r1, #0					@; desactivar
	bl _gt_switchTimerX

	b .Lendendstr				@; Saltar reinicio de zocalo
	
.LreiniciarZocPID:	
	ldrb r2, [r0, #1]			@; Carregar el n�m. s�cul seg�ent
	bl _gt_zocPid
	
.Lendendstr:
	
	pop {r0-r5, pc}

	
	.global _gt_rsiTimer3
	@; Parpadea el cursor cambiando el valor de la baldosa en la posicion del cursor
	@; cada 2hz (0.5s) i, solo permite al usuario presionar START cada 2hz
_gt_rsiTimer3:
	push {r0-r2, lr}

	ldr r0, =_gd_strIAddr
	ldr r0, [r0]				@; Posicion de la primera baldosa de texto
	add r0, #0x40				@; Desplazado 32 baldosas (1 fila)
	ldr r2, =_gd_index
	ldrb r2, [r2]				@; Posiciond del cursor actualmente
	mov r2, r2, lsl #1			@; Halfwords
	ldrh r1, [r0, r2]				@; Baldosa del cursor visible
	cmp r1, #0
	movne r1, #0				@; Baldosa transparente
	moveq r1, #CURSOR 			@; Baldosa cursor
	strh r1, [r0, r2]

	mov r1, #0x8				@; Tecla start
	ldr r0, =0x4000132			@; IRQ_KEYS
	ldrh r2, [r0]
	orr r2, r1					@; Permetre a start causar una interrupcio cada 0.5 seg
	strh r2, [r0]	

	pop {r0-r2, pc}

	.global _gt_rsiTimer1
	@; Auto repeat lento, lee pulsaciones cada 2 hz si lee 3 pulsaciones seguidas
	@; se desactiva y activa el timer 2
_gt_rsiTimer1:
	push {r0-r2, lr}

	ldr r0, =0x04000130			@; KEY_INPUT
	ldrh r0, [r0]
	tst r0, #0x8				@; Start
	beq .Lend_gt_timer1			@; Start solo la procesa rsiKEYS, para evitar enviar sinquerer
	bl _gt_processInput

	cmp r0, #1					@; Si retorna 1 i ha hagut pulsacio relevant d'1 tipus (A/B || </>)
	beq .LactualitzarInterTimer1

	ldr r1, =interrupcions		@; Si no l'usuari ha canviat d'accio
	strb r0, [r1]				@; Resetejo contador de interrupcions

	mov r0, #1					@; TIMER 1
	mov r1, #0					@; Desactivar
	bl _gt_switchTimerX			@; Desactivo el timer1

	ldr r0, =0x04000132			@; IRQ_KEYS
	ldrh r1, [r0]			
	orr r1, #0x4000				@; activar bit14
	strh r1, [r0]				@; Activo interrupcions de teclat

	b .Lend_gt_timer1			@; No incremento les pulsacions (START)

.LactualitzarInterTimer1:
	ldr r1, =interrupcions		@; Si no l'usuari ha canviat d'accio
	ldrb r2, [r1]
	cmp r2, #3					@; Comprobar si han saltado 3 interrupciones seguidas
	addne r2, #1
	moveq r2, #0
	strb r2, [r1]
	beq .LcambiarATimer2
	b .Lend_gt_timer1
	
.LcambiarATimer2:
	mov r0, #1					@; TIMER 1
	mov r1, #0					@; Desactivar
	bl _gt_switchTimerX			@; Desactivo el timer1

	mov r0, #2					@; TIMER 2
	mov r1, #1					@; Activar
	bl _gt_switchTimerX			@; Activar el timer1	

.Lend_gt_timer1:
	pop {r0-r2, pc}


	.global _gt_rsiTimer2
	@; Auto repeat rapido, lee pulsaciones cada 2hz si no lee un input relevante se apaga
	@; i reenciende las interrupciones por teclado
_gt_rsiTimer2:
	push {r0-r1, lr}

	ldr r0, =0x04000130			@; REG_KEYINPUT
	ldrh r0, [r0]
	tst r0, #0x8				@; Start
	beq .Lend_gt_timer2			@; Start solo la procesa rsiKEYS, para evitar enviar sinquerer
	bl _gt_processInput

	cmp r0, #1					@; Si retorna 1 ha hagut pulsacio relevant d'un tipus
	beq .Lend_gt_timer2

	@; Si no ha hagut pulsacio relevant apago timer i activo IRQ_KEYS
	mov r0, #2					@; TIMER 2
	mov r1, #0					@; Desactivar
	bl _gt_switchTimerX			@; Desactivo el timer2			

	ldr r0, =0x04000132			@; IRQ_KEYS
	ldrh r1, [r0]			
	orr r1, #0x4000				@; activar bit14
	strh r1, [r0]				@; Activo interrupcions de teclat

.Lend_gt_timer2:

	pop {r0-r1, pc}

	.global _gt_rsiKEYS
	@; Procesa la primera pulsacio, activa el timer1 y desactiva les interrupcions per teclat
_gt_rsiKEYS:
	push {r0-r2, lr}

	bl _gt_processInput

	mov r0, #1					@; TIMER1
	mov r1, #1					@; Activar
	bl _gt_switchTimerX

	ldr r0, =0x04000132			@; IRQ_KEYS
	ldrh r1, [r0]			
	mov r2, #0x4000
	add r2, #0x8
	bic r1, r2				@; desactivar bit14 i bit del START
	strh r1, [r0]

	pop {r0-r2, pc}

	@; Activa o desactiva un timer en especific
	@; R0: # timer ([0, 3])
	@; R1: 0 desactivar, 1 activar
_gt_switchTimerX:
	push {r0-r3,lr}

	and r0, #3					@; R0: mod 4 (control max)
	and r1, #1					@; R1: mod 2
	mov r0, r0, lsl #2			@; R0: r0 * 4
	mov r3, #0x80				@; 1000_0000
	ldr r2, =0x04000102			@; Timer0_CR
	add r2, r0					@; TIMERX_CR = TIMER0_CR + X * 4
	ldrh r0, [r2]				@; Valor de control actual
	cmp r1, #0					@; Si la mascara es 0
	biceq r0, r3				@; desactivar
	orrne r0, r3				@; sino activar
	strh r0, [r2]  				@; START/STOP

	pop {r0-r3, pc}
.end 