/*------------------------------------------------------------------------------

	"main.c" : fase 2 / programador G, P, T
				ivan.cardona@estudiants.urv.cat
				mireia.gasco@estudiants.urv.cat
				matiasariel.larrosa@estudiants.urv.cat
	Programa de prueba de llamada de funciones gr�ficas de GARLIC 2.0.

------------------------------------------------------------------------------*/
#include <nds.h>
#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <GARLIC_API.h>		// inclusi�n del API para simular un proceso
#define NUM_PROGS 13		// programes carregats
extern int * punixTime;		// puntero a zona de memoria con el tiempo real

extern int dotp(int);		// programa de usuario progG
extern int cdis(int);		// programa de usuario progP
extern int perf(int);		// programa de usuario progT
extern int cron(int); 		
extern int borrar(int);	
extern int desc(int);
extern int dpas(int);
extern int hola(int);
extern int labe(int);
extern int pong(int);
extern int prnt(int);

extern int cvocals(int);	// procesos de teclado
extern int capgirar(int);

extern void _gt_initKB();	// inicialitzacions del teclat
extern void _gt_rsiFifoNotEmpty();
extern void _gt_rsiIPCSync();
extern void _gt_timer3();
 
extern void _ga_printf(char *str, ...);
extern int _ga_getstring(char *str, int max_char);
extern void _ga_delay(int nsec);

int coordenades = 0;
char mensajeRecibido = 1;
int baldosaOff = -1;
const short divFreq0 = -33513982/1024;		// frecuencia de TIMER0 = 1 Hz
const short divFreq1 = -33513982/(1024*7);	// frecuencia de TIMER1 = 7 Hz
const short divFreq2 = -33513982/(1024*4);	// frecuencia de TIMER2 = 4 Hz

const char *argumentosDisponibles[4] = { "0", "1", "2", "3"};
		// se supone que estos programas est?n disponibles en el directorio
		// "Programas" de las estructura de ficheros de Nitrofiles
		
const char *progs[NUM_PROGS] = {"BORR","CDIS","CRON","DESC","DOTP","DPAS","HOLA","LABE","PERF","PONG","PRNT"
								,"CAPG","CVOC"};
const intFunc dir[NUM_PROGS] = {borrar, cdis, cron, desc, dotp, dpas, hola, labe, perf, pong, prnt, capgirar, cvocals};

/* Funci?n para presentar una lista de opciones y escoger una: devuelve el ?ndice de la opci?n
		(0: primera opci?n, 1: segunda opci?n, etc.)
		ATENCI?N: para que pueda funcionar correctamente, se supone que no habr? desplazamiento
				  de las l?neas de la ventana. */
int escogerOpcion(char *opciones[], int num_opciones)
{
	int fil_ini, j, sel, k;
	
	fil_ini = _gd_wbfs[_gi_za].pControl >> 16;		// fil_ini es ?ndice fila inicial
	for (j = 0; j < num_opciones; j++)			// mostrar opciones
		_gg_escribir("%1( ) %s\n", (unsigned int) opciones[j], 0, _gi_za);

	sel = -1;									// marca de no selecci?n
	j = 0;										// j es preselecci?n
	_gg_escribirCar(1, fil_ini, 10, 2, _gi_za);	// marcar preselecci?n
	do
	{
		_gp_WaitForVBlank();
		scanKeys();
		k = keysDown();				// leer botones
		if (k != 0)
			switch (k)
			{
				case KEY_UP:
						if (j > 0)
						{	_gg_escribirCar(1, fil_ini+j, 0, 2, _gi_za);
							j--;
							_gg_escribirCar(1, fil_ini+j, 10, 2, _gi_za);
						}
						break;
				case KEY_DOWN:
						if (j < num_opciones-1)
						{	_gg_escribirCar(1, fil_ini+j, 0, 2, _gi_za);
							j++;
							_gg_escribirCar(1, fil_ini+j, 10, 2, _gi_za);
						}
						break;
				case KEY_START:
						sel = j;			// escoger preselecci?n
						break;
			}
	} while (sel == -1);
	return sel;
}

/* Funci�n para gestionar los sincronismos  */
void gestionSincronismos()
{
	int i, mask;
	
	if (_gd_sincMain & 0xFFFE)		// si hay algun sincronismo pendiente
	{
		mask = 2;
		for (i = 1; i <= 15; i++)
		{
			if (_gd_sincMain & mask)
			{	// liberar la memoria del proceso terminado
				_gm_liberarMem(i);
				_gg_escribirLineaTabla(i, (i == _gi_za ? 2 : 3));
				_gg_escribir("%0* %d: proceso terminado\n", i, 0, 0);
				_gd_sincMain &= ~mask;		// poner bit a cero
			}
			mask <<= 1;
		}
	}
}

/* Funci?n para permitir seleccionar un programa entre los ficheros ELF
		disponibles, as? como un argumento para el programa (0, 1, 2 o 3) */
