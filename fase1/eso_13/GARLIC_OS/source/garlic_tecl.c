
/*------------------------------------------------------------------------------

	"garlic_tecl.c" : 
	
	contiene las funciones necesarias para la gestión de teclado.
	Inicializar las variables globales, los gráficos, instalar la RSI, etc.

------------------------------------------------------------------------------*/


#include <nds.h>
#include "garlic_font.h"
#include "garlic_system.h"

#define SEPARACIO_INICIAL 2					//n linies
#define VRAMBASE 0x06200000					//direccion base vram

u16 teclat32x8[] = 
{
	41,78,80,85,84, 0,70,79,82, 0,90,16,16, 0, 8,48,41,36, 0,16,16,16,16,16, 9,26, 0, 0, 0, 0, 0, 0,
	0 ,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97,97, 0,
	98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,96,
	98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,96,
	98,13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,96,
	0 ,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99, 0,
	0 , 7,33,15,34, 7,26,67,65,82,65,67,84,69,82, 0, 0, 7,28,15,30, 7,26,80,79,83,73,67,73,79,78, 0,
	0 , 7,51,37,44,37,35,52, 7,26,66,79,82,82,65, 0, 0, 7,51,52,33,50,52, 7,26,82,69,84,85,82,78, 0
};



void _gt_initKB()
{	
	int bgTeclat;
	
	videoSetModeSub(MODE_0_2D);					//videoSetModeSub
	vramSetBankC(VRAM_C_SUB_BG_0x06200000);		//VRAM_C_SUB_BG_0x06200000
	
	bgTeclat = bgInitSub(1, BgType_Text8bpp, BgSize_T_256x256, 0, 1);	//bgInitSub
	
	bgSetPriority(bgTeclat, 0);
	bgHide(bgTeclat);
	
	dmaCopy(teclat32x8, bgGetMapPtr(bgTeclat) + SEPARACIO_INICIAL * 32, sizeof(teclat32x8));
	decompress(garlic_fontTiles, bgGetGfxPtr(bgTeclat), LZ77Vram);
	dmaCopy(garlic_fontPal, BG_PALETTE_SUB, sizeof(garlic_fontPal));		//BG_PALETTE_SUB
	
	_gd_zocIAddr = VRAMBASE + SEPARACIO_INICIAL * 32 * 2 + 22;
	// dirInicial + linies * columnes * hwords + desplaçament lateral
	_gd_strIAddr = VRAMBASE + (SEPARACIO_INICIAL + 3) * 32 * 2 + 2;
	// dirInicial + linies * columnes * hwords + liniesExtra * columnes * hwords + desplaçament lateral
	_gd_curIAddr = VRAMBASE + (SEPARACIO_INICIAL + 4) * 32 * 2 + 2;
	// dirInicial + linies * columnes * hwords + liniesExtra * columnes * hwords + desplaçament lateral
	
	return;
}