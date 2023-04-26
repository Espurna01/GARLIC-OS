/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 2 / programador M

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <dirent.h>			// para struct dirent, etc.
#include <stdio.h>			// para fopen(), fread(), etc.
#include <stdlib.h>			// para malloc(), etc.
#include <string.h>			// para strcat(), memcpy(), etc.

#include <garlic_system.h>	// definici�n de funciones y variables de sistema


#define INI_MEM 0x01002000		// direcci�n inicial de memoria para programas
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
					para indiciar si dicha inicializaci�n ha tenido �xito; */
int _gm_initFS()
{
	return nitroFSInit(NULL);
}

/* _gm_listaProgs: devuelve una lista con los nombres en clave de todos
			los programas que se encuentran en el directorio "Programas".
			Se considera que un fichero es un programa si su nombre tiene
			8 caracteres y termina con ".elf"; se devuelven s�lo los
			4 primeros caracteres de los programas (nombre en clave).
			El resultado es un vector de strings (paso por referencia) y
			el n�mero de programas detectados */
int _gm_listaProgs(char* progs[])
{
	int n_progs=0;
	DIR* pdir = opendir("/Programas/");		//Abrimos la carpeta
	if (pdir != NULL) 
	{
		struct dirent * ent = readdir(pdir);
		while ((ent = readdir(pdir)) != NULL)
		{	
			//Si tiene 8 caracteres   && el caracter 4 es un . && char 5 es e       && char 6 es l         && char 7 una f
			if(strlen(ent->d_name)==8 && ent->d_name[4]=='.' && ent->d_name[5]=='e' && ent->d_name[6]=='l' && ent->d_name[7]=='f')
			{
				progs[n_progs] = calloc(4, sizeof(char));
				strncpy(progs[n_progs++], ent->d_name, 4);
			}
		}
		closedir(pdir);
	}
	return n_progs;
}


