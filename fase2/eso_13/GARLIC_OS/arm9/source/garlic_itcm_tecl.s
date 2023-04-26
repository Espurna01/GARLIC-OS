@;==============================================================================
@;
@;	"garlic_itcm_tecl.s":	c�digo de las rutinas relativas a la gesti�n
@;							del teclado
@;
@;==============================================================================

BALDOSA_AZUL = 0xDF			@; Codigo baldosa azul
BALDOSA_ROSA = 0x15F		@; Codigo baldosa rosa
BALDOSA_BLANCA = 0x5F		@; Codigo baldosa blanca
CURSOR = 0x160				@; '|' cursor en rosa

.section .dtcm,"wa",%progbits

	pidstr: .space 6		@; string pid (5 caracteres + centinela)

.section .itcm,"ax",%progbits	

	.arm
	.align 2
	
	.global _gt_rsiFifoNotEmpty
_gt_rsiFifoNotEmpty:
	push {r0-r5, lr}
	
	mov r2, #0x04100000
	ldr r2, [r2]				@; R0 = word(0x04100000)
	
	ldr r3, =0x06200800			@; Fondo 1 bg
	mov r0, r2, lsr #16			@; R0 = 16 bits altos coordenades
	mov r2, r2, lsl #16			@; filtrar 16 bits bajos
	mov r1, r2, lsr #16			@; R1 = 16 bits bajos
	
	sub r0, #1					@; Ajuste de posicion para baldosa precisa
	sub r1, #1
	
	ldr r2, =_gd_keyboardState
	ldrb r2, [r2]				@; Si el teclat esta a sota li resto a la y
	tst r2, #1					@; bit0: 1 sota, 0 dalt
	beq .LteclatDalt
	cmp r1, #96					@; Si visualment el teclat esta a sota i l'usuari
	subhs r1, #96				@; Pitja a sota ajustar la y.
	blo .Lno_casilla			@; Si pulsa a dalt no ha pitjat el teclat

	.LteclatDalt:

	mov r0, r0, lsr #3			@; x = x / 8 (baldosa x)
	mov r1, r1, lsr #3			@; y = y / 8 (baldosa y)
	
	cmp r1, #4					@; Primera fila de tecles
	blo .Lno_casilla
	cmp r1, #11					@; Ultima fila de tecles
	bhi	.Lno_casilla

	mov r4, r0, lsl #16
	orr r4, r1
	
	ldr r2, =coordenades
	str r4, [r2]
	
	cmp r1, #8					@; CAPS es a la fila 8 (4 si es conten nom�s les tecles)
	bne .Lnormalkey
	cmp r0, #1					@; Es de la baldosaX 1 inclosa
	blo .Lno_casilla
	cmp r0, #4					@; A la 4 inclosa
	bls .LCAPSkeyException
	
	.Lnormalkey:
	mov r2, r1,	lsl #6			 
	add r2, r0, lsl #1			@; R7 = y * 64 + x * 2 = 2*(x + y*32)
	
	ldrh r4, [r3, r2]			@; Condicion general menos para la tecla CAPS
	mov r3, #BALDOSA_AZUL		@; Baldosa azul
	cmp r4, r3
	bne .Lno_casilla
	
.LCAPSkeyException:
	bl _gt_processKey		
	
