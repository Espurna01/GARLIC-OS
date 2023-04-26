@;==============================================================================
@;
@;	"garlic_dtcm.s":	zona de datos básicos del sistema GARLIC 2.0
@;						(ver "garlic_system.h" para descripción de variables)
@;
@;==============================================================================

.section .dtcm,"wa",%progbits

	.align 2

	.global _gd_pidz			@; Identificador de proceso + zócalo actual
_gd_pidz:		.word 0

	.global _gd_pidCount		@; Contador global de PIDs
_gd_pidCount:	.word 0

	.global _gd_tickCount		@; Contador global de tics
_gd_tickCount:	.word 0

	.global _gd_sincMain		@; Sincronismos con programa principal
_gd_sincMain:	.word 0

	.global _gd_seed			@; Semilla para generación de números aleatorios
_gd_seed:		.word 0xFFFFFFFF

	.global _gd_nReady			@; Número de procesos en la cola de READY
_gd_nReady:		.word 0

	.global _gd_qReady			@; Cola de READY (procesos preparados)
_gd_qReady:		.space 16

	.global _gd_nDelay			@; Número de procesos en la cola de DELAY
_gd_nDelay:	.word 0

	.global _gd_qDelay			@; Cola de DELAY (procesos retardados)
_gd_qDelay:	.space 16 * 4

	.global _gd_pcbs			@; Vector de PCBs de los procesos activos
_gd_pcbs:		.space 16 * 6 * 4

	.global _gd_wbfs			@; Vector de WBUFs de las ventanas disponibles
_gd_wbfs:	.space 16 * (4 + 64)

	.global _gd_stacks			@; Vector de pilas de los procesos activos
_gd_stacks:		.space 15 * 128 * 4


@; Variables ProgP

	.global _gd_residu			@; variable pel resultat del residu
_gd_residu:	.word 0
 
	.global _gd_percentatge		@; percentatge d'us de la CPU (string)
_gd_percentatge:	.space 4
	
@; Variables ProgT

	.global _gd_maxIndex		@; Cada proceso puede tener un maxIndex distinto
_gd_maxIndex: 	.space 16	
	
	.global _gd_qKbwait			@; Cola de procesos que esperan entrada de un string por teclado
_gd_qKbwait: 	.space 16		@; 0x0B00_2064
	
	.align 2
	.global _gd_zocIAddr			@; zocalo Inicial adress
_gd_zocIAddr:	.word 0				@; 0x6200096
	
	.global _gd_strIAddr			@; string Inicial Adress
_gd_strIAddr:	.word 0				@; 0x62000C2		

	.global _gd_curIAddr			@; cursor Inicial Adr
_gd_curIAddr:	.word 0				@; 0x6200182
	
	.global _gd_keyboardState	@; Estat del teclat (bit0:0 dalt, bit0:1 baix)
_gd_keyboardState:	.byte 0		@; bit1: 0 minus, 1 majus. &(0x0B002458)

	.global _gd_index			@; Posicion del teclado
_gd_index:		.byte 0
	
	.global _gd_nKbwait			@; Numero de procesos en la cola de kbwait, podria ser un byte
_gd_nKbwait:	.byte 0

@; progM

	.global _gm_first_mem_pos	@; posición de memoria inicial donde cargar los programas 
_gm_first_mem_pos: .word 0x01002000 


.end
