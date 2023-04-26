@;==============================================================================
@;
@;	"garlic_dtcm.s":	zona de datos b�sicos del sistema GARLIC 1.0
@;						(ver "garlic_system.h" para descripci�n de variables)
@;
@;==============================================================================

.section .dtcm,"wa",%progbits

	.align 2

	.global _gd_pidz			@; Identificador de proceso + z�calo actual
_gd_pidz:		.word 0x00

	.global _gd_pidCount		@; Contador global de PIDs
_gd_pidCount:	.word 0

	.global _gd_tickCount		@; Contador global de tics
_gd_tickCount:	.word 0

	.global _gd_seed			@; Semilla para generaci�n de n�meros aleatorios
_gd_seed:		.word 0xFFFFFFFF

	.global _gd_nReady			@; N�mero de procesos en la cola de READY
_gd_nReady:		.word 0

	.global _gd_qReady			@; Cola de READY (procesos preparados)
_gd_qReady:		.space 16

	.global _gd_pcbs			@; Vector de PCBs de los procesos activos
_gd_pcbs:		.space 16 * 6 * 4

	.global _gd_wbfs			@; Vector de WBUFs de las ventanas disponibles
_gd_wbfs:		.space 4 * (4 + 32)

	.global _gd_stacks			@; Vector de pilas de los procesos activos
_gd_stacks:		.space 15 * 128 * 4


@; Variables ProgT

	.global _gd_string			@; Cadena de caracteres del teclado 0x0b00 2034
_gd_string: 	.space 30
	
	.global _gd_index			@; Posicion del teclado
_gd_index:		.byte 0
	
	.global _gd_nkbwait			@; Numero de procesos en la cola de kbwait, podria ser un byte
_gd_nkbwait:	.byte 0

	.global _gd_maxIndex		@; Cada proceso puede tener un maxIndex distinto
_gd_maxIndex: 	.space 16	
	
	.global _gd_kbwait			@; Cola de procesos que esperan entrada de un string por teclado
_gd_kbwait: 	.space 16		@; 0x0B00_2064
	
	.align 2
	.global _gd_zocIAddr			@; zocalo Inicial adress
_gd_zocIAddr:	.word 0				@; 0x6200096
	
	.global _gd_strIAddr			@; string Inicial Adress
_gd_strIAddr:	.word 0				@; 0x62000C2		

	.global _gd_curIAddr			@; cursor Inicial Adr
_gd_curIAddr:	.word 0				@; 0x6200182
	
	.align 1
	.global _gd_kbsignal
_gd_kbsignal:	.hword 0
	


.end

