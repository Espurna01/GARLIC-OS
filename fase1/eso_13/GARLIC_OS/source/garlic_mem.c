/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 1 / programador M 
		ainhoa.garcial@estudiants.urv.cat

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema

#define INI_MEM 0x01002000		// dirección inicial de memoria para programas
#define END_MEM 0x01008000		// direccion final de memoria para programas
#define EI_NIDENT 16

typedef unsigned int Elf32_Addr;
typedef unsigned short Elf32_Half;
typedef unsigned int Elf32_Off; 
typedef signed int Elf32_Sword;
typedef unsigned int Elf32_Word;

int offsetSegment = 0;

//Fichero elf
typedef struct {
	unsigned char e_ident[EI_NIDENT];
	Elf32_Half e_type;
	Elf32_Half e_machine;
	Elf32_Word e_version;
	Elf32_Addr e_entry;
	Elf32_Off e_phoff;
	Elf32_Off e_shoff;
	Elf32_Word e_flags;
	Elf32_Half e_ehsize;
	Elf32_Half e_phentsize;
	Elf32_Half e_phnum;
	Elf32_Half e_shentsize;
	Elf32_Half e_shnum;
	Elf32_Half e_shstrndx;
} Elf32_Ehdr;

//Tabla de segmentos
typedef struct {
	Elf32_Word p_type;
	Elf32_Off p_offset;
	Elf32_Addr p_vaddr;
	Elf32_Addr p_paddr;
	Elf32_Word p_filesz;
	Elf32_Word p_memsz;
	Elf32_Word p_flags;
	Elf32_Word p_align;
} Elf32_Phdr;


/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
					para indiciar si dicha inicialización ha tenido éxito; */
int _gm_initFS()
{
	return nitroFSInit(NULL);
}



/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
					directorio "/Programas/" del sistema de ficheros, y
					carga los segmentos de programa a partir de una posición de
					memoria libre, efectuando la reubicación de las referencias
					a los símbolos del programa, según el desplazamiento del
					código en la memoria destino;
	Parámetros:
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	dirección de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(char *keyName)
{
	int direc_prog=0;														//Lo que se retornará
	long size;
	long resultado;
	
	//1. Buscar fichero
	char direc[19];
	
	DIR* directory = opendir("/Programas/");
	if (directory != NULL) {
		sprintf(direc, "/Programas/%s.elf", keyName);
		FILE *program = fopen(direc, "rb"); 									//abrimos en lectura binaria rb
		
		//2. If --> encontrado 
		if (program != NULL) {
			fseek(program, 0, SEEK_END);										//lectura desde el final 
			size = ftell (program);												//obtengo el puntero del total del archivo
			char* buffer = (char*)malloc((size)*sizeof(char));	
			//Hacemos la reserva de memoria con todo el contenido del fichero
			
			if (buffer != NULL){
				
				fseek(program, 0, SEEK_SET);									//vuelvo a poner el puntero al comienzo
				resultado = fread(buffer, sizeof(char), size, program);	
				
				if (resultado == size){
				//3. acceder a la cabecera ELF para obtener el offset y tamaño de tabla de segmentos
					Elf32_Phdr tabla_seg;										//Inicializo una estructura del tipo tabla de segmentos 
					Elf32_Ehdr header;											//Fichero ELF
					
					fseek(program,0,SEEK_SET);
					fread(&header,1,sizeof(Elf32_Ehdr), program);
					
					Elf32_Addr entradaProg;
					Elf32_Off offset;
					Elf32_Half tabSeg_entradas;
					
					entradaProg = header.e_entry;
					offset = header.e_phoff;
					tabSeg_entradas = header.e_phnum;
					
					
					if (tabSeg_entradas != 0){									//Numero de entradas a la tabla de segmentos
						fseek(program, offset, SEEK_SET);						//pones el puntero en la dirección de la tabla de segmentos
						fread(&tabla_seg,1,sizeof(Elf32_Phdr), program); 		//guardas en la tabla de segmentos el segmento
						
						//4. Accedemos a la tabla de segmentos para cada uno de tipo PT_LOAD
						//5. obtener @ segm. a cargar
						Elf32_Word tabla_segm_code = tabla_seg.p_type;			//tipo ELF32_word primer valor de la tabla de segemntos
						
						if (tabla_segm_code == 1){
							Elf32_Addr prog_segmentoInicial = tabla_seg.p_paddr;
							Elf32_Off prog_offset = tabla_seg.p_offset;
							Elf32_Word prog_size = tabla_seg.p_memsz;
							
							//6. Cargar contenido a partir de direc de mem destino
							
							_gs_copiaMem((const void *) &buffer[prog_offset], (unsigned int *) (INI_MEM + offsetSegment), (unsigned int) prog_size);		//dirección fuente, destino y tamaño del segmento
							
							//7. Efectuar la reubicacion de las posiciones sensibles (La otra fx)
							_gm_reubicar( buffer, (unsigned int)prog_segmentoInicial, (unsigned int *) (INI_MEM + offsetSegment));		//buffer del fichero, dirección donde está el segmento, destino en memoria
							
							//8. Si el proceso funciona bien, devolver la @ entrada del programa --> primera insturc a ejecutar
							direc_prog = (INI_MEM + offsetSegment) + entradaProg - prog_segmentoInicial; //Direccion inicial + punto de entrada del progeama -  donde se carga el segmento
							
							offsetSegment += prog_size;
							offsetSegment += offsetSegment % 4;
						}
					}
				}
			}
			free(buffer);
		}
		//9. ELse, retornar 0
		fclose(program);
	}

	return ((intFunc) direc_prog);
}