.Lno_casilla:
	
	pop {r0-r5, pc}

	@; Procesa totes les tecles especials del teclat.
	@; Les del scroll ('/\' || '\/'), DEL, CAPS, INTRO,
	@; SPACE, '<=' i '=>'
	@; R0 = posBaldosaX
	@; R1 = posBaldosaY
_gt_processKey:
	push {lr}
	
	bl _gt_getspecialKey	@; Retorna el codi de tecla
	
	mov r3, r1, lsl #6
	add r3, r0, lsl #1		@; r3 = (y * 32 + x) * 2 = y * 64 + x * 2
							@; R3 = BaldosaOffset
	
	ldr r0, =baldosaOff		@; Guardar offset primera baldosa de la key
	str r3, [r0]			@; #314						
	@;R0:BaldosaX, R1:BaldosaY, R2:SpecialKey, R3:BaldosaOff
	
	mov r0, r3				@; r0: baldosaOff
	mov r1, r2				@; r1: specialKey
	ldr r2, =#BALDOSA_ROSA	@; Baldosa rosa
	cmp r1, #3
	bne .LfiCAPS
.LifCAPS:
	ldr r3, =_gd_keyboardState
	ldrb r4, [r3]
	
	tst r4, #2				@; bit1: 1 = Majus, 0 = minus
	movne r2, #BALDOSA_AZUL	@; Si es majus es pinta de blau
	
	eor r4, #2				@; invertir estat de majus
	strb r4, [r3]
.LfiCAPS:
	
	bl _gt_pintarBaldosa	@; pintar baldosa
	
	cmp r1, #0
	beq .Lpnormal
	
@; flecha					
	cmp r1, #1
	bne .LpDEL
	
	ldr r0, =_gd_keyboardState
	ldrb r1, [r0]			
	and r5, r1, #1			@; R5 = bit0 de keyboardState (0 a dalt, 1 a sota)
	
	mov r4, #0				
	cmp r5, #0							
	moveq r4, #-96			@; r4 despla�ament vertical 96 pixels cap a baix
	eor r1, #1				@; invertir bit
	strb r1, [r0]			@; guardar state
	
	ldr r2, =0x04001016		@; REG_BG1VOFS_SUB
	strh r4, [r2]
	add r2, #4				@; REG_BG1VOFS_SUB + 4 = REG_BG2VOFS_SUB
	strh r4, [r2]
	add r2, #4
	strh r4, [r2]			@; REG_BG2VOFS_SUB + 4 = REG_BG3VOFS_SUB
	
	ldr r2, =0x06201000		@; BG 2
	@; Inverteixo la flecha '\/' -> '/\'
	ldrh r4, [r2, r3]		@; a = baldosa[X]
	add r3, #2
	ldrh r5, [r2, r3]		@; b = baldosa[X + 1]
	strh r4, [r2, r3]		@; balosa[X + 1] = a
	sub r3, #2
	strh r5, [r2, r3]		@; baldosa[x] = b
	
	b .LendprocessKey
.LpDEL:
	cmp r1, #2
	bne .LpCAPS
	
	ldr r0, =_gd_strIAddr
	ldr r0, [r0]			@; Direccio cuadre text
	
	ldr r1, =_gd_index
	ldrb r1, [r1]
	mov r1, r1, lsl #1		@;Index actual
	cmp r1, #0		
	beq .LendprocessKey		@;Index esta al inici no hi ha cap lletra enrere
	
	ldr r4, =_gd_maxIndex
	ldrb r4, [r4]
	mov r4, r4, lsl #1
	
	sub r2, r1, #2			@; R2 = anterior index
	.LmoveStrL:
	ldrh r3, [r0, r1]		@; Seguent baldosa
	cmp r3,	#0x60			@; Baldosa final (marge cuadre text)
	moveq r3, #0	
	strh r3, [r0, r2]
	add r1, #2
	add r2, #2
	cmp r2, r4
	blo .LmoveStrL
	
	bl _gt_moveL
	
	b .LendprocessKey
.LpCAPS:
	cmp r1, #3
	bne .LpINTRO
	@; R4 = keyboardstate,bit:1= 1 -> copiar mapa majuscules, 0-> copiar minus 
	tst r4, #2
	@; R3 = matriu de caracters a copiar
	ldrne r3, =teclatCAPSfg32x7
	ldreq r3, =teclatfg32x7
	@; Cal actualitzar la flecha actual al teclat a copiar
	ldr r0, =0x06201000		@; BG2 
	mov r1, #300
	add r1, #14				@; #314 offset de baldosa flecha
	mov r4, #29
	mov r4, r4, lsl #1		@; offset en el teclat sense la capcalera
	ldrh r2, [r0, r1]
	strh r2, [r3, r4]		@; Actualitzar flecha '\/' o '/\'
	add r1, #2
	add r4, #2
	ldrh r2, [r0, r1]
	strh r2, [r3, r4]
	
	mov r1, r0				@; R1 = direccio desti
	mov r4, #4
	mov r4, r4, lsl #6		@; r4 = 32 * 4 * 2
	add r1, r4				@; afegir offset de la capcalera	
	mov r0, r3				@; R0 = direccio font
	mov r2, #0x1C0			@; R2 = numero de bytes = 32 * 7 * 2 = 448
	bl _gs_copiaMem
	b .LendprocessKey
.LpINTRO:
	cmp r1, #4
	bne .LpSPACE
	@; Quitar el primer zocalo de proceso de la cola de Kbwait
	@; A�adirlo a la cola de qReady
	@; Actualizar nReady y nKbwait
	@; No hace falta inhibir interrupciones al estar en una interrupci�n
	
	ldr r0, =_gd_qKbwait
	ldr r1, =_gd_nKbwait
	ldrb r2, [r1]
	
	sub r2, #1
	strb r2, [r1]	@; restar # procesos en la cua
	ldrb r1, [r0]	@; r1 = primer elemento en la cola de Kbwait
	cmp r2, #0
	beq .LqKbwaitempty
	
	bl _gt_desplKbwait
	
	.LqKbwaitempty:
	ldr r0, =_gd_qReady
	ldr r2, =_gd_nReady
	ldr r3, [r2]	@; Nready
	
	strb r1, [r0, r3]
	add r3, #1
	str r3, [r2]
	
	b .LendprocessKey
.LpSPACE:
	cmp r1, #5
	bne .LpLArrow
	
	ldr r1, =_gd_index
	ldrb r1, [r1]
	
	ldr r2, =_gd_maxIndex
	ldrb r2, [r2]
	cmp r1, r2
	beq .LendprocessKey
	
	bl _gt_moveStrR
	cmp r0, #1
	beq .LendprocessKey
	
	bl _gt_moveR
	
	b .LendprocessKey
.LpLArrow:
	cmp r1, #6
	bne .LpRArrow

	bl _gt_moveL
	
	b .LendprocessKey
.LpRArrow:
	
	bl _gt_moveR
	
	b .LendprocessKey
.Lpnormal:
	
	ldr r4, =0x06201000			@; Direccio del bg2
	ldrh r2, [r4, r0]			@; Baldosa pitjada
	
	ldr r3, =_gd_index
	ldrb r3, [r3]
	ldr r4, =_gd_maxIndex
	ldrb r4, [r4]
	cmp r3, r4					@; cursor al final del cuadre de text (zona blava)
	beq .LendprocessKey
	
	bl _gt_moveStrR				@; Si s'ha pogut desplaçar el caracters 
	cmp r0, #1
	beq .LendprocessKey
	
	ldr r1, =_gd_strIAddr
	ldr r1, [r1]				@; Direccio del cuadre de text
	
	mov r3, r3, lsl #1
	strh r2, [r1, r3]			
	
	bl _gt_moveR
.LendprocessKey:
	
	pop {pc}

	.global _gt_rsiIPCSync
_gt_rsiIPCSync:
	push {r0-r4, lr}
	
	ldr r0, =baldosaOff
	ldr r3, [r0]
	
	cmp r3, #-1		 			@; baldosaOff sera != -1 si s'ha pitjat una
	beq .Lpressed				@; tecla correctament abans de soltar
	
	ldr r0, =coordenades
	ldr r2, [r0]
	
	mov r0, r2, lsr #16			@; 16 bits altos baldosaX
	mov r2, r2, lsl #16			@; 16 bits altos eliminados
	mov r1, r2, lsr #16			@; 16 bits bajos baldosaY
	
	bl _gt_getspecialKey
	
	cmp r2, #3					@; CAPS no es torna blava quan es solta
	beq .LCAPSexception
	
	mov r0, r3					@; R0 = baldosaOff
	mov r1, r2					@; R1 = specialKey
	mov r2, #BALDOSA_AZUL		@; R2 = baldosa blava

	bl _gt_pintarBaldosa
.LCAPSexception:	
	ldr r0, =baldosaOff			@; No queda cap tecla per pintar de blau
	mov r3, #-1
	str r3, [r0]				@; Reset baldosaOff
	
.Lpressed:

	pop {r0-r4, pc}
	
	
	@; Pintar les baldoses necesaries del bg1
	@; r0: baldosaOffset
	@; r1: specialKey
	@; r2: color a pintar
_gt_pintarBaldosa:
	push {r0-r4, lr}
	
	cmp r1, #5
	movhi r1, #2				@; Numero de tecles a repintar de blau
	addls r1, #1				@; Si es 0 es normal, 1 tecla per pintar
	cmp r1, #6					@; El codi 6 es SPACE que te 5 baldosas
	subeq r1, #1				@; Ajustar aquesta
	
	ldr r4, =0x06200800			@; BG colors teclat
	mov r3, #0					@; Index per al bucle
	.LseguirPintant:
	strh r2, [r4, r0]			@; Pintar baldosa
	add r0, #2					@; Seguent baldosa	
	add r3, #1					@; Increment index
	cmp r3, r1
	blo .LseguirPintant
	
	pop {r0-r4, pc}


	@; Retorna un numero segons quina tecla s'ha pitjat
	@; R0: baldosaX
	@; R1: baldosaY
	@; retorna per r2: 1->flecha, 2->DEL, 3->CAPS, 4->INTRO, 5->SPACE
	@; 6-><=, 7->=>, 0->tecla general
_gt_getspecialKey:
	push {r1, lr}
	cmp r1, #4
	bne .Lrow2
	cmp r0, #29
	blo .Lendnormal
	mov r0, #29			@; assigno baldosaX a la baldosa inicial de la tecla especial
	mov r2, #1			@; flecha
	b .LendspecialKey
.Lrow2:
	cmp r1, #6
	bne .Lrow3
	cmp r0, #28
	blo .Lendnormal
	mov r0, #28
	mov r2, #2			@; DEL
	b .LendspecialKey
.Lrow3:
	cmp r1, #8
	bne .Lrow4
	cmp r0, #4			@; Al estar CAPS al inici nomes cal comprovar si es pasa
	bhi .LtryIntro
	mov r0, #1			@; Asigno baldosaX al inici de la tecla especial		
	mov r2, #3			@; CAPS
	b .LendspecialKey
	.LtryIntro:			@; A la fila 2 n'hi han 2 tecles especials
	cmp r0, #26
	blo .Lendnormal
	mov r0, #26			@; Baldosa inicial tecla INTRO
	mov r2, #4			@; INTRO
	b .LendspecialKey
.Lrow4:
	cmp r1, #10
	bne .Lendnormal
	cmp r0, #5
	bhi .LtryLarrow
	mov r0, #1
	mov r2, #5			@; SPACE
	b .LendspecialKey
	.LtryLarrow:
	cmp r0, #26
	blo .Lendnormal
	cmp r0, #27
	bhi .LtryRarrow
	mov r0, #26			@; Baldosa inicial <=
	mov r2, #6			@; <=
	b .LendspecialKey
	.LtryRarrow:
	@; No hi ha cap m�s tecla a la dreta de Larrow per tant ha pitjat Rarrow
	mov r0, #29
	mov r2, #7			@; =>
	b .LendspecialKey
.Lendnormal:
	mov r2, #0
.LendspecialKey:
	pop {r1, pc}
	
	
	@; Desplaza el cursor a la derecha
_gt_moveR:
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
	add r1, #2				@; incrementar index 
	cmp r1, r5				@; controlar max 
	movhi r1, #0
	strh r3, [r2, r1]		@; moure index
	mov r1, r1, lsr #1
	strb r1, [r0]			@; actualitzar index

	pop {r0-r5, pc}
	
	@; Desplaza el cursor a la izquierda
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
	
	
	@; Desplaza toda la string 1 caracter hacia la derecha,
	@; con el fin de poder a�adir caracteres en medio de caracteres ya escritos
	@; Retorna per r0: 0 si s'ha pogut 1 si no.
_gt_moveStrR:
	push {r1-r6, lr}
	
	ldr r0, =_gd_strIAddr
	ldr r0, [r0]
	
	ldr r1, =_gd_maxIndex 
	ldrb r1, [r1]
	sub r1, #1			@; Caracteres van del 0, index - 1
	mov r1, r1, lsl #1
	sub r2, r1, #2		@; index final - 1
	ldr r3, =_gd_index
	ldrb r3, [r3]
	mov r3, r3, lsl #1	@; r3 max
	mov r6, #1			@; Codi error
	
	.LmoveStrR:
	ldrh r4, [r0, r1]
	cmp r4, #0			@; ultim caracter buit es pot moure
	bne .LendmoveStrR
	mov r6, #0
	cmp r3, r1			@; indexfinal == index
	beq .LendmoveStrR
	ldrh r5, [r0, r2]
	strh r6, [r0, r2]
	strh r5, [r0, r1]
	sub r1, #2 
	sub r2, #2
	b .LmoveStrR

.LendmoveStrR:
	mov r0, r6
	pop {r1-r6, pc}
	

	.global _gt_showKB
@; Activa el bit de display del teclat
_gt_showKB:
	push {r0-r2, lr}
	ldr r0, =0x04001000		@; B DISPCNT 0x04001000
	ldr r1, [r0]
	mov r2, #7				@; 0b111
	mov r2, r2, lsl #9		@; 0b1110 0000 0000
	orr r1, r2
	str r1, [r0]
	pop {r0-r2, pc}
	
	.global _gt_hideKB
@; Desactiva el bit de display del teclat
_gt_hideKB:
	push {r0-r2, lr}
	ldr r0, =0x04001000		@; B DISPCNT 0x04001000
	ldr r1, [r0]
	mov r2, #7				@; 0b111
	mov r2, r2, lsl #9		@; 0b1110 0000 0000
	bic r1, r2				@; Bit 9, 10 y 11: Display BG 1+2+3
	str r1, [r0]
	pop {r0-r2, pc}

@; Canvia el n�mero de zocalo y el PID de la interfice del teclado
@; r2: zocalo
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
	
	@; R0: _gd_qKbwait
	@; R2: _gd_nKbwait - 1
_gt_desplKbwait:
	push {r0-r5, lr}
	ldr r5, =_gd_maxIndex		@; Tambien desplazo los indices
	mov r3, #0					@; Primera pos
	mov r1, #1					@; Siguiente
	.Ldespl:
	ldrb r4, [r0, r1]
	strb r4, [r0, r3]
	ldrb r4, [r5, r1]
	strb r4, [r5, r3]
	add r3, #1
	add r1, #1
	cmp r3, r2
	ble .Ldespl
	pop {r0-r5, pc}

	.global _gt_getstring
@; Rutina que copia la string entrada por el teclado a la string del
@; proceso que la ha pedido. Devuelve el n�mero de caracteres leido 
@; Parametros:
@; R0: string -> direcci�n base del vector de caracteres (bytes)
@; R1: max_char -> n�mero m�ximo de caracteres del vector
@; R2: zocalo -> n�mero de z�calo del proceso invocador
_gt_getstring:
	push {r1-r6, lr}
	cmp r2, #0						@; SO no pot estar en la cua del teclat
	moveq r1, #0
	streqb r1, [r0]
	beq .Lend_getstring
	
	ldr r3, =0x04001000				@; DISP CNT SUB 0x04001000
	ldr r4, [r3]
	tst r4, #512					@; bit fons 1
	bne .LKBOn 						@; bit a 1
	
	bl _gt_showKB
	ldr r3, =0x04000184				@; REG_IPC_FIFO_CR
	ldr r4, [r3]
	mov r5, #1
	mov r5, r5, lsl #15				@; Construir mascara
	orr r4, r5						@; Activar FIFO de envio/recepcion
	str r4, [r3]					
	
	ldr r3, =0x0400010E				@; TIMER3_CR
	ldrh r4, [r3]
	orr r4, #0x80					@; Timer start
	strh r4, [r3]
	
	bl _gt_zocPid					@; Canviar zocalo i PID
	
	mov r4, r0						@; Salvar direccio str
	mov r3, r2						@; Salvar socul proces
	
	mov r0, #BALDOSA_AZUL			@; Color a pintar
	mov r2, #0						@; "Mode": 0 pintar normal, 1 pintar resta en blanc
	bl _gt_pintarCuadreText			@; Pintar cuadre de text on es pot escriure
	
	mov r0, r4
	mov r2, r3

.LKBOn:
	bl _gp_inhibirIRQs		@; Mientras modifico colas de ejecucion inhibo IRQs
	
	ldr r3, =_gd_pidz
	ldr r5, [r3]
	mov r4, #1
	mov r4, r4, lsl #31		@; bit de mes pes a 1
	orr r4, r5				@; activar bit de mes pes
	str r4, [r3]
	
	ldr r3, =_gd_qKbwait
	ldr r4, =_gd_nKbwait
	ldr r6, =_gd_maxIndex
	ldrb r5, [r4]
	
	strb r1, [r6, r5]		@; A�adir maxIndex		
	strb r2, [r3, r5]		@; A�adir zocalo a qKbwait
	add r5, #1
	strb r5, [r4]
	
	bl _gp_desinhibirIRQs
	bl _gp_WaitForVBlank		@; proces guardat a la cua de KB, salvar proces
	
	ldr r2, =_gd_strIAddr
	ldr r2, [r2]				@; r2: direccion de la str en la pantalla
	ldr r3, =_gd_index			
	
	mov r4, #0					@; r4: indice de copia
	ldrb r3, [r3]				@; R3: cursor del teclado
	mov r5, #0					@; valor para restaurar
.LcopiarStr:
	cmp r4, r3					@; Comparo con el indice con el cursor
	beq .LfiCopiarStr
	mov r4, r4, lsl #1
	ldrh r6, [r2, r4]			@; Leer codigo baldosa string
	add r6, #32					@; Transformar baldosa -> ASCII
	strh r5, [r2, r4]			@; Restaurar codigo baldosa string
	mov r4, r4, lsr #1
	strb r6, [r0, r4]			@; Guardar caracter en string de entrada
	add r4, #1					@; Incrementar indice
	b .LcopiarStr				@; Si salto aqui faltan posiciones para copiar
	
	.LfiCopiarStr:
	cmp r3, r1					@; Comparo con el maxchar
	beq .LfiCopiar				@; Salida si cursor == maxchar 
								@; Se han copiado y borrado maxchar caracteres	

	mov r3, r4					@; R4: indice actual
.Lborrar:
	mov r3, r3, lsl #1
	strh r5, [r2, r3]			@; Restaurar codigo baldosa cuadro texto
	mov r3, r3, lsr #1
	add r3, #1					@; Incrementar indice
	cmp r3, r1					@; Comparar con maxchar
	blo .Lborrar				@; Saltar si no se ha llegado a maxchar - 1
	
.LfiCopiar:
	strb r5, [r0, r4]			@; A�adir el \0 al final del str

	mov r0, r4					@; R4: Caracteres copiados
	
	ldr r1, =_gd_nKbwait
	ldrb r1, [r1]				@; Numero de procesos en cola de teclado
	cmp r1, #0					@; Si no hay mas procesos esperando string
	bleq _gt_endKb				@; Esconder el teclado y desactivar FifoIRQ		
	blne _gt_resetKb			@; Reseter cabecera del teclado

.Lend_getstring:
	pop {r1-r6, pc}	
	
	.global _gt_timer3
_gt_timer3:
	push {r0-r2, lr}
	ldr r0, =_gd_curIAddr
	ldr r0, [r0]			@; R0: pos ini cursor
	ldr r1, =_gd_index
	ldrb r1, [r1]			@; R1: index
	mov r1, r1, lsl #1
	ldrh r2, [r0, r1]		@; R2: pos cursor
	cmp r2, #0
	moveq r2, #CURSOR		@; '|'	cursor rosa
	movne r2, #0
	strh r2, [r0, r1]
	pop {r0-r2, pc}
	
	.global _gt_endKb
_gt_endKb:
	push {r0-r3, lr}
	bl _gt_hideKB				@; Esconder teclado
	
	bl _gt_resetCursor
	
	ldr r1, =0x04000184			@; REG_FIFO_CR
	ldrh r2, [r1]
	mov r3, #1
	mov r3, r3, lsl #15			@; r3: bit15
	bic r2, r3					
	strh r2, [r1]				@; Desactivar fifos envio y recepcion
	
	ldr r1, =0x0400010E			@; Timer CR
	ldrh r2, [r1]
	bic r2, #0x80				@; Timer stop
	strh r2, [r1]
	
	mov r0, #BALDOSA_BLANCA		@; R0 = color a pintar (blanc)
	ldr r1, =_gd_maxIndex
	ldrb r1, [r1]				@; R1 = # de baldosas a pintar
	mov r2, #1					
	bl _gt_pintarCuadreText

	bl _gt_borrarText
	
	pop {r0-r3, pc}
	
	
	.global _gt_resetKb
_gt_resetKb:
	push {r0-r3, lr}
	
	bl _gt_resetCursor
	
	ldr r3, =_gd_qKbwait		@; Si hay mas procesos en el teclado
	ldrb r2, [r3]				@; Cambiar la cabecera del teclado
	bl _gt_zocPid
	
	mov r0, #BALDOSA_AZUL		@; Baldosa a pintar
	ldr r1, =_gd_maxIndex
	ldrb r1, [r1]				@; # baldoses a pintar
	mov r2, #1					@; pintar la resta blanques
	bl _gt_pintarCuadreText
	
	bl _gt_borrarText

	pop {r0-r3, pc}
	
	@; Borra el text de tot el cuadre de text
_gt_borrarText:
	push {r0-r2, lr}

	ldr r0, =_gd_strIAddr
	ldr r0, [r0]
	mov r1, #0				@; Indice
	mov r2, #0				@; Valor restaurar
	.LborrarText:
	strh r2, [r0, r1]
	add r1, #2
	cmp r1, #60
	blo .LborrarText

	pop {r0-r2, pc}

	@; Pinta el cuadre de text d'un color en especific
	@; R0: Color a pintar
	@; R1: # de baldoses a pintar
	@; R2: 0 = pintar baldosas; !0 = pintar resto baldosas blanca
_gt_pintarCuadreText:
	push {r0-r4, lr}

	mov r1, r1, lsl #1
	ldr r3, =_gd_strIAddr
	ldr r3, [r3]
	sub r3, #0x800		@; BG1 cuadre text (fondo color)
	mov r4, #0
.LpintarCuadreText:
	cmp r4, r1
	bge .LsegPintarCuadreText
	strh r0, [r3, r4]
	add r4, #2
	b .LpintarCuadreText

.LsegPintarCuadreText:
	cmp r2, #0
	beq .LfipintarCuadreText

	mov r0, #BALDOSA_BLANCA
.LpintarCuadreResta:
	cmp r4, #60			@; Si s'han pintat totes les baldoses
	bge .LfipintarCuadreText
	strh r0, [r3, r4]	
	add r4, #2
	b .LpintarCuadreResta

.LfipintarCuadreText:
	pop {r0-r4, pc}

_gt_resetCursor:
	push {r0-r3, lr}

	ldr r0, =_gd_curIAddr
	ldr r0, [r0]				@; Pos inicial mem cursor
	ldr r1, =_gd_index			@; Resetejar index
	ldrb r2, [r1]				@; R2: posicion del cursor actualmente
	mov r2, r2, lsl #1
	mov r3, #0
	strh r3, [r0, r2]			@; Reiniciar indice visualmente
	strb r3, [r1]				@; Reiniciar variable
	mov r3, #CURSOR				@; '|'
	strh r3, [r0]				@; Mover cursor al inicio

	pop {r0-r3, pc}

	.global _gt_getXYbuttons
	@; Lee el estado de los botones XY de manera asincrona sin interrupir la 
	@; ejecucion del programa
	@; ret r0: bit0 (X = 1 pressed / 0 released), bit1 (Y 1 pressed / 0 released)
_gt_getXYbuttons:
	push {lr}
	ldr r0, =0x04000180			@; IPCSYNC
	ldrb r0, [r0]				@; leer bits base
	and r0, #3					@; bits base
	pop {pc}
	
.end 