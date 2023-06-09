/*------------------------------------------------------------------------------

	"garlic_tecl.c" : 
	
	contiene las funciones necesarias para la gestión de teclado.
	Inicializar las variables globales, los gráficos, instalar la RSI, etc.

------------------------------------------------------------------------------*/


#include <nds.h>
#include <garlic_system.h>
#define VRAMBASE 0x06201000					//direccion base vram
#define BG3CURSOR (*(u16*)0x06201882)
u16 teclatfg32x7[] = 
{
	0 ,60, 0,17, 0,18, 0,19, 0,20, 0,21, 0,22, 0,23, 0,24, 0,25, 0,16, 0, 7, 0,91, 0,94, 0,60,15, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0 ,32, 0,28, 0,81, 0,87, 0,69, 0,82, 0,84, 0,89, 0,85, 0,73, 0,79, 0,80, 0,59, 0, 0,36,37,44, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0 ,35,33,48,51, 0,65, 0,83, 0,68, 0,70, 0,71, 0,72, 0,74, 0,75, 0,76, 0,13, 0,41,46,52,50,47, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0 ,51,48,33,35,37, 0,90, 0,88, 0,67, 0,86, 0,66, 0,78, 0,77, 0,12, 0,14, 0, 0,28,29, 0,29,30, 0,
};

// 95 = baldosa blanca
u16 teclatbg32x12[] =
{	
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,
	479, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,
	479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,223,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,
	479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,479,223,223,223,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479, 
	479,223,223,223,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,223,223,223,223,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,
	479,223,223,223,223,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,223,479,479,223,223,479,223,223,479,
	479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479,479
};

u16 cabecera32x4[] = {
	41 , 78, 80, 85, 84,  0, 70, 79, 82,  0, 90, 16, 16,  0,  8, 48, 41, 36,  0, 16, 16, 16, 16, 16,  9, 26,  0,  0,  0,  0,  0,  0,
	0  , 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97,  0,
	98 ,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 96,
	0  , 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,  0,
};

u16 teclatCAPSfg32x7[] =
{
	0 ,11, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0,15, 0, 8, 0, 9, 0,29, 0,31, 0,93, 0,92, 0,60,15, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0 ,10, 0,30, 0,49, 0,55, 0,37, 0,50, 0,52, 0,57, 0,53, 0,41, 0,47, 0,48, 0,61, 0, 0,36,37,44, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0 ,35,33,48,51, 0,33, 0,51, 0,36, 0,38, 0,39, 0,40, 0,41, 0,42, 0,43, 0,44, 0,41,46,52,50,47, 0,
	0 , 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0 ,51,48,33,35,37, 0,58, 0,56, 0,35, 0,54, 0,34, 0,46, 0,45, 0,27, 0,26, 0, 0,28,29, 0,29,30, 0,
};

void _gt_initKB()
{	
	int bgTeclat, fgTeclat, cursor;

	bgTeclat = bgInitSub(1, BgType_Text8bpp, BgSize_T_256x256, 1, 1);
	fgTeclat = bgInitSub(2, BgType_Text8bpp, BgSize_T_256x256, 2, 1);	//bgInitSub
	cursor = bgInitSub(3, BgType_Text8bpp, BgSize_T_256x256, 3, 1);
	
	bgSetPriority(bgTeclat, 2);
	bgSetPriority(fgTeclat, 1);
	bgSetPriority(cursor, 0);
	
	_gt_hideKB();
	
	dmaCopy(cabecera32x4, bgGetMapPtr(fgTeclat), sizeof(cabecera32x4));
	dmaCopy(teclatfg32x7, bgGetMapPtr(fgTeclat) + 32 * 4, sizeof(teclatfg32x7));
	dmaCopy(teclatbg32x12, bgGetMapPtr(bgTeclat), sizeof(teclatbg32x12));
	BG3CURSOR = 0x160;				// cursor baldosa en fondo 3
	
	//dmaCopy(cursor1x1, bgGetGfxPtr(cursor), 1);
	
	_gd_zocIAddr = VRAMBASE + 11 * 2;
	// dirInicial + desplaçament lateral
	_gd_strIAddr = VRAMBASE + 2 * 32 * 2 + 2;
	// dirInicial + linies * columnes * hwords + desplaçament lateral
	_gd_curIAddr = VRAMBASE + 2 * 32 * 2 + 2 + 0x800;
	// dirInicial + linies * columnes * hwords + desplaçament lateral + (bg3 - bg2)
	
	return;
}
