/*------------------------------------------------------------------------------

	"perf.c" : programa de usuario de Matias Ariel Larrosa Babio;
	
	Busca números perfectos (sigma(k) = 2k) entre [0, 2^(10+arg)]. arg está
	entre los valores [0...3] por tanto se buscaran números perfectos entre
	1024, 2048, 4096 i 8192.
	
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */

int _start(int arg)				/* función de inicio : no se usa 'main' */
{
	unsigned int i, iter, total;
	
	GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      PERF  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************");
	
	iter = 1 << (10 + arg);			// iter = cálculo de 2 elevado a 10 + arg
	
	total = 0;
	GARLIC_printf("\nBuscando num perf entre [0, %d]...\n", iter);
	GARLIC_printf("Numeros encontrados:\n\t{");
	for (i = 0; i <= iter; i++){		// encontrar números perfectos
		int sum = 0;
		unsigned int quo, mod;
		for(int j = 1;j * 2 <= i; j++) {
			GARLIC_divmod(i, j, &quo, &mod);
			if(mod == 0)
				sum += j;
		}
		if(sum == i && sum != 0) {
			if(total != 0)
				GARLIC_printf(", ");
			GARLIC_printf("%d", i);
			total++;
		}
	}
	GARLIC_printf("}\nBusqueda finalizada. Total = %d", total);
	GARLIC_printf("\nPrograma PERF terminado\n");
	 
	return 0;
}
