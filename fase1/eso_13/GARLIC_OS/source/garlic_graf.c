/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G
					ivan.cardona@estudiants.urv.cat

	Funciones de gestión de las ventanas de texto (gráficas), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema
#include <garlic_font.h>	// definición gráfica de caracteres

/* definiciones para realizar cálculos relativos a la posición de los 
caracteres dentro de las ventanas gráficas, que pueden ser 4 o 16 */
#define NVENT	4			// número de ventanas totales
#define PPART 	2			// número de ventanas horizontales o verticales
									// (particiones de pantalla)
#define VCOLS 	32			// columnas de cualquier ventana
#define VFILS 	24			// filas de cualquier ventana
#define PCOLS 	VCOLS * PPART	// número de columnas totales
#define PFILS	VFILS * PPART	// núermo de filas totales

int bg2A, bg3A;
int bg2Amap;
u16 * mapPtr;

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por parámetro*/
void _gg_generarMarco(int v)
{
	// mapPtr = mapa base de bg3A + desplazamiento de filas
	mapPtr = bgGetMapPtr(bg3A) + (((v) / PPART) * VFILS * PCOLS);
	
	// si la ventana es impar, desplazaremos segun las columnas
	if (v % PPART != 0){
		mapPtr = mapPtr + VCOLS * (v % PPART);
	}
	
	// esquina superior izquierda
	mapPtr[0] = 103;
	
	// esquina inferior izquierda
	mapPtr[(VFILS-1) * PCOLS] = 100;
	
	// esquina superior derecha
	mapPtr[VCOLS-1] = 102;
	
	// esquina inferior derecha
	mapPtr[(VFILS-1) * PCOLS + (VCOLS-1)] = 101;
	
	// laterales superior e inferior
	for (int i = 1; i < VCOLS-1; i++)
	{
		mapPtr[i] = 99;	 						// superior
		mapPtr[(VFILS-1) * PCOLS + i] = 97;		// inferior
	}
	
	// laterales izquierdo y derecho
	for (int i = 1; i < VFILS-1; i++)
	{
		mapPtr[i * PCOLS] = 96;					// izquierdo
		mapPtr[i * PCOLS + (VCOLS-1)] = 98;		// derecho
	}
	
}