/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
				directorio "/Programas/" del sistema de ficheros, y carga los
				segmentos de programa a partir de una posici�n de memoria libre,
				efectuando la reubicaci�n de las referencias a los s�mbolos del
				programa, seg�n el desplazamiento del c�digo y los datos en la
				memoria destino;
	Par�metros:
		zocalo	->	�ndice del z�calo que indexar� el proceso del programa
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	direcci�n de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(int zocalo, char *keyName)
{
	int direc_prog=0;														//Lo que se retornar�
	long size;
	long resultado;
	
	
	//1. Buscar fichero
	char direc[19];
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
			
			Elf32_Ehdr* header2 = (Elf32_Ehdr*) buffer;
			Elf32_Phdr *tabla_segm_data;
			
			if (resultado == size){
			//3. acceder a la cabecera ELF para obtener el offset y tama�o de tabla de segmentos
				Elf32_Phdr tabla_seg, tabla_seg_dat;									//Inicializo una estructura del tipo tabla de segmentos 
				Elf32_Ehdr header;											//Fichero ELF
				
				fseek(program,0,SEEK_SET);
   				fread(&header,1,sizeof(Elf32_Ehdr), program);
				
				Elf32_Addr entradaProg;
				Elf32_Off offset;
				Elf32_Half tabSeg_entradas;
				Elf32_Half size_seg;
				unsigned int reservaMemCode;
				unsigned int reservaMemDatos;
				
				entradaProg = header.e_entry;
				offset = header.e_phoff;
				tabSeg_entradas = header.e_phnum;
				size_seg = header.e_phentsize;
				
				if (tabSeg_entradas != 0){									
					//Numero de entradas a la tabla de segmentos; puede ser 1 o 2
					// hacer una comprobaci�n, si son dos trataremos primero codigo y luego datos
					// si es una, trataremos solo codigo como venimos haciendo
					
					fseek(program, offset, SEEK_SET);						//pones el puntero en la direcci�n de la tabla de segmentos
					fread(&tabla_seg,1,sizeof(Elf32_Phdr), program); 		//guardas en la tabla de segmentos el primer segmento
					
					//4. Accedemos a la tabla de segmentos para cada uno de tipo PT_LOAD
					
					Elf32_Word tabla_segm_code = tabla_seg.p_type;			//tipo ELF32_word primer valor de la tabla de segemntos
					Elf32_Word tabla_seg_dat_type = tabla_seg.p_type;
					Elf32_Addr prog_segmentoInicial = tabla_seg.p_paddr;
					Elf32_Off prog_offset = tabla_seg.p_offset;
					Elf32_Word prog_size = tabla_seg.p_memsz;
					
					//5. obtener @ segm. a cargar
					if (tabSeg_entradas == 1){
						if (tabla_segm_code == 1){
							
							//6. Cargar contenido a partir de direc de mem destino
							reservaMemCode = (int) _gm_reservarMem( zocalo, prog_size, (unsigned char) 0);
							
							if (reservaMemCode!=0){
								_gs_copiaMem((const void *) &buffer[prog_offset], (unsigned int *) reservaMemCode, (unsigned int) prog_size);		//direcci�n fuente, destino y tama�o del segmento
								
								//7. Efectuar la reubicacion de las posiciones sensibles (La otra fx)
								_gm_reubicar( buffer, (unsigned int)prog_segmentoInicial, (unsigned int *) reservaMemCode ,0XFFFFFFFF,0);		//buffer del fichero, direcci�n donde est� el segmento, destino en memoria, inicio segmento de datos
								//8. Si el proceso funciona bien, devolver la @ entrada del programa --> primera insturc a ejecutar
								direc_prog = reservaMemCode + entradaProg - prog_segmentoInicial; //Direccion inicial + punto de entrada del progeama -  donde se carga el segmento
							}
							else{
								_gm_liberarMem(zocalo);
							}
							
						}	
					}
					else if (tabSeg_entradas == 2){
						if (!((offsetSegment + INI_MEM) > END_MEM)){
							
							offset += size_seg;
							tabla_segm_data = (Elf32_Phdr*) &buffer[header2->e_phoff+(header2->e_phentsize)];
							
							fseek(program, offset, SEEK_SET);						//pones el puntero en la direcci�n de la tabla de segmentos
							fread(&tabla_seg_dat,1,sizeof(Elf32_Phdr), program); 		//guardas en la tabla de segmentos el primer segmento
								
							tabla_seg_dat_type = tabla_seg_dat.p_type;
							
							if((tabla_segm_code == 1) && (tabla_seg_dat_type == 1)){
								
								prog_offset = tabla_seg.p_offset;
								prog_size = tabla_seg.p_memsz;
								prog_segmentoInicial = tabla_seg.p_paddr;
								
								reservaMemDatos = (int) _gm_reservarMem( zocalo, tabla_segm_data->p_memsz, (unsigned char) 1);
								if (reservaMemDatos!=0){
									reservaMemCode = (int) _gm_reservarMem( zocalo, prog_size, (unsigned char) 0);
									if (reservaMemCode!=0){
										
										_gs_copiaMem((const void *) &buffer[prog_offset], (unsigned int *) reservaMemCode, (unsigned int) prog_size);		//direcci�n fuente, destino y tama�o del segmento
										_gs_copiaMem((const void *) &buffer[tabla_segm_data->p_offset], (unsigned int *) reservaMemDatos, (unsigned int) tabla_segm_data->p_filesz);		//direcci�n fuente, destino y tama�o del segmento
										
										//7. Efectuar la reubicacion de las posiciones sensibles (La otra fx)
										_gm_reubicar(buffer, (unsigned int)prog_segmentoInicial, (unsigned int *) reservaMemCode, tabla_segm_data->p_paddr, (unsigned int *) reservaMemDatos);		//buffer del fichero, direcci�n donde est� el segmento, destino en memoria, inicio segmento de datos
										
										direc_prog = reservaMemCode + entradaProg - prog_segmentoInicial; //Direccion inicial + punto de entrada del progeama -  donde se carga el segmento
									}
								} else {
									_gm_liberarMem(zocalo);
								}
							}
						}
					}
				}
			}
		}
		free(buffer);
	}
	
	//9. ELse, retornar 0
	fclose(program);
	return ((intFunc) direc_prog);
}