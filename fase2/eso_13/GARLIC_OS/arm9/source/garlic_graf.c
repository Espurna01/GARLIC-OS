/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 2 / programador G
					ivan.cardona@estudiants.urv.cat

	Funciones de gesti�n de las ventanas de texto (gr�ficos), para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <garlic_font.h>	// definici�n gr�fica de caracteres

/* definiciones para realizar c�lculos relativos a la posici�n de los 
caracteres dentro de las ventanas gr�ficas, que pueden ser 4 o 16 */
#define NVENT	16			// n�mero de ventanas totales
#define PPART 	4			// n�mero de ventanas horizontales o verticales
									// (particiones de pantalla)
#define VCOLS 	32			// columnas de cualquier ventana
#define VFILS 	24			// filas de cualquier ventana
#define PCOLS 	VCOLS * PPART	// n�mero de columnas totales
#define PFILS	VFILS * PPART	// n�ermo de filas totales

int bg2A, bg3A;
int bg2Amap;
u16 * mapPtr;

const unsigned int char_colors[] = {240, 96, 64};	// amarillo, verde, rojo
const char espaisblanc[] = "    ";
const char blancosPC[] = "        ";

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por par�metro*/
void _gg_generarMarco(int v, int color)
{
	// mapPtr = mapa base de bg3A + desplazamiento de filas
	mapPtr = bgGetMapPtr(bg3A) + (((v) / PPART) * VFILS * PCOLS);
	
	// si la ventana es impar, desplazaremos segun las columnas
	if (v % PPART != 0){
		mapPtr = mapPtr + VCOLS * (v % PPART);
	}
	
	// tendremos que sumar el indice de la baldosa al color correspondiente
	int iColor = color * 128;
	
	// IMPRESI�N DEL MARCO
	
	// esquina superior izquierda
	mapPtr[0] = 103 + iColor;
	
	// esquina inferior izquierda
	mapPtr[(VFILS-1) * PCOLS] = 100 + iColor;
	
	// esquina superior derecha
	mapPtr[VCOLS-1] = 102 + iColor;
	
	// esquina inferior derecha
	mapPtr[(VFILS-1) * PCOLS + (VCOLS-1)] = 101 + iColor;
	
	// laterales superior e inferior
	for (int i = 1; i < VCOLS-1; i++)
	{
		mapPtr[i] = 99 + iColor;	 					// superior
		mapPtr[(VFILS-1) * PCOLS + i] = 97 + iColor;	// inferior
	}
	
	// laterales izquierdo y derecho
	for (int i = 1; i < VFILS-1; i++)
	{
		mapPtr[i * PCOLS] = 96 + iColor;					// izquierdo
		mapPtr[i * PCOLS + (VCOLS-1)] = 98 + iColor;		// derecho
	}
	
}