/* _gg_iniGraf: inicializa el procesador gráfico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
	videoSetMode(MODE_5_2D); // inicializamos procesador gráfico principal en modo 5
	lcdMainOnTop(); // salida en la pantalla superior
	
	vramSetBankA(VRAM_A_MAIN_BG); // reservamos el banco de memoria de video A
	
	bg2Amap = (int)bgGetMapPtr(bg2A); // mapa que usaremos en las rutinas auxiliares
	
	/* bgInit(int layer, BgType type, BgSize size, int mapBase, int tileBase)
			Inicializamos fondo gráfico 2 en modo Extended Rotation,
			con un tamaño total de 512x512 píxeles.
			mapBase1 = 0 --> 0600 0000 (Virtual VRAM procesador gráfico principal)
			tileBase = 1 --> 0600 4000 (Virutal VRAM procesador gráfico principal)
	*/
	bg2A = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 0, 1);
	bgSetPriority(bg2A, 1); // fijamos el fondo 2 con segunda prioridad
	
	// Fondo gráfico 3
	bg3A = bgInit(3, BgType_ExRotation, BgSize_ER_512x512, 3, 1);
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

	// generamos los marcos de las ventanas de texto en el fondo 3
	for (int i = 0; i < NVENT; i++)
	{
		_gg_generarMarco(i);
	}
	
	// escalamos los fondos 2 y 3 para que se ajusten a las dimensiones de la pantalla NDS
	// reducción al 50%
	bgSetScale(bg2A, 512, 512);
	bgSetScale(bg3A, 512, 512);
	bgUpdate();
	
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los códigos de formato
					  precedidos por '%' e inserta la representación ASCII de
					  los valores indicados por parámetro.
	Parámetros:
		formato	->	string con códigos de formato (ver descripción _gg_escribir);
		val1, val2	->	valores a transcribir, sean número de código ASCII (%c),
					un número natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observación:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripción a código ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{
	char caracter;
	int i = 0; 		// contador del string de formato entrante
	int r = 0; 		// contador string resultante
	int s = 0;		// contador que usaremos para los string de los valores
	int vals = 0; 	// contador de valores tratados
	char valor[11]; // tabla donde guardaremos los dígitos de los números
					// 11 posiciones porque 2^32bits = 4294967296 + centinela
	caracter = formato[i];
	char *codi;
	
	while (caracter != '\0') 	// mientras no sea el final del string de formato
	{
		if (caracter == '%')	// si encontramos un código de formato
		{
			i++; // pasamos a leer la marca de formato
			caracter = formato[i];
			
			if ((caracter == 's') && (vals < 2))
			{
				s = 0;	// contador del string de marca de formato
				
				codi = (char *)(vals == 0 ? val1 : val2);
				// recorremos el string representado por el código de formato
				// y lo copiamos en resultado
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
					// guardamos en "valor" la representación en decimal del número
					if (vals == 0)
						_gs_num2str_dec(valor, sizeof(valor), val1);
					else 
						_gs_num2str_dec(valor, sizeof(valor), val2);
				}
				else
				{
					// guardamos en "valor" la representación en hexadecimal del número
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
		else // si no hay código de formato copiamos tal cual el carácter en el string resultante
		{
			resultado[r] = formato[i];
			r++;
			i++;
		}
		caracter = formato[i];
	}
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Parámetros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de línea), '\t' (tabulador, 4 espacios)
					y códigos entre 32 y 159 (los 32 últimos son caracteres
					gráficos), además de códigos de formato %c, %d, %x y %s
					(max. 2 códigos por cadena)
		val1	->	valor a sustituir en primer código de formato, si existe
		val2	->	valor a sustituir en segundo código de formato, si existe
					- los valores pueden ser un código ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	número de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{
	int filaAct, numChars;
	int i = 0;
	int primerTab = 0;
	char caracter;

	char resultado[VCOLS * 3] = ""; // el texto definitivo tendrá como máximo 3 líneas
	_gg_procesarFormato(formato, val1, val2, resultado); // sustituimos los códigos de formato
	
	// pControl --> control de escritura en ventana
	// 16 bits altos: número de línea (0-23)
	// 16 bits bajos: caracteres pendientes (0-32) almacenados en pChars[]
	filaAct = _gd_wbfs[ventana].pControl >> 16; // seleccionamos 16 bits altos con un shift
	numChars = _gd_wbfs[ventana].pControl & 0xFFFF; // seleccionamos 16 bits bajos con una AND
	
	caracter = resultado[i];
	
	while (caracter != '\0')
	{
		if (caracter == '\t')
		{
			if (numChars % 4 == 0) primerTab = 1;
			
			while(((numChars < VCOLS) && (numChars % 4 != 0)) || (primerTab == 1))
			{
				primerTab = 0;
				_gd_wbfs[ventana].pChars[numChars] = ' '; // añadimos espacios hasta el próximo múltiplo de 4
				numChars++;
			}
		}
		
		else if ((caracter != '\n') && (numChars < VCOLS)) // copiamos tal cual el carácter del string en el buffer de linea
		{
			_gd_wbfs[ventana].pChars[numChars] = caracter;
			numChars++;
		}
		
		if ((caracter == '\n') || (numChars == VCOLS))
		{
			swiWaitForVBlank();
			
			// en caso de que estemos en la última linea de escritura,
			// deberemos realizar un desplazamiento hacia arriba (scroll)
			if (filaAct == VFILS)
			{
				_gg_desplazar(ventana);
				filaAct--;
			}
			// transferimos los caracteres del buffer sobre las posiciones de 
			// memoria de video correspondientes a la linea actual de escritura en ventana
			if(numChars > 0) _gg_escribirLinea(ventana, filaAct, numChars);
			
			filaAct++;		 // incrementamos la linea de escritura
			numChars = 0; 	// restablecemos el número de carácteres en la nueva linea
		}
		
		i++;
		caracter = resultado[i];
		
		// actualizamos el campo pControl con numChars restante de la fila
		_gd_wbfs[ventana].pControl = (filaAct << 16) + numChars; 
	}

}
