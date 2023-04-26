/*------------------------------------------------------------------------------
	
	"procesos_teclado.c" / 
	
	Incluye los programas de teclado para llamar a la GARLIC_gtstring

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>

/* Proceso de prueba, con llamadas a las funciones del API del sistema Garlic */
//------------------------------------------------------------------------------
int capgirar(int arg) {
//------------------------------------------------------------------------------
	unsigned int i, j, iter;
	char frase[11];
	if (arg < 0) arg = 0;			// limitar valor m�ximo y 
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento
	
									// esccribir mensaje inicial
	GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      CAPG  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************\n");
	
	j = 1;							// j = c�lculo de 10 elevado a arg
	for (i = 0; i < arg; i++)
		j *= 10;
						// c�lculo aleatorio del n�mero de iteraciones 'iter'
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteraci�n
	GARLIC_printf("- %d frases para GIRAR...\n", iter);
	for (i = 0; i < iter; i++){		// escribir mensajes
		GARLIC_printf("Frase (%d) girar:\n", i + 1);
		j = GARLIC_getstring(frase, 10);
		GARLIC_printf("\"%s\" -> \"", frase);
		for(int k = j - 1; k >= 0; k--){
			GARLIC_printf("%c", frase[k]);
		}
		GARLIC_printf("\"\n");
	}
	GARLIC_printf("*** Final capgirar\n");
	return 0;
}

int vocales(char *str, int max_char){
	int count = 0;
	for(int i = 0; i < max_char; i++)
		switch (str[i]){
		case 'a':
		case 'e':
		case 'i':
		case 'o':
		case 'u':
		case 'A':
		case 'E':
		case 'I':
		case 'O':
		case 'U':
			count++;
			break;
		}
	return count;
}


/* Proceso de prueba, con llamadas a las funciones del API del sistema Garlic */
//------------------------------------------------------------------------------
int cvocals(int arg) {
//------------------------------------------------------------------------------
	unsigned int i, j, iter, aleatori, div;
	char frase[31];
	
	if (arg < 0) arg = 0;			// limitar valor m�ximo y 
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento

	GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      VOCA  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************\n");

	
	j = 1;							// j = c�lculo de 10 elevado a arg
	for (i = 0; i < arg; i++)
		j *= 10;
						// c�lculo aleatorio del n�mero de iteraciones 'iter'
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteraci�n
	
	GARLIC_printf("- %d frases CONTAR VOCALES...\n", iter);
	for (i = 0; i < iter; i++){		// escribir mensajes
		GARLIC_divmod(GARLIC_random(), 30, &div, &aleatori);
		GARLIC_printf("(%d)Tamano max (voca): %d\n", i+1, aleatori + 1);
		j = GARLIC_getstring(frase, aleatori + 1); //aleatori = [1, 30]
		GARLIC_printf("\"%s\"\n\tTamano: %d\n", frase, j);
		GARLIC_printf("\tNum.Vocales = %d\n", vocales(frase, j));
	}
	
	GARLIC_printf("*** Final vocales\n");
	return 0;
}
