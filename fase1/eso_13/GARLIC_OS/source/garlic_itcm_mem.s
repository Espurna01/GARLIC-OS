@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	codigo de rutinas de soporte a la carga de
@;							programas en memoria (version 1.0)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gm_reubicar
	@; rutina para interpretar los 'relocs' de un fichero ELF y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, restando la direccion de inicio de segmento y sumando
	@; la direccion de destino en la memoria;
	@; Parametros:
	@; R0: direccion inicial del buffer de fichero (char *fileBuf)
	@; R1: direccion de inicio de segmento (unsigned int pAddr)
	@; R2: direccion de destino en la memoria (unsigned int *dest)
	@; Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
	push {r0-r12, lr}
	ldr r4, [r0, #32]		@; Offset de la primera tabla: e_shoff = 16 char* de e_ident + 2 half + 3 word = 16 + 2*2 + 3*4 = 32 bytes
	ldrh r5, [r0, #48]		@; Cantidad de tablas : e_shnum = 16 char* de e_ident + 6 half + 5 word = 16 + 6*2 + 5*4 = 48 bytes 
	ldrh r12, [r0, #46]		@; Valor para calcular offset de la siguiente tabla de seciones
	sub r2, r1				
	add r4, r0				@; Sumo el offset al fichero ELF de la tabla de secciones
.LforBuscarSecciones:
	ldr r6, [r4, #4]		@; e_shoff + ELF + #4 --> sh_type 
	cmp r6, #9				@; Comparo que sean del tipo SHT_REL
	bne .LCodeNoReloc
	@; .LCodigoSeccion:
	ldr r7, [r4, #16]		@; 4*4 word --> sh_offset offset del segmento
	ldr r8, [r4, #20]		@; 4*5 word --> sh_size tamany de la seccion
	ldr r9, [r4, #36]		@; 4*9 word --> sh_entsize tamany en bytes de cada reubicador
	add r7, r0				@; Añado a r7 el offset de los reubicadores
.LforBuscarReubicadores:
	ldr r10, [r7, #4]		@; Obtengo el offset de los reuicadores --> r_offset
	and r10, #0b11111111	@; Cogemos el codigo numeric de los 8 bits bajos 
	cmp r10, #2				@; Comparamos con el tipo R_ARM_ABS32 (tipo 2)
	bne .LCodeNoReubic
	@; .LHacerReubcicacion:
	ldr r10, [r7]
	add r10, r2
	ldr r1, [r10]
	add r1, r2			
	str r1, [r10]			@; guardamos el reubicador
.LCodeNoReubic:
	sub r8, r9				@; Quitamos el reloc de la seccion
	add r7, r9				@; offset del siguiente reloc es: offset actual + tamaño de reloc
	cmp r8, #0				@; Comparar que no sea el ultimo
	bne .LforBuscarReubicadores
.LCodeNoReloc:
	sub r5, #1				@; Descontamos una entrada (la tratamos) al contador de entradas
	add r4, r12				@; Offset + tamaño de tabla de reub
	cmp r5, #0				@; header-> e_phnum: Comprobamos que hay alguna entrada en la tabla de segmentos
	bne .LforBuscarSecciones
	
	pop {r0-r12, pc}
	
.end
