/*------------------------------------------------------------------------------

	"main.c" : fase 1 / programador G, P, T y M
				ivan.cardona@estudiants.urv.cat
				mireia.gasco@estudiants.urv.cat
				matiasariel.larrosa@estudiants.urv.cat
				ainhoa.garcial@estudiants.urv.cat
	Programa de prueba de llamada de funciones gr�ficas de GARLIC 1.0.

------------------------------------------------------------------------------*/
#include <nds.h>
#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <GARLIC_API.h>		// inclusi�n del API para simular un proceso

extern int * punixTime;		// puntero a zona de memoria con el tiempo real

extern int cvocals(int);	// procesos de teclado
extern int capgirar(int);

extern void _gt_initKB();	// inicialitzacions del teclat
extern void _gt_rsiTimer3(); // Parpadeig del cursor
extern void _gt_rsiTimer2(); // Autorepeat rapid
extern void _gt_rsiTimer1(); // Autorepeat lent
extern void _gt_rsiKEYS();	// Primera pulsacio de tecla

/* Inicializaciones generales del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	
	_gg_iniGrafA();			// inicializar procesador gr�fico A
	for (int v = 0; v < 4; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana

	_gt_initKB();
	
	_gd_seed = *punixTime;	// inicializar semilla para n�meros aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits
	
	REG_KEYCNT = KEY_LEFT | KEY_RIGHT | KEY_A | 
					KEY_B | KEY_SELECT | KEY_START;
	
	irqInitHandler(_gp_IntrMain);	// instalar rutina principal interrupciones
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instalar RSI de vertical Blank
	irqSet(IRQ_TIMER1, _gt_rsiTimer1);	// instalar RSI del Timer1
	irqSet(IRQ_TIMER2, _gt_rsiTimer2);	// instalar RSI del Timer2
	irqSet(IRQ_TIMER3, _gt_rsiTimer3);	// instalar RSI del Timer3
	irqSet(IRQ_KEYS, _gt_rsiKEYS);
	irqEnable(IRQ_VBLANK | IRQ_KEYS | IRQ_TIMER1 | IRQ_TIMER2 | IRQ_TIMER3);			
		// activar interrupciones de vertical Blank, del teclat i dels timers
	REG_IME = IME_ENABLE;			// activar las interrupciones en general
	
	TIMER1_DATA = 0;				// 2 hz
	TIMER1_CR = 0x42;				// TIMER_IRQ_ENABLE | F/256
	TIMER2_DATA = 0;				// 8hz
	TIMER2_CR = 0x41;				// TIMER_IRQ_ENABLE | F/64
	TIMER3_DATA = 0;				// 2hz
	TIMER3_CR = 0x42;				// TIMER_IRQ_ENABLE | F/256

	_gd_pcbs[0].keyName = 0x4C524147;	// "GARL"

	if (!_gm_initFS()) {
		GARLIC_printf("ERROR: �no se puede inicializar el sistema de ficheros!");
		exit(0);
	}
}

//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------
	
	inicializarSistema();
	
	GARLIC_printf("********************************");
	GARLIC_printf("*                              *");
	GARLIC_printf("* Sistema Operativo GARLIC 1.0 *");
	GARLIC_printf("*                              *");
	GARLIC_printf("********************************");
	GARLIC_printf("*** Inicio fase 1_G+P+T+M\n");
	
	int z1 = 13, z2 = 14, z3 = 7;		//zocalos
	int arg1 = 3, arg2 = 2, arg3 = 1;	//Arguments per defecte
	char in[2];
	char checkProcess = 0;				//Variable per comprobar el acabament
										//de 2 procesos
	intFunc start;
	
	GARLIC_printf("\nIntroduce un num [0,3] (dotp)\n");
	GARLIC_getstring(in, 1);		// pedir arg por teclado
	if (in[0] - '0' >= 0 && in[0] - '0' <= 3){
		arg1 = in[0] - '0';
		GARLIC_printf("Utilitzant arg '%d'\n", arg1);
	}else GARLIC_printf("Utilitzant valor per defecte %d\n", arg1);
	
	GARLIC_printf("\nIntroduce un num [0,3] (cdis)\n");
	GARLIC_getstring(in, 1);		// pedir arg por teclado
	if (in[0] - '0' >= 0 && in[0] - '0' <= 3){
		arg2 = in[0] - '0';
		GARLIC_printf("Utilitzant arg '%d'\n", arg2);
	}else GARLIC_printf("Utilitzant valor per defecte %d\n", arg2);
	
	GARLIC_printf("\nIntroduce un num [0,3] (perf)\n");
	GARLIC_getstring(in, 1);		// pedir arg por teclado
	if (in[0] - '0' >= 0 && in[0] - '0' <= 3){
		arg3 = in[0] - '0';
		GARLIC_printf("Utilitzant arg '%d'\n", arg3);
	}else GARLIC_printf("Utilitzant valor per defecte %d\n", arg3);
	
	GARLIC_printf("\nargs = [%d, %d", arg1, arg2);
	GARLIC_printf(", %d], creant procesos...\n\n", arg3);
	
	start = _gm_cargarPrograma("DOTP");
	if(!start){
		GARLIC_printf("DOTP no se ha cargado.\n");
	}else
		_gp_crearProc(start, z1, "DOTP", arg1);
	
	start = _gm_cargarPrograma("CDIS");
	if(!start){
		GARLIC_printf("CDIS no se ha cargado.\n");
	}else
		_gp_crearProc(start, z2, "CDIS", arg2);
	
	start = _gm_cargarPrograma("PERF");
	if(!start){
		GARLIC_printf("PERF no se ha cargado.\n");
	}else
		_gp_crearProc(start, z3, "PERF", arg3);
	
	while (_gp_numProc() > 1) {
		_gp_WaitForVBlank();
		if(!_gd_pcbs[z1].PID && !(checkProcess & 0x1)){
			GARLIC_printf("Creant proces capgirar...\n");
			_gp_crearProc(capgirar, z1, "CAPG", 1);
			checkProcess |= 0x1; // primer bit
		}
		if(!_gd_pcbs[z2].PID && !(checkProcess & 0x2)){
			GARLIC_printf("Creant proces contar vocals...\n");
			_gp_crearProc(cvocals, z2, "CVOCA", 1);
			checkProcess |= 0x2; // segon bit
		}
		if(!_gd_pcbs[z3].PID && !(checkProcess & 0x4)){
			GARLIC_printf("\nIntroduce un num [0,3] (dpas)\n");
			GARLIC_getstring(in, 1);		// pedir arg por teclado
			if (in[0] - '0' >= 0 && in[0] - '0' <= 3)
				arg3 = in[0] - '0';
			GARLIC_printf("Utilitzant valor %d\n", arg3);
			
			GARLIC_printf("Creant proces diumenge pascua...\n");
			
			start = _gm_cargarPrograma("DPAS");
			if(!start){
				GARLIC_printf("DPAS no se ha cargado.\n");
			}else 
				_gp_crearProc(start, z3, "DPAS", arg3);
			checkProcess |= 0x4; // tercer bit
		}
	}						// esperar a que terminen los procesos de usuario
	
	GARLIC_printf("\nNo queden procesos, ticks: %d\n", _gd_tickCount);
	GARLIC_printf("*** Final fase 1_G+P+T+M\n");

	while (1) {
		_gp_WaitForVBlank();
	}							// parar el procesador en un bucle infinito
	return 0;
}