void seleccionarPrograma()
{
	int ind_prog, argumento;
	int zoc = _gi_za; 
	
	
	if(_gd_pcbs[zoc].PID != 0){
		_gp_matarProc(zoc);
		_gg_escribir("%3* %d: proceso destruido\n", _gd_pcbs[zoc].PID, 0, 0);
		_gg_escribirLineaTabla(zoc, 2);
	}
	 
	_gs_borrarVentana(zoc, 1);
	_gg_escribir("%1*** Seleccionar programa :\n", 0, 0, zoc);
	ind_prog = escogerOpcion((char **) progs, NUM_PROGS);
	_gg_escribir("%1*** Seleccionar argumento :\n", 0, 0, zoc);
	argumento = escogerOpcion((char **) argumentosDisponibles, 4);

	_gp_crearProc(dir[ind_prog], zoc, (char *) progs[ind_prog], argumento);
	_gg_escribir("%2* %d:%s.elf", zoc, (unsigned int) progs[ind_prog], 0);
	_gg_escribir(" (%d)\n", argumento, 0, 0);
	_gg_escribirLineaTabla(zoc, 2);
	
}

/* Inicializaciones generales del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	
	_gg_iniGrafA();			// inicializar procesador gr�fico A
	_gs_iniGrafB();
	
	_gd_pcbs[0].keyName = 0x4C524147;	// "GARL"
	
	_gs_dibujarTabla();
	
	_gi_redibujarZocalo(1);			// marca tabla de z?calos con el proceso
									// del S.O. seleccionado (en verde)
	
	for (int v = 0; v < 4; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana

	_gt_initKB();
	
	_gd_seed = *punixTime;	// inicializar semilla para n�meros aleatorios con
	_gd_seed = (_gd_seed << 16) + 18;		// el valor de tiempo real UNIX, desplazado 16 bits
	
	irqInitHandler(_gp_IntrMain);	// instalar rutina principal interrupciones
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instalar RSI de vertical Blank
	irqSet(IRQ_FIFO_NOT_EMPTY, _gt_rsiFifoNotEmpty);
	irqSet(IRQ_IPC_SYNC, _gt_rsiIPCSync);
	irqSet(IRQ_TIMER0, _gp_rsiTIMER0); 	// actualiza porcentaje uso
	irqSet(IRQ_TIMER1, _gm_rsiTIMER1); 	// actualiza estado de procesos
	irqSet(IRQ_TIMER2, _gg_rsiTIMER2);	// actualiza columna PC
	irqSet(IRQ_TIMER3, _gt_timer3);		// parpadeo cursor
	irqSet(IRQ_VCOUNT, _gi_movimientoVentanas); //movimiento de Ventanas
	REG_DISPSTAT |= 0xE620;			// fijar linea VCOUNT a 230 y activar int.
	irqEnable(IRQ_VBLANK | IRQ_IPC_SYNC | IRQ_FIFO_NOT_EMPTY | IRQ_TIMER0
		| IRQ_TIMER2 | IRQ_TIMER3 | IRQ_VCOUNT);

	TIMER0_DATA = divFreq0; 
	TIMER0_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	TIMER1_DATA = divFreq1; 
	TIMER1_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)	
	TIMER2_DATA = divFreq2; 
	TIMER2_CR = 0xC3;  		// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	TIMER3_DATA = 0;	// 2hz
	TIMER3_CR = 0x42;	// Timer IRQ ENABLE | F/256
	
	REG_IPC_FIFO_CR = IPC_FIFO_RECV_IRQ; //IPC_FIFO_ENABLE se activa al llamar
										 //a _gt_getstring
	REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE;
	REG_IME = IME_ENABLE;
	
	if (!_gm_initFS()) {
		_ga_printf("ERROR: �no se puede inicializar el sistema de ficheros!\n");
		exit(0);
	}
}

//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------
	int key;

	inicializarSistema();
	
	_gg_escribir("%1********************************", 0, 0, 0);
	_gg_escribir("%1*                              *", 0, 0, 0);
	_gg_escribir("%1* Sistema Operativo GARLIC 2.0 *", 0, 0, 0);
	_gg_escribir("%1*                              *", 0, 0, 0);
	_gg_escribir("%1********************************", 0, 0, 0);
	_gg_escribir("%1*** Inicio fase 2_T+P+G\n", 0, 0, 0);
	
	
	while (1)						// bucle infinito
	{
		scanKeys();
		key = keysDown();			// leer botones y controlar la interfaz
		if (key != 0)				// de usuario
		{	_gi_controlInterfaz(key);
			if ((key == KEY_START) && (_gi_za != 0))
				seleccionarPrograma();
		}
		gestionSincronismos();
		_gp_WaitForVBlank();		// retardo del proceso de sistema
	}
	return 0;		
}
