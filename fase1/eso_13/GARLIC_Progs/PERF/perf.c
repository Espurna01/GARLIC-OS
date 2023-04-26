/*------------------------------------------------------------------------------

	"perf.c" : programa de usuario de Matias Ariel Larrosa Babio;
	
	Busca n�meros perfectos (sigma(k) = 2k) entre [0, 2^(10+arg)]. arg est�
	entre los valores [0...3] por tanto se buscaran n�meros perfectos entre
	1024, 2048, 4096 i 8192.
	
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definici�n de las funciones API de GARLIC */

int _start(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	unsigned int i, iter, total;
	
	GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      PERF  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************");
	
	iter = 1 << (10 + arg);			// iter = c�lculo de 2 elevado a 10 + arg
	
	total = 0;
	GARLIC_printf("\nBuscando num perf entre [0, %d]...\n", iter);
	GARLIC_printf("Numeros encontrados:\n\t{");
	for (i = 0; i <= iter; i++){		// encontrar n�meros perfectos
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
