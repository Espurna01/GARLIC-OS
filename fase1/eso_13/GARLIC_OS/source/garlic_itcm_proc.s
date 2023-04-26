@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	c�digo de las funciones de control de procesos (1.0)
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
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupci�n)
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

	@;mirem si hi ha algun procés pendent a la cua de ready
	ldr r4, =_gd_nReady		@; r4 = direcció _gd_nReady
	ldr r5, [r4]			@; r5 = número de processos a la cua de ready
	cmp r5, #0
	beq .finalRSI
	
	@; mirem si el procés a desbancar és el del SO
	ldr r6, =_gd_pidz	@; r6 = direcció _gd_pidz
	ldr r7, [r6]		@; r7 = pid + sòcol (28 bits + 4 bits) 
	cmp r7, #0			@; si val 0, vol dir que és el procés del SO
	beq .salvarContext

	mov r7, r7, lsr #4		@; desplacem els bits del sòcol, ens quedem només amb el pid
	cmp r7, #0			@; si el pid és 0, però no és el procés del SO, no cal salvar el context
	beq .restaurarContext

	.salvarContext:
	bl _gp_salvarProc

	.restaurarContext:
	bl _gp_restaurarProc

	.finalRSI:
	pop {r4-r7, pc}


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
	
	@; canviem el mode d'execució a mode sistema
	mov r8, sp		@; r9 = sp del mode IRQ
	
	mrs r9, cpsr	@; r10 = valor del cpsr
	eor r9, #0xd	@; modifiquem els bits de mode (12 -> 1F) per passar a mode sistema
	msr cpsr, r9	@; desem el nou cpsr
	
	@; apilem els valors dels registres a la pila d'usuari
	ldr r11, [r8, #56]	@; r11 = r12 procés
	ldr r10, [r8, #12]	@; r10 = r11 procés
	ldr r9, [r8, #8]	@; r9 = r10 procés
	push {r9-r11, lr}	@; apilem lr i els reg. r12, r11 i r10
	
	ldr r11, [r8, #4]	@; r11 = r9 procés
	ldr r10, [r8]		@; r10 = r8 procés
	ldr r9, [r8, #32]	@; r9 = r7 procés
	push {r9-r11}		@; apilem els reg. r9, r8 i r7
	
	ldr r11, [r8, #28]	@; r11 = r6 procés
	ldr r10, [r8, #24]	@; r10 = r5 procés
	ldr r9, [r8, #20]	@; r9 = r4 procés
	push {r9-r11}		@; apilem els reg. r6, r5 i r4
	
	ldr r11, [r8, #52]	@; r11 = r3 procés
	ldr r10, [r8, #48]	@; r10 = r2 procés
	ldr r9, [r8, #44]	@; r9 = r1 procés
	ldr r8, [r8, #40]	@; r8 = r0 procés
	push {r8-r11}		@; apilem els reg. r3, r2, r1 i r0
	
	
	@;guardem el número de sòcol del procés a desbancar a la última posició de la cua de ready
	ldr r8, [r6]	@; r8 = pidz
	and r8, #0xf	@; r8 = z

	ldr r9, =_gd_qReady			@; r9 = direcció base de la cua de ready
	strb r8, [r9, r5]			@; guardem z a la última posició del vector
	
	@; augmentem el comptador de processos de la cua de ready
	add r5, #1
	str r5, [r4]
	
	@; actualitzem la taula de pcbs
	ldr r9, =_gd_pcbs	@; r9 = direcció base de la taula de pcbs
	mov r10, #24
	mul r10, r8, r10	@; r8: z, r10 = adreça base element taula pcbs
	add r9, r10			@; r9 = direcció base de l'element de la taula de pcbs que volem modificar
	str sp, [r9, #8]	@; desem r11 (sp sistema) al pcb
						@; sp és el tercer camp de l'entrada
	
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
	ldrb r11, [r8, r10]		@; r11 = valor de la posició n + 1 de la cua
	sub r10, r10, #1		@; r10 = n
	strb r11, [r8, r10]		@; desem r11 a la posició n de la cua
	add r10, #2				@; index++
	cmp r10, r5
	blo .for		@; index < n_Ready?
	
	sub r5, #1		@; r5 = nou número de processos en ready
	str r5, [r4]
	
	@; desem el PID i el sòcol a _gd_pidz
	ldr r8, =_gd_pcbs	@; r8 = direcció base taula pcbs
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
	push {lr}
	ldr r0, =_gd_nReady
	ldr r0, [r0]
	add r0, #1
	pop {pc}


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
	
	@; comprovem que el sòcol és correcte i està lliure
	cmp r1, #0		@; si es vol assignar el sòcol 0
	moveq r0, #1	@; retornem error
	beq .fi

	ldr r4, =_gd_pcbs
	mov r5, #24
	mul r6, r1, r5
	add r4, r6		@; r4 = direcció base element a la taula de pcbs
	ldr r5, [r4]	@; r5 = pid
	cmp r5, #0
	movne r0, #1	@; si el sòcol ja està ocupat, retornem error
	bne .fi
	
	@; obtenim un nou pid pel procés
	ldr r5, =_gd_pidCount	@; r5 = direcció pidCount
	ldr r6, [r5]			@; r6 = valor pidCount
	add r6, r6, #1
	str r6, [r5]		@; pidCount++
	str r6, [r4]		@; desem el pid a la taula de pcbs

	@; desem el pc del procés a la taula de pcbs
	add r0, #4			@; r0 = pc
	str r0, [r4, #4]	@; desem el pc a la taula de pcbs
	
	@; desem el keyname a la taula de pcbs
	ldr r0, [r2]	@; primers 4 bytes del nom del procés
	str r0, [r4, #16]	@; desem el keyName
	
	@; calculem l'adreça base de la pila
	mov r7, sp
	ldr r5, =_gd_stacks			@; r5 = adreça base vector piles
	add sp, r5, r1, lsl #9		
	
	@; inicialitzem els registres de la pila
	ldr r5, =_gp_terminarProc	@; r5 = direcció gp_terminarProc
	push {r5}		@; apilem la direcció de terminarProc()
	
	mov r5, #0
	mov r6, #0
	
	.while:
	push {r5}	@; apilem un 0
	add r6, #1	@; augmentem el comptador
	cmp r6, #11	
	bls .while	@; mentre no haguem apilat 12 zeros
	
	push {r3}	@; apilem el paràmetre al top de la pila
	
	@; desem el punter a la pila en el pcb
	str sp, [r4, #8]
	mov sp, r7			@; recuperem el valor original de la pila
	
	@; desem el valor inicial del reg. cpsr
	mov r5, #0x1f		
	str r5, [r4, #12]
	
	@; inicialitzem el camp workTicks del pcb
	mov r5, #0
	str r5, [r4, #20]
	
	@; desem el sòcol a la cua de ready
	ldr r5, =_gd_qReady		@; r5 = adreça base qReady
	ldr r6, =_gd_nReady		@; r6 = adreça base nReady
	ldr r7, [r6]			@; r7 = nReady
	
	strb r1, [r5, r7]		@; desem el sòcol (r1) en la última posició de la cua de ready
	add r7, #1
	str r7, [r6]
	
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
	str r1, [r0]			@; guardar z�calo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = direcci�n base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto
	
.end

