/*------------------------------------------------------------------------------

	"DPAS.c" : Programa de prueba para el sistema operativo GARLIC 1.0;
	
	Recibe un any aleatorio e imprime por pantalla la fecha en la que caerï¿½a
	el domingo de Pascua correspondiente a esa fecha.
	El DOmingo de Pascual estï¿½ marcado como el domingo inmediatamente posterior
	a la primera luna llena despuï¿½s del equinocio de marzo, es decir, del 
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
	
	Si el valor dias fuese mayor a 31, estarï¿½amos hablando del mes de Abril
	en vez de marzo.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definicion de las funciones API de GARLIC */

int _start(int arg)                /* funcion de inicio : no se usa 'main' */
{
    unsigned int a, b, c, d, e, dia, coc, any;
	
    if (arg < 0) arg = 0;                    // limitar el a?o m?nimo y 
    else if (arg > 3) arg = 3;        // el any maximo de calculo
	
	arg = 1 << (arg + 5);	// 2^(5+arg) -> {32,64,128,256,512}
	
	GARLIC_divmod(GARLIC_random(), arg, &coc, &any);
	
	any += 1900;
                                    // esccribir mensaje inicial
    GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      DPAS  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************\n");

    GARLIC_divmod(any, 19, &coc, &a);     //a
    GARLIC_divmod(any, 4, &coc, &b);    //b
    GARLIC_divmod(any, 7, &coc, &c);    //c

    d =  (19*a + 24);
    GARLIC_divmod(d, 30, &coc, &c);
    d = coc;

    e = (2*b + 4*c + 6*d +5);
    GARLIC_divmod(e, 7, &coc, &c);
    e = coc;

    dia = d + e + 22;

    if (dia <= 31) {
        GARLIC_printf("En el any %d el Domingo de Pascua cae en el dia %d de marzo\n", any, dia);
    } else {
        dia = dia - 31;
        GARLIC_printf("En el any %d el Domingo de Pascua cae en el dia %d de abril\n", any, dia);
    }
	GARLIC_printf("\n");
    return 0;
}