/* _gg_iniGraf: inicializa el procesador gr�fico A para GARLIC 2.0 */
void _gg_iniGrafA()
{
	videoSetMode(MODE_5_2D); // inicializamos procesador gr�fico principal en modo 5
	lcdMainOnTop(); // salida en la pantalla superior
	
	vramSetBankA(VRAM_A_MAIN_BG); // reservamos el banco de memoria de video A
	
	bg2Amap = (int)bgGetMapPtr(bg2A); // mapa que usaremos en las rutinas auxiliares
	
	/* bgInit(int layer, BgType type, BgSize size, int mapBase, int tileBase)
			Inicializamos fondo gr�fico 2 en modo Extended Rotation,
			con un tama�o total de 1024x1024 p�xeles.
			mapBase1 = 0 --> 0600 0000 (Virtual VRAM procesador gr�fico principal)
			tileBase = 4 --> 0601 0000 (Virutal VRAM procesador gr�fico principal)
	*/
	/* Hemos de tener en cuenta el tama�o que ocupar� cada mapa
		Tama�o = n� posiciones * bytes/posicion = 128*128 posiciones * 2 bytes/posicion = 32KB
		Por lo tanto, ser� necesaria una separaci�n de 16 en el mapBase
	*/
	bg2A = bgInit(2, BgType_ExRotation, BgSize_ER_1024x1024, 0, 4);
	bgSetPriority(bg2A, 1); // fijamos el fondo 2 con segunda prioridad
	
	// Fondo gr�fico 3
	bg3A = bgInit(3, BgType_ExRotation, BgSize_ER_1024x1024, 16, 4);
	bgSetPriority(bg3A, 0); // fijamos el fondo 3 con primera prioridad
	
	/* decompress (const void *data, void *dst, DecompressType type)
			Descomprimimos el contenido de la fuente de letras
			sobre  la zona de memoria de video del fondo 3
	*/
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3A), LZ77Vram);
	
	/* dmaCopy (const void *source, void *dest, uint32 size)
	Copiamos la paleta de colores sobre la "background palette memory"
	*/
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal)); 
	
	/* 
		Tama�o de cada baldosa o "tile" --> 8*8 p�xeles, 8 bits/pixel --> 64B/baldosa 
		Tama�o total baldosas --> 64B/baldosa * 128 baldosas = 8192B
		Como cargamos halfwords, los pixeles los trataremos de 2 en 2
		--> Total posiciones a recorrer = 8192 / 2 = 4096
	*/
	int totalPos = 4096;
	int numColors = 3;
	
	u16* base = bgGetGfxPtr(bg3A);
	
	for(int colors = 0; colors < numColors; colors++)
	{
		for(int i = 0; i < totalPos; i++)
		{
			// si primer pixel de color blanco
			if (base[i] == 0x00FF) base[i + totalPos*(colors+1)] = char_colors[colors];
			// si segundo pixel de color blanco
			else if (base[i] == 0xFF00) base[i + totalPos*(colors+1)] = char_colors[colors] << 8;
			// si ambos pixeles de color blanco
			else if (base[i] == 0xFFFF) base[i + totalPos*(colors+1)] = char_colors[colors] + (char_colors[colors] << 8);
		}
	}

	// generamos los marcos de las ventanas de texto en el fondo 3
	for (int i = 0; i < NVENT; i++)
	{
		_gg_generarMarco(i, 3);
	}
	
	// escalamos los fondos 2 y 3 para que se ajusten a las dimensiones de la pantalla NDS
	// zoom inicial 1/4
	bgSetScale(bg2A, 512, 512);
	bgSetScale(bg3A, 512, 512);
	bgUpdate();
	
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los c�digos de formato
					  precedidos por '%' e inserta la representaci�n ASCII de
					  los valores indicados por par�metro.
	Par�metros:
		formato	->	string con c�digos de formato (ver descripci�n _gg_escribir);
		val1, val2	->	valores a transcribir, sean n�mero de c�digo ASCII (%c),
					un n�mero natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observaci�n:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripci�n a c�digo ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{
	char caracter;
	int i = 0; 		// contador del string de formato entrante
	int r = 0; 		// contador string resultante
	int s = 0;		// contador que usaremos para los string de los valores
	int vals = 0; 	// contador de valores tratados
	char valor[11]; // tabla donde guardaremos los d�gitos de los n�meros
					// 11 posiciones porque 2^32bits = 4294967296 + centinela
	caracter = formato[i];
	char *codi;
	
	while (caracter != '\0') 	// mientras no sea el final del string de formato
	{
		if ((caracter == '%')  && (formato[i+1] < 48 || formato[i+1] > 51))	// si encontramos un c�digo de formato y no se trata de un color
		{
			i++; // pasamos a leer la marca de formato
			caracter = formato[i];
			
			if ((caracter == 's') && (vals < 2))
			{
				s = 0;	// contador del string de marca de formato
				
				codi = (char *)(vals == 0 ? val1 : val2);
				// recorremos el string representado por el c�digo de formato y lo copiamos en resultado
				while(codi[s] != '\0') 
				{
					resultado[r] = codi[s];
					s++;
					r++;
				}
				vals++;
				i++;
			}
			
			else if ((caracter == 'c') && (vals < 2))
			{
				resultado[r] = (char) (vals == 0 ? val1 : val2);
				vals++;
				r++;
				i++;
			}
			
			else if (caracter == '%')
			{
				resultado[r] = '%';
				r++;
				i++;
			}
			
			else if ((caracter == 'd' || caracter == 'x') && (vals < 2))
			{
				if ((caracter == 'd'))
				{
					// guardamos en "valor" la representaci�n en decimal del n�mero
					if (vals == 0)
						_gs_num2str_dec(valor, sizeof(valor), val1);
					else 
						_gs_num2str_dec(valor, sizeof(valor), val2);
				}
				else
				{
					// guardamos en "valor" la representaci�n en hexadecimal del n�mero
					if (vals == 0)
						_gs_num2str_hex(valor, sizeof(valor), val1);
					else 
						_gs_num2str_hex(valor, sizeof(valor), val2);
				}
				vals++;
				
				s = 0;
				while(valor[s] != '\0')
				{
					if(valor[s] != ' ') // evitamos espacios en blanco
					{
						// copiamos el string obtenido en resultado
						resultado[r] = valor[s];
						r++;
					}
					s++;
				}
				i++;
			}
		}
		else // si no hay c�digo de formato o se trata de un c�digo de color copiamos tal cual el car�cter en el string resultante
		{
			resultado[r] = formato[i];
			r++;
			i++;
		}
		caracter = formato[i];
	}
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Par�metros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de l�nea), '\t' (tabulador, 4 espacios)
					y c�digos entre 32 y 159 (los 32 �ltimos son caracteres
					gr�ficos), adem�s de c�digos de formato %c, %d, %x y %s
					(max. 2 c�digos por cadena) y las marcas de cambio de color
					actual %0 (blanco), %1 (amarillo), %2 (verde) y %3 (rojo)
		val1	->	valor a sustituir en primer c�digo de formato, si existe
		val2	->	valor a sustituir en segundo c�digo de formato, si existe
					- los valores pueden ser un c�digo ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	n�mero de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	int filaAct, numChars, color;
	int i = 0;
	int primerTab = 0;
	char caracter;

	char resultado[VCOLS * 3] = ""; // el texto definitivo tendr� como m�ximo 3 l�neas
	_gg_procesarFormato(formato, val1, val2, resultado); // sustituimos los c�digos de formato
	
	// pControl --> control de escritura en ventana
	// 4 bits altos: c�digo de color actual (0-3)
	// 12 bits medios: n�mero de l�nea (0-23)
	// 16 bits bajos: caracteres pendientes (0-32) almacenados en pChars[]
	color = _gd_wbfs[ventana].pControl >> 28; // seleccionamos los 4 bits altos (color) con un shift
	filaAct = (_gd_wbfs[ventana].pControl & 0x0FFF0000) >> 16; // seleccionamos los 12 bits medios (linea) con un shift y una AND
	numChars = _gd_wbfs[ventana].pControl & 0xFFFF; // seleccionamos los 16 bits bajos (caracteres) con una AND
	
	caracter = resultado[i];
	
	while (caracter != '\0')
	{
		// si nos encontramos con una marca de formato de color (%0, %1, %2 o %3)
		if (caracter == '%' && (resultado[i+1] > 47 && resultado[i+1] < 52))
		{
			color = resultado[i+1] - '0';
			i = i + 2;
			caracter = resultado[i];
		}
		
		if (caracter == '\t')
		{
			if (numChars % 4 == 0) primerTab = 1;
			
			while(((numChars < VCOLS) && (numChars % 4 != 0)) || (primerTab == 1))
			{
				primerTab = 0;
				_gd_wbfs[ventana].pChars[numChars] = (' ' - 32) + (color*128); // a�adimos espacios hasta el pr�ximo m�ltiplo de 4
				numChars++;
			}
		}
		
		else if ((caracter != '\n') && (numChars < VCOLS)) 
		{
			_gd_wbfs[ventana].pChars[numChars] = (caracter - 32) + (color*128); // copiamos el indice de baldosa en el buffer de linea 
			numChars++;
		}
		
		if ((caracter == '\n') || (numChars == VCOLS))
		{
			_gp_WaitForVBlank();
			
			// en caso de que estemos en la �ltima linea de escritura,
			// deberemos realizar un desplazamiento hacia arriba (scroll)
			if (filaAct == VFILS)
			{
				_gg_desplazar(ventana);
				filaAct--;
			}
			// transferimos los caracteres del buffer sobre las posiciones de 
			// memoria de video correspondientes a la linea actual de escritura en ventana
			if (numChars > 0) _gg_escribirLinea(ventana, filaAct, numChars);
			
			filaAct++;		 // incrementamos la linea de escritura
			numChars = 0; 	// restablecemos el n�mero de car�cteres en la nueva linea
		}
		
		i++;
		caracter = resultado[i];
		
		// actualizamos el campo pControl con numChars restante de la fila
		_gd_wbfs[ventana].pControl = (color << 28) + ((filaAct & 0x0FFF) << 16) + numChars; 
	}
}
