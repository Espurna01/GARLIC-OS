/*------------------------------------------------------------------------------
	Proceso de usuario ProgG: producto escalar entre dos vecotres aleatorios
	[-10, 10] de longitud 1+2^arg.
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>

int _start(int arg){

	unsigned int n,i,j,mult, prod;
	
    // limitamos los valores del argumento
    if (arg < 0) arg = 0;
    else if (arg > 3) arg = 3;

    GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      DOTP  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************\n");
    GARLIC_printf("Se van a generar dos vectores\ncon valores aleatorios [-10..10]\n");

    j = 1;                            // j = cálculo de 2 elevado a arg
    for (i = 0; i < arg; i++)
        j *= 2;

    n = 1 + j;                        // longitud n = 1 + 2^arg

    unsigned int vector1[n];
    unsigned int vector2[n];

    GARLIC_printf("La longitud de los vectores es:\n");
    GARLIC_printf("1+2^arg --> 1+2^%d = %d\n", arg, n);

    // llenamos los vectores con números aleatorios entre -10 y 10
    // y a continuación calculamos el producto escalar
    prod = 0;
    for(i = 0; i < n; i++)
    {
        vector1[i] = GARLIC_random()%20-10; //%20-10 --> [-10..10]
        vector2[i] = GARLIC_random()%20-10; 
        mult = vector1[i] * vector2[i];
        prod = prod + mult;
    }
// ANOTACIÓN: los números negativos están codificados como naturales
    // debido a las funciones que se encargan de procesar los decimales
    // por tanto el rango del unsigned int va de 0 a 4294967295,
    // siendo este último valor el correspondiente a un -1 en notación entera
    GARLIC_printf("\nContenido del vector 1:\n");
    GARLIC_printf("[");
    for(i = 0; i < n; i++)
    { 
        if (vector1[i] >= 0 && vector1[i] <= 10)
        {
            if (i != 0) GARLIC_printf(",");
            GARLIC_printf("%d", vector1[i]);
        }
        else { // número negativo de -1 a -10 (de 4294967295 a 4294967286)
            if (i != 0) GARLIC_printf(",");
            vector1[i] = 4294967296 - vector1[i];
            GARLIC_printf("-%d", vector1[i]);
        }
    }
    GARLIC_printf("]\n");

    GARLIC_printf("\nContenido del vector 2:\n");
    GARLIC_printf("[");
    for(j = 0; j < n; j++)
    { 
        if (vector2[j] >= 0 && vector2[j] <= 10)
        {
            if (j != 0) GARLIC_printf(",");
            GARLIC_printf("%d", vector2[j]);
        }
        else {
            if (j != 0) GARLIC_printf(",");
            vector2[j] = 4294967296 - vector2[j];
            GARLIC_printf("-%d", vector2[j]);
        }
    }
    GARLIC_printf("]\n");

    // suponiendo el producto escalar más elevado
    // (vectores de 1+2^3 de longitud con todas las posiciones con valor 10 --> prod = 900)
    if (prod > 900) // si es superior estaremos ante un número negativo
    {
        prod = 4294967296 - prod;
        GARLIC_printf("\nProducto escalar resultante:\n -%d\n", prod);
    }
    else 
    {
        GARLIC_printf("\nProducto escalar resultante:\n %d\n", prod);
    }
	GARLIC_printf("\nPrograma DOTP terminado\n");
	 
    return 0;

}