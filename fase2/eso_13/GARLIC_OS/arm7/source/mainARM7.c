/*------------------------------------------------------------------------------

	Codigo main para la ARM7
	
------------------------------------------------------------------------------*/
#include <nds.h> 
//#include <stdio.h>
touchPosition position = {0};
extern void _arm7_rsiIPCSync();

/* comprobarPantallaTactil() verifica si se ha pulsado efectivamente la pantalla
   t�ctil con el l�piz, comprobando que est� pulsada durante al menos dos llama-
   das consecutivas a la funci�n y, adem�s, las coordenadas raw sean diferentes
   de 0; en este caso, se fija el par�metro pasado por referencia, touchPos,
   con las coordenadas (x, y) en p�xeles, y la funci�n devuelve cierto. */
bool comprobarPantallaTactil(void)
{
	static bool penDown = false;
	bool lecturaCorrecta = false;

	if (!touchPenDown())
	{
		penDown = false;	// no hay contacto del l�piz con la pantalla
	}
	else		// hay contacto, pero hay que verificarlo
	{
		if (penDown)		// si anteriormente ya estaba en contacto
		{
			touchReadXY(&position);	// leer la posici�n de contacto
			
			if ((position.rawx == 0) || (position.rawy == 0))
			{						// si alguna coordenada no es correcta
				penDown = false;	// anular indicador de contacto
			}
			else
			{
				lecturaCorrecta = true;
			}
		}
		else
		{					// si es la primera detecci�n de contacto
			penDown = true;		// memorizar el estado para la segunda verificaci�n
		}
	}
	return lecturaCorrecta;		
}
/**/

int main(){
	readUserSettings();
	irqInit();
	irqEnable(IRQ_VBLANK);
	// Constants definides a ipc.h
	REG_IPC_FIFO_CR = IPC_FIFO_ENABLE | IPC_FIFO_SEND_CLEAR;
	REG_IPC_SYNC = 0;
	REG_KEYCNT = KEY_TOUCH | (1 << 14);
	REG_IME = IME_ENABLE;
	
	char pitjada = 0;	// Boolea que indica si la pantalla esta o no pitjada
	char old_codigo = 0; // codi de pulsacio anterior
	while(1){
		swiIntrWait(0, IRQ_VBLANK);
		//_gt_waitForVBlank();
		if(comprobarPantallaTactil()){
			if(!pitjada){	// Si no est� pitjada actualment
				// coordenades = xxxxxxxxxxxxxxxxyyyyyyyyyyyyyyyy
				int coordenades = position.px << 16 | position.py;
				REG_IPC_FIFO_TX = coordenades;
				REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE;
				pitjada = 1;	// Est� pitjada actualment
			}
		}else if (pitjada){
			REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE | IPC_SYNC_IRQ_REQUEST;		
				// saltar la interrupcio ja que s'ha deixat de pitjar
			pitjada = 0;
		}		
		char codigo = REG_KEYXY & 3;	//0 pressed 1 released
		codigo ^= 3;	//0 released 1 presed
		//https://problemkaputt.de/gbatek.htm#dskeypad
		if(codigo != old_codigo){
			old_codigo = codigo;
			// escriure codi XY sense saltar la SYNC del arm9
			// quan calgui el proces llegira el camp
			REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE | (codigo << 8);
		}
	}
}
