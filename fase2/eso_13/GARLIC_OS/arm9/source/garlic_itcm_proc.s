@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	c�digo de las rutinas de control de procesos (2.0)
@;						(ver "garlic_system.h" para descripci�n de funciones)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupci�n
	@; de retrazado vertical (VBL); es un sustituto de la "swi #5", que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupcion)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (m�scara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (m�scara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones espec�ficos
	ldr r0, [r2, #4]		@; R0 = m�scara de int. del manejador indexado
	cmp	r0, #0				@; si m�scara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de b�squeda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = direcci�n de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si direcci�n = 0
	mov r2, lr				@; guardar direcci�n de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar direcci�n de retorno
	b .Lintr_ret			@; salir del bucle de b�squeda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente �ndice del vector de
	b	.Lintr_find			@; manejadores de interrupciones espec�ficas
.Lintr_ret:
	mov r1, r0				@; indica qu� interrupci�n se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupci�n servida)
	ldr	r0, =__irq_flags	@; R0 = direcci�n flags IRQ para gesti�n IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupci�n
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepci�n IRQ de la BIOS


	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.
_gp_rsiVBL:
	push {r4-r7, lr}

	@; augmentem el contador de ticks general
	ldr r4, =_gd_tickCount
	ldr r5, [r4]
	add r5, #1
	str r5, [r4]
	bl _gp_actualitzarRetard	@; cridem la funci� que actualitza el retard dels processos
								@; que es troben a la cua de delay


	@;mirem si hi ha algun proces pendent a la cua de ready
	ldr r4, =_gd_nReady		@; r4 = direcci� _gd_nReady
	ldr r5, [r4]			@; r5 = n�mero de processos a la cua de ready
	cmp r5, #0
	beq .finalRSI
	
	@; mirem si el proc�s a desbancar �s el del SO
	ldr r6, =_gd_pidz	@; r6 = direccio _gd_pidz
	ldr r7, [r6]		@; r7 = pid + socol (28 bits + 4 bits) 
	cmp r7, #0			@; si val 0, vol dir que es el proces del SO
	beq .salvarContext

	mov r7, r7, lsr #4	@; desplacem els bits del socol, ens quedem nomes amb el pid
	cmp r7, #0			@; si el pid es 0, pero no es el proces del SO, no cal salvar el context
	beq .restaurarContext

	.salvarContext:
	bl _gp_salvarProc

	.restaurarContext:
	bl _gp_restaurarProc

	.finalRSI:
	
	@; augmentem els tics del proces que queda en execucio
	ldr r4, =_gd_pidz
	ldr r4, [r4]		@; r4 = pidz
	and r4, r4, #15		@; r4 = z
	mov r5, #24
	ldr r6, =_gd_pcbs
	mla r6, r4, r5, r6	@; r6 = direccio pcb del socol
	ldr r4, [r6, #20]	@; r4 = valor de worktics
	add r4, #1			@; worktics++
	str r4, [r6, #20]		@; desem el nou valor dels worktics
	
	pop {r4-r7, pc}


	@; Rutina per actualitzar el retard dels processos bloquejats
	@; Resta 1 tic a cada contador
	@; Si algun proc�s arriba a 0, el treu de la cua de delay i
	@; el posa a la cua de ready
_gp_actualitzarRetard:
	push {r0-r10, lr}
	
	ldr r0, =_gd_nDelay 	@; r0 = direcci� de gd_nDelay
	ldr r1, [r0]			@; r1 = num de processos retardats
	mov r2, #0				@; r2 = �ndex
	ldr r3, =_gd_qDelay		@; r3 = direcci� gd_qDelay
	ldr r4, =_gd_nReady		@; r4 = direcci� gd_nReady
	ldr r5, =_gd_qReady		@; r5 = direcci� gd_qReady
	
	cmp r2, r1	
	beq .LfiActualitzaRetard	@; si no hi ha cap proc�s a la cua

	.LForActualitzarRetard:
	ldr r6, [r3, r2, lsl #2]	@; r6 = s�col + tics
	sub r6, #1					@; restem 1 als tics
	ldr r7, =0xffff
	and r7, r6					@; r7 = tics
	cmp r7, #0
	bne .LDesarNousTics
	
	@; si el contador arriba a 0, canviem el proc�s de cua
	sub r1, #1
	str r1, [r0]		@; decrementem el numero de processos en delay
	
	mov r6, r6, lsr #24	@; r6 = s�col
	ldr r7, [r4]		@; r7 = num processos en ready
	strb r6, [r5, r7]	@; desem el s�col a la cua de ready
	add r7, #1
	str r7, [r4]		@; actualitzem el num de processos en ready
	
	@; reorganitzem la cua de delay
	mov r8, r2			@; r8 = �ndex2
	cmp r8, r1
	beq .LTractarSeg	@; si ja hem mirat tots els processos
	
.LReorganitzarCuaDelay:
	add r9, r8, #1				@; r9 = punter a la seg�ent posici� de la cua
	ldr r10, [r3, r9, lsl #2]	@; r10 = word de la seg�ent posici�
	str r10, [r3, r8, lsl #2]	@; desem el valor a la posici� actual
	add r8, #1
	cmp r8, r1
	blo .LReorganitzarCuaDelay
	b .LTractarSeg
	
.LDesarNousTics:
	str r6, [r3, r2, lsl #2] 	@; desem els nous tics	
	add r2, #1		@; r2 = �ndex++	
	
.LTractarSeg:
	cmp r2, r1		@; mentre faltin processos per tractar
	blo .LForActualitzarRetard
	
.LfiActualitzaRetard:
	pop {r0-r10, pc}

	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs
	@;Par�metros
	@; R4: direcci�n _gd_nReady
	@; R5: n�mero de procesos en READY
	@; R6: direcci�n _gd_pidz
	@;Resultado
	@; R5: nuevo n�mero de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}
	
	@; canviem el mode d'execuci� a mode sistema
	mov r8, sp		@; r9 = sp del mode IRQ
	
	mrs r9, cpsr	@; r10 = valor del cpsr
	eor r9, #0xd	@; modifiquem els bits de mode (12 -> 1F) per passar a mode sistema
	msr cpsr, r9	@; desem el nou cpsr
	
	@; apilem els valors dels registres a la pila d'usuari
	ldr r11, [r8, #56]	@; r11 = r12 proces
	ldr r10, [r8, #12]	@; r10 = r11 proces
	ldr r9, [r8, #8]	@; r9 = r10 proces
	push {r9-r11, lr}	@; apilem lr i els reg. r12, r11 i r10
	
	ldr r11, [r8, #4]	@; r11 = r9 proces
	ldr r10, [r8]		@; r10 = r8 proces
	ldr r9, [r8, #32]	@; r9 = r7 proces
	push {r9-r11}		@; apilem els reg. r9, r8 i r7
	
	ldr r11, [r8, #28]	@; r11 = r6 proces
	ldr r10, [r8, #24]	@; r10 = r5 proces
	ldr r9, [r8, #20]	@; r9 = r4 proces
	push {r9-r11}		@; apilem els reg. r6, r5 i r4
	
	ldr r11, [r8, #52]	@; r11 = r3 proces
	ldr r10, [r8, #48]	@; r10 = r2 proces
	ldr r9, [r8, #44]	@; r9 = r1 proces
	ldr r8, [r8, #40]	@; r8 = r0 proces
	push {r8-r11}		@; apilem els reg. r3, r2, r1 i r0
	
	
	@;guardem el numero de socol del proces a desbancar a la ultima posicio de la cua de ready
	ldr r8, [r6]	@; r8 = pidz
	mov r9, r8, lsr #31
	cmp r9, #1
	beq .LprocesEnDelay	@; si el proc�s est� retardat, no el desem a la cua de Ready
	
	and r8, #0xf	@; r8 = z
	ldr r9, =_gd_qReady			@; r9 = direccio base de la cua de ready
	strb r8, [r9, r5]			@; guardem z a la ultima posicio del vector
	
	@; augmentem el comptador de processos de la cua de ready
	add r5, #1
	str r5, [r4]
	b .LprocesNoEnDelay
	
	.LprocesEnDelay:
	and r8, #0xf	@; r8 = z
	
	.LprocesNoEnDelay:
	@; actualitzem la taula de pcbs
	ldr r9, =_gd_pcbs	@; r9 = direccio base de la taula de pcbs
	mov r10, #24
	mul r10, r8, r10	@; r8: z, r10 = adreca base element taula pcbs
	add r9, r10			@; r9 = direccio base de l'element de la taula de pcbs que volem modificar
	str sp, [r9, #8]	@; desem r11 (sp sistema) al pcb
						@; sp es el tercer camp de l'entrada
	
	@; tornem al mode IRQ
	mrs r10, cpsr
	eor r10, #0xd	@; modifiquem els bits de mode (1F -> 12) per passar a mode IRQ
	msr cpsr, r10	@; desem el nou cpsr
	
	mrs r11, spsr		@; r11= valor del spsr
	str r11, [r9, #12]	@; desem sprs (cpsr sistema) al pcb
	
	ldr r11, [sp, #60]	@; r11 = pc procés a desbancar
	str r11, [r9, #4]	@; desem el pc al pcb	
	
	pop {r8-r11, pc}

	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY
	@;Par�metros
	@; R4: direcci�n _gd_nReady
	@; R5: n�mero de procesos en READY
	@; R6: direcci�n _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}
	
	@; obtenim el sòcol del procés a restaurar
	ldr r8, =_gd_qReady		@; r8 = direcció base de la cua de ready
	ldrb r9, [r8]			@; r9 = z
	
	@; eliminem el primer element de la cua de ready i desplacem la resta
	mov r10, #1		@; r10 = index (n + 1)
	
	.for:
	ldrb r11, [r8, r10]		@; r11 = valor de la posicio n + 1 de la cua
	sub r10, r10, #1		@; r10 = n
	strb r11, [r8, r10]		@; desem r11 a la posicio n de la cua
	add r10, #2				@; index++
	cmp r10, r5
	blo .for		@; index < n_Ready?
	
	sub r5, #1		@; r5 = nou numero de processos en ready
	str r5, [r4]
	
	@; desem el PID i el socol a _gd_pidz
	ldr r8, =_gd_pcbs	@; r8 = direccio base taula pcbs
	mov r11, #24
	mul r11, r9, r11	@; r11 = index * 24
	add r8, r11			@; r8 = direcció base de l'element al que volem accedir (pcb)
	ldr r10, [r8]		@; r10 = pid procés
	
	mov r10, r10, lsl #4
	orr r10, r9			@; r10 = pidz
	ldr r9, =_gd_pidz	@; r9 = adreça pidz
	str r10, [r9]		@; desem el pidz
	
	@; recuperem els valors de r15 i cpsr del pcb
	ldr r9, [r8, #4]	@; r9 = pc procés
	str r9, [sp, #60]	@; desem la nova adreça de retorn
	
	ldr r9, [r8, #12]	@; r9 = cpsr procés
	msr spsr, r9		@; desem el nou spsr (cpsr del procés)
	
	@; canviem a mode sistema
	mov r9, sp				@; r8 = sp del mode IRQ
	
	mrs r10, cpsr	@; r10 = valor del cpsr
	eor r10, #0xd	@; modifiquem els bits de mode (12 -> 1F) per passar a mode sistema
	msr cpsr, r10	@; desem el nou cpsr
	
	@; ara estem en mode sistema, desapilem els regisres
	ldr sp, [r8, #8]	@; sp = sp procés a restaurar
	mov r8, r9			@; r8 = sp del mode IRQ
	
	pop {r9-r11}
	str r9, [r8, #40]	@; desem r0 a la pila del mode IRQ
	str r10, [r8, #44]	@; desem r1 a la pila del mode IRQ
	str r11, [r8, #48]	@; desem r2 a la pila del mode IRQ
	
	pop {r9-r11}
	str r9, [r8, #52]	@; desem r3 a la pila del mode IRQ
	str r10, [r8, #20]	@; desem r4 a la pila del mode IRQ
	str r11, [r8, #24]	@; desem r5 a la pila del mode IRQ
	
	pop {r9-r11}
	str r9, [r8, #28]	@; desem r6 a la pila del mode IRQ
	str r10, [r8, #32]	@; desem r7 a la pila del mode IRQ
	str r11, [r8]		@; desem r8 a la pila del mode IRQ
	
	pop {r9-r11}
	str r9, [r8, #4]	@; desem r9 a la pila del mode IRQ
	str r10, [r8, #8]	@; desem r10 a la pila del mode IRQ
	str r11, [r8, #12]	@; desem r11 a la pila del mode IRQ
	
	pop {r9, lr}
	str r9, [r8, #56]	@; desem r12 a la pila del mode IRQ
	
	
	@; tornem al mode IRQ
	mrs r10, cpsr
	eor r10, #0xd	@; modifiquem els bits de mode (1F -> 12) per passar a mode IRQ
	msr cpsr, r10	@; desem el nou cpsr
	
	pop {r8-r11, pc}




	.global _gp_numProc
	@;Resultado
	@; R0: n�mero de procesos total
_gp_numProc:
	push {r1-r2, lr}
	mov r0, #1				@; contar siempre 1 proceso en RUN
	ldr r1, =_gd_nReady
	ldr r2, [r1]			@; R2 = n�mero de procesos en cola de READY
	add r0, r2				@; a�adir procesos en READY
	ldr r1, =_gd_nDelay
	ldr r2, [r1]			@; R2 = n�mero de procesos en cola de DELAY
	add r0, r2				@; a�adir procesos retardados
	ldr r1, =_gd_nKbwait
	ldrb r2, [r1]			@; R2 = n�mero de procesos en cola de KBWAIT del progT
	add r0, r2				@; a�adir procesos retardados
	pop {r1-r2, pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecuci�n y
	@; coloc�ndolo en la cola de READY
	@;Par�metros
	@; R0: intFunc funcion,
	@; R1: int zocalo,
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
	push {r0-r10, lr}
	
	@; comprovem que el socol es correcte i este� lliure
	cmp r1, #0		@; si es vol assignar el socol 0
	moveq r0, #1	@; retornem error
	beq .fi

	ldr r4, =_gd_pcbs
	mov r5, #24
	mul r6, r1, r5
	add r4, r6		@; r4 = direccio base element a la taula de pcbs
	ldr r5, [r4]	@; r5 = pid
	cmp r5, #0
	movne r0, #1	@; si el socol ja esta� ocupat, retornem error
	bne .fi
	
	@; obtenim un nou pid pel proces
	ldr r5, =_gd_pidCount	@; r5 = direccio pidCount
	ldr r6, [r5]			@; r6 = valor pidCount
	add r6, r6, #1
	str r6, [r5]		@; pidCount++
	str r6, [r4]		@; desem el pid a la taula de pcbs

	@; desem el pc del proces a la taula de pcbs
	add r0, #4			@; r0 = pc
	str r0, [r4, #4]	@; desem el pc a la taula de pcbs
	
	@; desem el keyname a la taula de pcbs
	ldr r0, [r2]	@; primers 4 bytes del nom del proces
	str r0, [r4, #16]	@; desem el keyName
	
	@; calculem l'adreca base de la pila
	mov r7, sp
	ldr r5, =_gd_stacks			@; r5 = adreca base vector piles
	add sp, r5, r1, lsl #9		
	
	@; inicialitzem els registres de la pila
	ldr r5, =_gp_terminarProc	@; r5 = direccio gp_terminarProc
	push {r5}		@; apilem la direccio de terminarProc()
	
	mov r5, #0
	mov r6, #0
	
	.while:
	push {r5}	@; apilem un 0
	add r6, #1	@; augmentem el comptador
	cmp r6, #11	
	bls .while	@; mentre no haguem apilat 12 zeros
	
	push {r3}	@; apilem el parametre al top de la pila
	
	@; desem el punter a la pila en el pcb
	str sp, [r4, #8]
	mov sp, r7			@; recuperem el valor original de la pila
	
	@; desem el valor inicial del reg. cpsr
	mov r5, #0x1f		
	str r5, [r4, #12]
	
	@; inicialitzem el camp workTicks del pcb
	mov r5, #0
	str r5, [r4, #20]
	
	@; desem el s�col a la cua de ready
	
	bl _gp_inhibirIRQs		@; modificarem la cua de Ready, iniciem SC
	ldr r5, =_gd_qReady		@; r5 = adre�a base qReady
	ldr r6, =_gd_nReady		@; r6 = adre�a base nReady
	ldr r7, [r6]			@; r7 = nReady
	
	strb r1, [r5, r7]		@; desem el s�col (r1) en la �ltima posici� de la cua de ready
	add r7, #1
	str r7, [r6]
	bl _gp_desinhibirIRQs	@; fi SC
	
	mov r0, #0	
	.fi:
	pop {r0-r10, pc}



	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del z�calo actual, para indicar que esa
	@; entrada del vector _gd_pcbs est� libre; tambi�n pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el n�mero de z�calo), para que el c�digo
	@; de multiplexaci�n de procesos no salve el estado del proceso terminado.
_gp_terminarProc:
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + z�calo
	and r1, r1, #0xf		@; R1 = z�calo del proceso desbancado
	bl _gp_inhibirIRQs
	str r1, [r0]			@; guardar z�calo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = direcci�n base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
	str r3, [r2, #20]		@; borrar porcentaje de USO de la CPU
	ldr r0, =_gd_sincMain
	ldr r2, [r0]			@; R2 = valor actual de la variable de sincronismo
	mov r3, #1
	mov r3, r3, lsl r1		@; R3 = m�scara con bit correspondiente al z�calo
	orr r2, r3
	str r2, [r0]			@; actualizar variable de sincronismo
	bl _gp_desinhibirIRQs
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto


	.global _gp_matarProc
	@; Rutina para destruir un proceso de usuario:
	@; borra el PID del PCB del z�calo referenciado por par�metro, para indicar
	@; que esa entrada del vector _gd_pcbs est� libre; elimina el �ndice de
	@; z�calo de la cola de READY o de la cola de DELAY, est� donde est�;
	@; Par�metros:
	@;	R0:	z�calo del proceso a matar (entre 1 y 15).
_gp_matarProc:
	push {r0-r7, lr}

	bl _gp_inhibirIRQs

	@; posem _gd_pcbs[z].PID a 0
	
	ldr r1, =_gd_pcbs		@; r1 = direccio gd_pcbs
	mov r2, #0				@; r2 = 0
	mov r3, #24				@; r3 = 24
	mla r4, r0, r3, r1		@; r4 = direccio base gd_pcbs + (socol * 24)
	str r2, [r4]			@; desem un 0 al camp del pid
	str r2, [r4, #20]		@; posem a 0 els worktics
	

	@; busquem el socol a la cua de ready
	ldr r1, =_gd_qReady		@; r1 = adreca base _gd_qReady
	ldr r2, =_gd_nReady		@; r2 = adreca nReady
	ldr r3, [r2]			@; r3 = nReady
	cmp r3, #0
	beq .LmatarProcBuscarADelay	@; si la cua est� buida, busquem a delay
	mov r4, #0				@; r4 = index
.LmatarProcBucleReady:
	ldrb r5, [r1, r4]		@; r5 = socol
	cmp r5, r0
	subeq r3, #1			@; si trobem el socol, r3 = nReady - 1
	streq r3, [r2]			@; ho desem
	beq .LmatarProcTrobatAReady
	add r4, #1				@; index++
	cmp r4, r3
	bne .LmatarProcBucleReady	@; si no coincidex, seguim buscant
	
	b .LmatarProcBuscarADelay	@; si no l'hem trobat, buscarem a delay
	
	
	@; hem trobat el socol a ready, l'eliminem desplacant la resta d'elements
.LmatarProcTrobatAReady:
	add r6, r4, #1		@; r6 = index + 1
	ldrb r7, [r1, r6] 	@; r7 = socol index + 1
	strb r7, [r1, r4]	@; desem socol index + 1 a index
	add r4, #1
	cmp r4, r3
	blo .LmatarProcTrobatAReady
	
	b .LfiMatarProc

	@; si no hem trobat el socol a ready, busquem a delay
.LmatarProcBuscarADelay:
	ldr r1, =_gd_qDelay		@; r1 = adreca base _gd_qDelay
	ldr r2, =_gd_nDelay		@; r2 = adreca nDelay
	ldr r3, [r2]			@; r3 = nDelay	
	mov r4, #0				@; r4 = index
	cmp r3, #0
	beq .LmatarProcBuscarAKbwait
	
.LmatarProcBucleDelay:
	ldr r5, [r1, r4, lsl #2]	@; r5 = socol + tics
	mov r5, r5, lsr #24		@; r5 = socol
	cmp r5, r0
	subeq r3, #1			@; si trobem el socol, r3 = nDelay - 1
	streq r3, [r2]			@; ho desem
	beq .LmatarProcTrobatADelay
	add r4, #1				@; index++
	cmp r4, r3
	bne .LmatarProcBucleDelay	@; si no coincidex, seguim buscant
	
	@; si no l'hem trobat, busquem a la cua de teclat del progT
	b .LmatarProcBuscarAKbwait
	
	
	@; hem trobat el socol a delay, l'eliminem desplacant la resta d'elements
.LmatarProcTrobatADelay:
	add r6, r4, #1				@; r6 = index + 1
	ldr r7, [r1, r6, lsl #2] 	@; r7 = socol index + 1
	str r7, [r1, r4, lsl #2]	@; desem socol index + 1 a index
	add r4, #1
	cmp r4, r3
	blo .LmatarProcTrobatAReady
	
	@; si no hem trobat el socol a ready, busquem a kbwait
.LmatarProcBuscarAKbwait:
	ldr r1, =_gd_qKbwait		@; r1 = adreca base _gd_qKbwait
	ldr r2, =_gd_nKbwait		@; r2 = adreca _gd_nKbwait
	ldrb r3, [r2]				@; r3 = nKbwait	
	cmp r3, #0
	beq .LfiMatarProc
	
	mov r4, #0				@; r4 = index
.LmatarProcBucleKbwait:
	ldrb r5, [r1, r4]		@; r5 = socol
	cmp r5, r0
	subeq r3, #1			@; si trobem el socol, r3 = kbwait - 1
	streqb r3, [r2]			@; ho desem
	beq .LmatarProcTrobatAKbwait
	add r4, #1				@; index++
	cmp r4, r3
	bne .LmatarProcBucleKbwait	@; si no coincidex, seguim buscant

	@; si no l'hem trobat, acabem
	b .LfiMatarProc
	
	@; si hem trobat el s�col a kbwait
.LmatarProcTrobatAKbwait:

	ldr r5, =_gd_maxIndex	@; cua de maxIndex de Kb
	mov r2, r4				@; r2 index on es el zocol
	cmp r3, #0				@; si no hi ha mes procesos a la cua de Kb
	bleq _gt_endKb			@; ocultem el teclat resetejanlo
	beq .LfiMatarProc
	.LdesplqKbIndex:
	add r6, r4, #1		@; r6 = index + 1
	ldrb r7, [r1, r6] 	@; r7 = socol index + 1
	strb r7, [r1, r4]	@; desem socol index + 1 a index
	ldrb r7, [r5, r6]	@; desplaçem cua de indexos tambe
	strb r7, [r5, r4]
	add r4, #1
	cmp r4, r3
	blo .LdesplqKbIndex
	
	cmp r2, #0				@; Si el zocol matat es el que estaba en "run"
	bleq _gt_resetKb		@; restejem el teclat si hi ha mes a la cua
	
	.LfiMatarProc:
	bl _gp_desinhibirIRQs
	pop {r0-r7, pc}

	
	.global _gp_retardarProc
	@; retarda la ejecuci�n de un proceso durante cierto n�mero de segundos,
	@; coloc�ndolo en la cola de DELAY
	@;Par�metros
	@; R0: int nsec
_gp_retardarProc:
	push {r0-r6, lr}
	
	@; calculem quants tics s'ha de retardar el proc�s
	mov r1, #60		@; r1 = 60 tics -> 1s
	mul r2, r0, r1	@; r2 = num de tics a retardar
	
	@; construim un word amb el s�col i el retard
	
	bl _gp_inhibirIRQs
	ldr r3, =_gd_pidz	@; r3 = adre�a pidz
	ldr r4, [r3]		@; r4 = pidz
	cmp r4, #0		@; mirem que no sigui el SO
	beq .LfiRetardarProc	@; si ho �s, no cal fer res
	and r5, r4, #0xF		@; r5 = s�col
	mov r5, r5, lsl #24		@; r5 = s�col en els 8 bits alts
	orr r5, r2				@; r5 = s�col -> 8 bits alts
							@; 		retard -> 16 bits baixos
	
	@; afegim el word a la cua de delay
	ldr r1, =_gd_qDelay
	ldr r2, =_gd_nDelay
	ldr r6, [r2]				@; r6 = numero de processos a la cua de delay
	str r5, [r1, r6, lsl #2]	@; desem el word a la seg�ent posici� de la cua
	
	@; augmentem el contador de processos en delay
	add r6, #1
	str r6, [r2]
	
	@; modifiquem el bit alt del pidz
	orr r4, #0x80000000
	str r4, [r3]		
	
	@; desbanquem el proc�s
	bl _gp_desinhibirIRQs
	bl _gp_WaitForVBlank
	
	.LfiRetardarProc:
	bl _gp_desinhibirIRQs	
	pop {r0-r6, pc}


	.global _gp_inhibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 0, para inhibir todas
	@; las IRQs y evitar as� posibles problemas debidos al cambio de contexto
_gp_inhibirIRQs:
	push {r0-r1, lr}
	ldr r0, =0x4000208
	mov r1, #0
	str r1, [r0]		@; desem el nou IME
	pop {r0-r1, pc}


	.global _gp_desinhibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 1, para desinhibir todas
	@; las IRQs
_gp_desinhibirIRQs:
	push {r0-r1, lr}
	ldr r0, =0x4000208
	mov r1, #1
	str r1, [r0]		@; desem el nou IME
	pop {r0-r1, pc}


	.global _gp_rsiTIMER0
	@; Rutina de Servicio de Interrupci�n (RSI) para contabilizar los tics
	@; de trabajo de cada proceso: suma los tics de todos los procesos y calcula
	@; el porcentaje de uso de la CPU, que se guarda en los 8 bits altos de la
	@; entrada _gd_pcbs[z].workTicks de cada proceso (z) y, si el procesador
	@; gr�fico secundario est� correctamente configurado, se imprime en la
	@; columna correspondiente de la tabla de procesos.
_gp_rsiTIMER0:
	push {r0-r10, lr}

	@; recompte tics dels procesos actius
	ldr r9, =_gd_pcbs	@; r9 = direccio gd_pcbs
	mov r10, #24		@; r10 = 24 (desplacament entre pcbs)
	ldr r1, [r9, #20]	@; r1 = camp workticks SO
	and r1, #0x00FFFFFF	@; r1 = tics del SO
	mov r5, #1			@; r5 = socol seguent
	
.LbucleTics:
	mla r4, r5, r10, r9	@; r4 = pcb del socol indicat per r9
	ldr r6, [r4]		@; r6 = pid
	cmp r6, #0
	beq .LbucleTicsSeguent
	ldr r6, [r4, #20]	@; r6 = camp worktics
	and r6, #0x00FFFFFF	@; r6 = tics
	add r1, r6			@; r1 = suma tics totals
	
.LbucleTicsSeguent:
	add r5, #1			@; r5 = index++
	cmp r5, #15
	ble .LbucleTics
	
	
	@; ara ja tenim els tics totals en r1
	@; calculem el percentatge de cada proces i resetegem el camp worktics
	mov r5, #100
	add r2, r9, #20		@; r2 = posicio mem worktics
	ldr r0, [r2]		@; r0 = camp worktics SO
	and r0, #0x00FFFFFF	@; r0= tics SO
	mul r0, r5			@; r0 = tics * 100 (numerador)
	ldr r3, =_gd_residu	@; r3 = variable on es desara el residu
	bl _ga_divmod		@; el resultat es desa al camp de worktics	
	mov r8, #0			@; r8 = index socol
	b .LescriurePerc

.LescriurePercBucle:
	mla r4, r8, r10, r9	@; r4 = pcb del socol que toca
	ldr r6, [r4]		@; r6 = pid
	cmp r6, #0			@; mirem si hi ha algun proces en el socol
	beq .LescriurePercSeg
	
	add r2, r4, #20		@; r2 = posicio worktics
	ldr r0, [r2]		@; r0 = camp worktics
	and r0, #0x00FFFFFF	@; r0 = tics
	mul r0, r5			@; r0 = tics * 100
	ldr r3, =_gd_residu	@; r3 = variable on es desara el residu
	bl _ga_divmod

.LescriurePerc:
	mov r7, r1
	ldr r1, [r2]		@; r1 = percentatge calculat per _ga_divmod
	mov r0, r1			@; r0 = percentatge calculat per _ga_divmod
	mov r1, r1, lsl #24	@; r1 = percentatge als 8 bits m�s alts
	str r1, [r2]		@; desem el percentatge al camp worktics
	mov r2, r0			@; r2 = percentatge calculat per _ga_divmod
	mov r1, #4			@; r1 = longitud string
	ldr r0, =_gd_percentatge	@; r0 = var on desar el string
	bl _gs_num2str_dec			@; convertim el % a un string
	
	ldr r0, =_gd_percentatge
	add r1, r8, #4	@; r1 = fila (socol + 4)
	mov r2, #28		@; r2 = columna
	mov r3, #0		@; r3 = color
	bl _gs_escribirStringSub	@; escribim el %
	mov r1, r7		
	
.LescriurePercSeg:
	add r8, #1 		@; r8 = index++
	cmp r8, #15
	ble .LescriurePercBucle
	
	
	@; un cop modificats tots els percentatges
	@; posem a 1 el bit 0 de la variable _gd_sincMain
	ldr r0, =_gd_sincMain
	ldr r1, [r0]
	orr r1, #1
	str r1, [r0]
	
	
	pop {r0-r10, pc}

	
.end