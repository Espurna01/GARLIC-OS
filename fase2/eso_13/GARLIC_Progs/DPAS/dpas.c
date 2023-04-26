/*------------------------------------------------------------------------------

	"DPAS.c" : Programa de prueba para el sistema operativo GARLIC 1.0;
	
	Recibe un año aleatorio e imprime por pantalla la fecha en la que caería
	el domingo de Pascua correspondiente a esa fecha.
	El DOmingo de Pascual está marcado como el domingo inmediatamente posterior
	a la primera luna llena después del equinocio de marzo, es decir, del 
	comienzo de la primavera y se debe calcular empleando la luna llena 
	astronómica.
	A partir del 1900.
	Los siguientes cálculos nos darán la fecha:
	A = año % 19
	B = año % 4
	C = año % 7
	D = (19 * A + 24) % 30
	E = (2 * B + 4 * C + 6 * D + 5) % 7
	dias = 22 + D + E
	
	Si el valor días fuese mayor a 31, estaríamos hablando del mes de Abril
	en vez de marzo.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */


unsigned int dias[10];			/* variables globales no inicializadas */
unsigned int meses[10];

								/* variable global inicializada */
unsigned int anys[10] = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29};

int _start(int arg)                /* funcion de inicio : no se usa 'main' */
{
    unsigned int a, b, c, d, e, dia, coc;
	
    if (arg < 0) arg = 0;                    // limitar el a?o m?nimo y 
    else if (arg > 3) arg = 3;        // el any maximo de calculo
	
	// esccribir mensaje inicial
	GARLIC_printf("********************************");	
	GARLIC_printf("*                              *");
	GARLIC_printf("*      DPAS  -  PID (%d)        *", GARLIC_pid());
	GARLIC_printf("*                              *");
	GARLIC_printf("********************************\n");


	for (int i = 0; i < 10; i++){
		GARLIC_divmod(anys[i], 19, &coc, &a);     //a
		GARLIC_divmod(anys[i], 4, &coc, &b);    //b
		GARLIC_divmod(anys[i], 7, &coc, &c);    //c
		
		d =  (19*a + 24);
		GARLIC_divmod(d, 30, &coc, &c);
		d = coc;
		
		e = (2*b + 4*c + 6*d +5);
		GARLIC_divmod(e, 7, &coc, &c);
		e = coc;
		
		dia = d + e + 22;
		dias[i] = dia;
		
		if (dia <= 31) {
			GARLIC_printf("En el any %d el Domingo de Pascua cae en el dia %d de marzo\n", anys[i], dia);
			meses[i] = 3;
		} else {
			dia = dia - 31;
			GARLIC_printf("En el any %d el Domingo de Pascua cae en el dia %d de abril\n", anys[i], dia);
			meses[i] = 4;
		}
		GARLIC_printf("\n");
	}
    return 0;
}