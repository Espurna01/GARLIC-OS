/*------------------------------------------------------------------------------
	
	"procesos_usuario.c" / 
	
	Incluye los programas de usuario de los programadores G, P y T.
	Al no tener implementado el progM.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>

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
    GARLIC_printf("*      CVOC  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************\n");

	j = 1;							// j = c�lculo de 10 elevado a arg
	for (i = 0; i < arg; i++)
		j *= 10;
						// c�lculo aleatorio del n�mero de iteraciones 'iter'
	GARLIC_divmod(15, j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteraci�n
	
	GARLIC_printf("- %d frases CONTAR VOCALES...\n", iter);
	for (i = 0; i < iter; i++){		// escribir mensajes
		GARLIC_divmod(GARLIC_random(), 30, &div, &aleatori);
		GARLIC_printf("(%d)Tamano max: %d\n", i+1, aleatori + 1);
		j = GARLIC_getstring(frase, aleatori + 1); //aleatori = [1, 30]
		GARLIC_printf("\"%s\"\n\tTamano: %d\n", frase, j);
		GARLIC_printf("\tNum.Vocales = %d\n", vocales(frase, j));
	}
	
	return 0;
}

int perf(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	unsigned int i, iter, total, encontrados[4];
	char codigo = 0;
	arg = arg >= 3? 2 : arg; 
	GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      PERF  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************");
	
	iter = 1 << (10 + arg - 2);			// iter = c�lculo de 2 elevado a 10 + arg
	
	total = 0;
	GARLIC_printf("\nBuscando # Perf entre [0, %d]...\n", iter);
	i = 0;
	do{		// encontrar n�meros perfectos
		int sum = 0;
		for(int j = 1;j * 2 <= i; j++) {
			if(i % j == 0)
				sum += j;
		}
		if(sum == i && sum != 0) {
			GARLIC_printf("Numero PERF encontrado! (%d)\n", i);
			encontrados[total] = i;
			total++;
			GARLIC_printf("Buscar siguiente?(X(si)/Y(no))\n");
			do{
				codigo = GARLIC_getXYbuttons();
			}while(codigo == 0);
			if(codigo & 2)
				GARLIC_printf("Dejando la busqueda...\n");
			else if(codigo & 1) GARLIC_printf("Buscando siguiente...\n");
			GARLIC_delay(1);
		}
		i++; 
	}while(i <= iter && !(codigo & 2));
	GARLIC_printf("\nBusqueda finalizada. Total = %d\n", total);
	GARLIC_printf("Numeros encontrados:\n\t{");
	for(i = 0; i < total; i++){
		if(i != 0) GARLIC_printf(", ");
		GARLIC_printf("%d", encontrados[i]);
	}
	GARLIC_printf("}\n");
	GARLIC_printf("\nPrograma PERF terminado\n");
	 
	return 0;
}


const char digitos[][8][8] =
	{	// d�gito 0
	 {{	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x7F, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x7F, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x7F, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 1
	 {{	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 2
	 {{	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 3
	 {{	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 4
	 {{	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 5
	 {{	0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x7F, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 6
	 {{	0x20, 0x20, 0x20, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 7
	 {{	0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 8
	 {{	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// d�gito 9
	 {{	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x7F, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x7F, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x7F, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x7F, 0x20, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}},
		// car�cter ':'
	 {{	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x7F, 0x20, 0x20, 0x20, 0x20, 0},
	  {	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0},
	  { 0, 0, 0, 0, 0, 0, 0, 0}}};


int cron(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	int umin, dmin, useg, dseg;
	unsigned char masc;
	
	if (arg < 0) arg = 0;			// limitar valor m�nimo del argumento 
	if (arg > 3) arg = 3;			// limitar valor m�ximo del argumento

	GARLIC_clear();
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa CRON  -  PID %2(%d) %0--\n", GARLIC_pid());

	dmin = 0; umin = 0;
	dseg = 0; useg = 0;	
									// imprimir "00:00"
	GARLIC_printmat(0, 8, (char (*)[8]) digitos[0], arg);
	GARLIC_printmat(7, 8, (char (*)[8]) digitos[0], arg);
	GARLIC_printmat(14, 8, (char (*)[8]) digitos[10], arg);
	GARLIC_printmat(19, 8, (char (*)[8]) digitos[0], arg);
	GARLIC_printmat(26, 8, (char (*)[8]) digitos[0], arg);
	do
	{
		GARLIC_delay(arg);			// retardo dependiendo del argumento
		useg++;						// incrementar unidades de segundo
		masc = 0;					// resetear m�scara de modificaciones
		if (useg == 10)
		{	useg = 0;				// desbordamiento de unidades de segundo
			dseg++;
			masc |= 0x01;	
			if (dseg == 6)
			{	dseg = 0;			// desbordamiento de decenas de segundo
				umin++;
				masc |= 0x02;
				if (umin == 10)
				{	umin = 0;		// desbordamiento de unidades de minuto
					dmin++;
					masc |= 0x04;
				}
			}
		}
		GARLIC_printmat(26, 8, (char (*)[8]) digitos[useg], arg);
		if (masc & 0x01)
			GARLIC_printmat(19, 8, (char (*)[8]) digitos[dseg], arg);
		if (masc & 0x02)
			GARLIC_printmat(7, 8, (char (*)[8]) digitos[umin], arg);
		if (masc & 0x04)
			GARLIC_printmat(0, 8, (char (*)[8]) digitos[dmin], arg);	
	} while (dmin < 9); 			// acaba a los 90 minutos
	return 0;
}

/* Proceso de prueba, con llamadas a las funciones del API del sistema Garlic */
//------------------------------------------------------------------------------
int capgirar(int arg) {
//------------------------------------------------------------------------------
	unsigned int i, j, iter;
	char frase[31];
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
	GARLIC_divmod(19, j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteraci�n
	
	GARLIC_printf("- %d frases para GIRAR...\n", iter);
	for (i = 0; i < iter; i++){		// escribir mensajes
		GARLIC_printf("Frase (%d) girar:\n", i + 1);
		j = GARLIC_getstring(frase, GARLIC_random() % 20 + 5);
		GARLIC_printf("\"%s\" -> \"", frase);
		for(int k = j - 1; k >= 0; k--){
			GARLIC_printf("%c", frase[k]);
		}
		GARLIC_printf("\"\n");
	}
	 
	return 0;
}


int borrar(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	GARLIC_clear();
	return 0;
}

void mostrar_zeros(int);

int cdis(int arg)				
{
	unsigned int i, j, quocient, residu, metres, conv;

    //limitem el valor de l'argument
    //ens asegurem que es troba entre 0 i 3
    if (arg < 0) arg = 0;
    else if (arg > 3) arg = 3;

    //mostrem un missatge inicial
    GARLIC_printf("********************************");
    GARLIC_printf("*                              *");
    GARLIC_printf("*      CDIS  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("*                              *");
    GARLIC_printf("********************************");

    //calculem 10^(arg+1)
    arg++;
    j = 1;
    for (i = 0; i < arg; i++){
        j = 10;
    }


    //generem un n�mero aleatori de metres
    GARLIC_printf("Calculant metres (aleatori)...\n");
	GARLIC_delay(1);
    GARLIC_divmod(GARLIC_random(), j, &quocient, &metres);
    GARLIC_printf("Calcul finalitzat.\n");
    GARLIC_printf("\nNumero de metres: %d\n", metres);


    //c�lcul milles
    GARLIC_printf("\nCalculant conversio a milles...\n");
	GARLIC_delay(1);
    conv = metres * 62;
    GARLIC_divmod(conv, 100000, &quocient, &residu);
    GARLIC_printf("%d metres = %d.",metres, quocient);
    mostrar_zeros(residu);
    GARLIC_printf("%d milles\n", residu);
	

    //c�lcul iardes
    GARLIC_printf("\nCalculant conversio a iardes...\n");
	GARLIC_delay(1);
    conv = metres * 109361;
    GARLIC_divmod(conv, 100000, &quocient, &residu);
    GARLIC_printf("%d metres = %d.", metres, quocient);
    mostrar_zeros(residu);
    GARLIC_printf("%d iardes\n", residu);

    //c�lcul peus
    GARLIC_printf("\nCalculant conversio a peus...\n");
	GARLIC_delay(1);
    conv = metres * 328084;
    GARLIC_divmod(conv, 100000, &quocient, &residu);
    GARLIC_printf("%d metres = %d.", metres, quocient);
    mostrar_zeros(residu);
    GARLIC_printf("%d peus\n", residu);


    GARLIC_printf("Final programa CDIS\n");
	 
    return 0;
}

void mostrar_zeros(int num){

    unsigned int quocient, residu, numXifres, j;

    numXifres = 0;
    j = 1;

    //calculem el n�mero de xifres que t� el n�mero
    GARLIC_divmod(num, j, &quocient, &residu);
    while(quocient != 0) {
        j *= 10;
        numXifres++;
        GARLIC_divmod(num, j, &quocient, &residu);
    }

    //si el n�mero de xifres decimals �s menor que 5
    //escribim els zeros que falten despr�s de la coma
    if(numXifres < 5){

        numXifres = 5 - numXifres;

        while(numXifres > 0) {
            GARLIC_printf("0");
            numXifres--;
        }
    }
}

unsigned int factores[10];			/* variables globales no inicializadas */
unsigned char pesos[10];
unsigned int nFactores;
										/* variable global inicializada */
unsigned int pK[1000] = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
				31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
				73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
				127, 131, 137, 139, 149, 151, 157, 163, 167, 173,
				179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
				233, 239, 241, 251, 257, 263, 269, 271, 277, 281,
				283, 293, 307, 311, 313, 317, 331, 337, 347, 349,
				353, 359, 367, 373, 379, 383, 389, 397, 401, 409,
				419, 421, 431, 433, 439, 443, 449, 457, 461, 463,
				467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
				547, 557, 563, 569, 571, 577, 587, 593, 599, 601,
				607, 613, 617, 619, 631, 641, 643, 647, 653, 659,
				661, 673, 677, 683, 691, 701, 709, 719, 727, 733,
				739, 743, 751, 757, 761, 769, 773, 787, 797, 809,
				811, 821, 823, 827, 829, 839, 853, 857, 859, 863,
				877, 881, 883, 887, 907, 911, 919, 929, 937, 941,
				947, 953, 967, 971, 977, 983, 991, 997, 1009, 1013,
				1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069,
				1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 1129, 1151,
				1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223,
				1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291,
				1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373,
				1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451,
				1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511,
				1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583,
				1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657,
				1663, 1667, 1669, 1693, 1697, 1699, 1709, 1721, 1723, 1733,
				1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811,
				1823, 1831, 1847, 1861, 1867, 1871, 1873, 1877, 1879, 1889,
				1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987,
				1993, 1997, 1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053,
				2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129,
				2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213,
				2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287,
				2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357,
				2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417, 2423,
				2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531,
				2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593, 2609, 2617,
				2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687,
				2689, 2693, 2699, 2707, 2711, 2713, 2719, 2729, 2731, 2741,
				2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819,
				2833, 2837, 2843, 2851, 2857, 2861, 2879, 2887, 2897, 2903,
				2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999,
				3001, 3011, 3019, 3023, 3037, 3041, 3049, 3061, 3067, 3079,
				3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181,
				3187, 3191, 3203, 3209, 3217, 3221, 3229, 3251, 3253, 3257,
				3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331,
				3343, 3347, 3359, 3361, 3371, 3373, 3389, 3391, 3407, 3413,
				3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511,
				3517, 3527, 3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571,
				3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643,
				3659, 3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727,
				3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821,
				3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907,
				3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967, 3989,
				4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057,
				4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129, 4133, 4139,
				4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231,
				4241, 4243, 4253, 4259, 4261, 4271, 4273, 4283, 4289, 4297,
				4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409,
				4421, 4423, 4441, 4447, 4451, 4457, 4463, 4481, 4483, 4493,
				4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583,
				4591, 4597, 4603, 4621, 4637, 4639, 4643, 4649, 4651, 4657,
				4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751,
				4759, 4783, 4787, 4789, 4793, 4799, 4801, 4813, 4817, 4831,
				4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937,
				4943, 4951, 4957, 4967, 4969, 4973, 4987, 4993, 4999, 5003,
				5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087,
				5099, 5101, 5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179,
				5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279,
				5281, 5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387,
				5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443,
				5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521,
				5527, 5531, 5557, 5563, 5569, 5573, 5581, 5591, 5623, 5639,
				5641, 5647, 5651, 5653, 5657, 5659, 5669, 5683, 5689, 5693,
				5701, 5711, 5717, 5737, 5741, 5743, 5749, 5779, 5783, 5791,
				5801, 5807, 5813, 5821, 5827, 5839, 5843, 5849, 5851, 5857,
				5861, 5867, 5869, 5879, 5881, 5897, 5903, 5923, 5927, 5939,
				5953, 5981, 5987, 6007, 6011, 6029, 6037, 6043, 6047, 6053,
				6067, 6073, 6079, 6089, 6091, 6101, 6113, 6121, 6131, 6133,
				6143, 6151, 6163, 6173, 6197, 6199, 6203, 6211, 6217, 6221,
				6229, 6247, 6257, 6263, 6269, 6271, 6277, 6287, 6299, 6301,
				6311, 6317, 6323, 6329, 6337, 6343, 6353, 6359, 6361, 6367,
				6373, 6379, 6389, 6397, 6421, 6427, 6449, 6451, 6469, 6473,
				6481, 6491, 6521, 6529, 6547, 6551, 6553, 6563, 6569, 6571,
				6577, 6581, 6599, 6607, 6619, 6637, 6653, 6659, 6661, 6673,
				6679, 6689, 6691, 6701, 6703, 6709, 6719, 6733, 6737, 6761,
				6763, 6779, 6781, 6791, 6793, 6803, 6823, 6827, 6829, 6833,
				6841, 6857, 6863, 6869, 6871, 6883, 6899, 6907, 6911, 6917,
				6947, 6949, 6959, 6961, 6967, 6971, 6977, 6983, 6991, 6997,
				7001, 7013, 7019, 7027, 7039, 7043, 7057, 7069, 7079, 7103,
				7109, 7121, 7127, 7129, 7151, 7159, 7177, 7187, 7193, 7207,
				7211, 7213, 7219, 7229, 7237, 7243, 7247, 7253, 7283, 7297,
				7307, 7309, 7321, 7331, 7333, 7349, 7351, 7369, 7393, 7411,
				7417, 7433, 7451, 7457, 7459, 7477, 7481, 7487, 7489, 7499,
				7507, 7517, 7523, 7529, 7537, 7541, 7547, 7549, 7559, 7561,
				7573, 7577, 7583, 7589, 7591, 7603, 7607, 7621, 7639, 7643,
				7649, 7669, 7673, 7681, 7687, 7691, 7699, 7703, 7717, 7723,
				7727, 7741, 7753, 7757, 7759, 7789, 7793, 7817, 7823, 7829,
				7841, 7853, 7867, 7873, 7877, 7879, 7883, 7901, 7907, 7919 };


/* reducir(n, factor) : funci�n para reducir, si es posible, el n�mero entero
 * 					(natural) n por el factor que se pasa por par�metro.
 * 					 En caso de que sea possible, se a�adir� el factor al
 * 					vector global factores[], se calcular� el n�mero de
 * 					veces del factor en el vector global pesos[] y se
 * 					incrementar� la variable global nFactores.
 * 					 La funci�n devuelve el n�mero (n) reducido por el factor
 * 					el n�mero de veces calculado. Si el n�mero no era divisible,
 * 					por el factor, lo devuelve igual al valor de entrada.
 */
unsigned int reducir(unsigned int n, unsigned int factor)
{
	unsigned int div = n;	
	unsigned int div2, mod2;

	GARLIC_divmod(div, factor, &div2, &mod2);
	if (mod2 == 0) {				// comprobar si es divisible
		factores[nFactores] = factor;	// a�adir el factor
		pesos[nFactores] = 0;
		do {
			div = div2;
			pesos[nFactores]++;			// contabilizar repeticiones
			GARLIC_divmod(div, factor, &div2, &mod2);
		} while ((div > 1) && (mod2 == 0));
		nFactores++;					// incrementar n�mero de factores
	}
	return div;						// devolver el n�mero reducido (o no)
}


/* factorizar1000(n) : funci�n para factorizar el n�mero natural (positivo)
 * 					que se pasa por par�metro, utilizando s�lo los 1000
 * 					primeros n�meros primos, registrados en el vector
 * 					global pk1000[].
 * 					 Los distintos factores se registrar�n en el vector
 * 					global fatores[], mientras que el n�mero de veces que
 * 					aparece cada factor se registrar� en el vector global
 * 					pesos[].
 * 					 La funci�n devuelve el residuo del n�mero a factorizar,
 * 					que ser� 1 si la factorizaci�n ha sido completa, o
 * 					diferente de 1 si parte del n�mero no se ha podido
 * 					factorizar con los 1000 primeros n�meros primos; el
 * 					n�mero parcial de factores obtenidos se registrar� en
 * 					la variable globla nFactores;
 */
unsigned int factorizar1000(unsigned int n)
{
	unsigned int i, div = n;

	i = 0;
	while ((div > 1) && (i < 1000) && (pK[i] <= div/2))
	{
		div = reducir(div, pK[i]);
		i++;					// siguiente factor fijo
	}
	return div;					// devolver residuo de la factorizaci�n
}
	
/* factorizar(n) : funci�n para factorizar el n�mero natural (positivo)
 * 					que se pasa por par�metro; los distintos factores se
 * 					registrar�n en el vector global fatores[], mientras
 * 					que el n�mero de veces que aparece cada factor se
 * 					registrar� en el vector global pesos[].
 * 					 La funci�n devuelve el n�mero de factores distintos
 * 					que se han obtenido, o cero si el n�mero no se puede
 * 					factorizar, es decir, en los casos especiales 0 y 1.
 * 					 Si se trata de un n�mero primo, el resultado ser�
 * 					un s�lo factor con peso igual a uno.
 * 					 No existe ning�n natural de 32 bits que presente
 * 					m�s de 9 factores distintos.
 */
unsigned int factorizar(unsigned int n)
{
	unsigned int div, fv;

	nFactores = 0;
	if ((n == 0) || (n == 1))			// casos triviales:
		return 0;							// no se pueden factorizar
		
	div = factorizar1000(n);			// factorizaci�n con factores fijos
	fv = pK[999] + 2;						// factor variable
	while ((div > 1) && (fv <= div/2))
	{
		div = reducir(div, fv);
		fv += 2;						// siguiente factor variable
	}
	if (div > 1)						// si todav�a queda dividendo,
	{
		factores[nFactores] = div;
		pesos[nFactores] = 1;			// a�adirlo como �ltimo factor
		nFactores++;
	}
	return nFactores;				// devolver n�mero de factores distintos
}




int desc(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	unsigned int i, j, k;
	unsigned int num, nfact;
	unsigned int num2, desp;
	
	if (arg < 0) arg = 0;			// limitar valor m�nimo del argumento 
	if (arg > 3) arg = 3;			// limitar valor m�ximo del argumento

	GARLIC_clear();
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa DESC  -  PID %2(%d) %0--\n", GARLIC_pid());

	desp = (arg == 2 ? 4 : 8);				// desplazamiento n�mero aleatorio
	i = 0;
	do
	{
		if (arg == 0) num = i;				// obtener n�mero a descomponer
		else
		{	num = GARLIC_random();			// casos de n�meros aleatorios
			if (arg >= 2)
				num = (num << desp) | (GARLIC_random() & ((1<<desp) - 1));
		}
		GARLIC_printf("%2\n\n= %0%d\n", num);	// imprimir n�mero a descomponer
		
		nfact = factorizar(num);
		if (nfact == 0)
			GARLIC_printf("\t%3|NO factorizable!");
		else
		{	if ((nfact == 1) && (pesos[0] == 1))
				GARLIC_printf("\t%1|Numero PRIMO!");
			else
			{	num2 = 1;
				for (j = 0; j < nfact; j++)	// imprimir factores y pesos
				{
					GARLIC_printf("%2 *%1%d %2^ %3%d\n", factores[j], pesos[j]);
					for (k = 0; k < pesos[j]; k++)
						num2 *= factores[j];
				}
				if (num2 != num)
					GARLIC_printf("%3|Descomposicion incorrecta!\n");
			}
		}
		i++;								// si (arg == 0), repetir 100 veces
	} while ((i <= 100) || (arg != 0)); 	// si (arg != 0), repetir siempre
	return 0;
}

int dotp(int arg){

	unsigned int n,i,j,mult, prod;
	
    // limitamos los valores del argumento
    if (arg < 0) arg = 0;
    else if (arg > 3) arg = 3;

    GARLIC_printf("%1********************************");
    GARLIC_printf("%1*                              *");
    GARLIC_printf("%1*      DOTP  -  PID (%d)        *", GARLIC_pid());
    GARLIC_printf("%1*                              *");
    GARLIC_printf("%1********************************\n");
    GARLIC_printf("%1Se van a generar dos vectores\ncon valores aleatorios [-10..10]\n");

    j = 1;                            // j = cálculo de 2 elevado a arg
    for (i = 0; i < arg; i++)
        j *= 2;

    n = 1 + j;                        // longitud n = 1 + 2^arg

    unsigned int vector1[n];
    unsigned int vector2[n];

    GARLIC_printf("%2La longitud de los vectores es:\n");
    GARLIC_printf("%21+2^arg --> 1+2^%d = %d\n", arg, n);

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
    GARLIC_printf("%2\nContenido del vector 1:\n");
    GARLIC_printf("%2[");
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

    GARLIC_printf("%2\nContenido del vector 2:\n");
    GARLIC_printf("%2[");
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
        GARLIC_printf("%0\nProducto escalar resultante:\n -%d\n", prod);
    }
    else 
    {
        GARLIC_printf("%0\nProducto escalar resultante:\n %d\n", prod);
    }
	GARLIC_printf("%3\nPrograma DOTP terminado\n");
	 
    return 0;

}

unsigned int dias[10];			/* variables globales no inicializadas */
unsigned int meses[10];

								/* variable global inicializada */
unsigned int anys[10] = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29};

int dpas(int arg)                /* funcion de inicio : no se usa 'main' */
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

int hola(int arg)                /* funci�n de inicio : no se usa 'main' */
{
    unsigned int i, j, iter;

    if (arg < 0) arg = 0;            // limitar valor m�ximo y 
    else if (arg > 3) arg = 3;        // valor m�nimo del argumento

                                    // esccribir mensaje inicial
    GARLIC_printf("-- Programa HOLA  -  PID (%d) --\n", GARLIC_pid());

    j = 1;                            // j = c�lculo de 10 elevado a arg
    for (i = 0; i < arg; i++)
        j *= 10;
                        // c�lculo aleatorio del n�mero de iteraciones 'iter'
    GARLIC_divmod(GARLIC_random(), j, &i, &iter);
    iter++;                            // asegurar que hay al menos una iteraci�n

    for (i = 0; i < iter; i++)        // escribir mensajes
        GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);

    return 0;
}


#define BLOCK 0x5F
#define POINT 0x0E
#define SPACE 0x00

#define MAX_FILS 16
#define MAX_COLS 32

#define F 'f'
#define P 'p'
#define B 'b'

struct character {
	char c;
	unsigned int x;
	unsigned int y;
	unsigned int color;
	unsigned int score;
	unsigned int xdir;
	unsigned int ydir;
};

struct character chars[4];
char lab[MAX_FILS][MAX_COLS];
unsigned int nchars, labx, laby, points;


/* Funcion para inicializar el laberinto, dibujando en pantalla el marco, los
	bloques aleatorios y los puntos; accede a las variables globales que
	definen la matriz (lab), la anchura del laberinto (labx) y la altura (laby)
*/
void init_lab()
{
	unsigned int i,j;
	unsigned int num_items, randx, randy;
	unsigned int div, mod;
	
	// Init horizontal borders
	for (j = 0; j < labx; j++)
	{
		lab[0][j] = B;
		lab[laby-1][j] = B;
		GARLIC_printchar(j, 4, BLOCK, 0);
		GARLIC_printchar(j, laby+3, BLOCK, 0);
	}
	
	// Init vertical borders
	for (i = 1; i < laby-1; i++)
	{
		lab[i][0] = B;
		lab[i][labx-1] = B;
		GARLIC_printchar(0, i+4, BLOCK, 0);
		GARLIC_printchar(labx-1, i+4, BLOCK, 0);
	}
	
	// Init empty positions
	for (i = 1; i < laby-1; i++)
	{
		for (j = 1; j < labx-1; j++)
			lab[i][j] = F;
	}
	
	// Calculate number of random blocks and points
	num_items = (25 * (labx-2) * (laby-2)) / 100;
	points = num_items;

	// Init random blocks
	i=0;
	while (i < num_items)
	{
		GARLIC_divmod(GARLIC_random(), labx, &div, &mod);
		randx = mod;
		GARLIC_divmod(GARLIC_random(), laby, &div, &mod);
		randy = mod;
		
		if (lab[randy][randx] != B)
		{
			GARLIC_printchar(randx, randy+4, BLOCK, 0);
			lab[randy][randx] = B;
			i++;
		}
	}

	// Init random points
	i=0;
	while (i < num_items)
	{
		// Obtener posiciones aleatorias
		GARLIC_divmod(GARLIC_random(), labx, &div, &mod);
		randx = mod;
		GARLIC_divmod(GARLIC_random(), laby, &div, &mod);
		randy = mod;
		
		// Comprobar que es una posici�n accesible
		if (lab[randy][randx] == F)
		{
			GARLIC_printchar(randx, randy+4, POINT, 0);
			lab[randy][randx] = P;
			i++;
		}
	}
	
	// Print Scores
	for (i = 0; i < nchars; i++)
	{
		GARLIC_printchar(i*6, 22, chars[i].c, chars[i].color);
		GARLIC_printchar((i*6)+1, 22, 0x1A, chars[i].color);
		GARLIC_printchar((i*6)+3, 22 , 0x10, chars[i].color);
	}
}

/* Funcion para obtener la posicion inicial de las letras y dibujarlas en
	pantalla */
void init_chars()
{
	unsigned int i = 0;
	unsigned int randx, randy;
	unsigned int div, mod;
	
	while (i < nchars)
	{
		// Obtener posiciones aleatorias
		GARLIC_divmod(GARLIC_random(), labx, &div, &mod);
		randx = mod;
		GARLIC_divmod(GARLIC_random(), laby, &div, &mod);
		randy = mod;
		
		if (lab[randy][randx] == F)
		{
			// Escribir en mapa
			lab[randy][randx] = chars[i].c; 
			
			// Guadar valores en la estructura
			chars[i].x = randx;
			chars[i].y = randy;
			
			// Escribir en pantalla
			GARLIC_printchar(randx, randy+4, chars[i].c, chars[i].color);
			
			// Set movement direction
			if (randx < labx/2) chars[i].xdir = 1;
			else 				chars[i].xdir = -1;
			chars[i].ydir = 0;
			
			i++;
		}
	}
}


/* Inicializaci�n de las estructuras */
void init_puppets()
{
	int i;
	for (i = 0; i < nchars; i++)
	{
		chars[i].c = 0x21 + i;
		chars[i].color = i;
		chars[i].score = 0;
	}
}


/* Actualizaci�n de puntos de una cierta letra segun el indice (i) de la tabla
	de estructuras chars */
void update_score(unsigned int i)
{
	unsigned int score, div, mod;
	
	score = chars[i].score;
	if (score > 9) {
		GARLIC_divmod(score, 10, &div, &mod);
		GARLIC_printchar((i*6)+2, 22, 0x10+div, chars[i].color);
		GARLIC_printchar((i*6)+3, 22, 0x10+mod, chars[i].color);
	} else {
		GARLIC_printchar((i*6)+3, 22, 0x10+score, chars[i].color);
	}
}

/* Funcion que implementa el algoritmo de movimiento de las letras, mueve una
	posicion a cada llamada */
void mov_chars()
{
	unsigned int i, j=0, div, mod;
	unsigned int newx, newy;
	
	for (i = 0; i < nchars; i++)
	{
		newx = chars[i].x + chars[i].xdir;
		newy = chars[i].y + chars[i].ydir;
		GARLIC_divmod(GARLIC_random(), 4, &div, &mod);
		if (mod == 3 || lab[newy][newx] == B)
		{	/* cambio de direcci�n si hay choque o con una probabilidad de 1/4 */
			j = 0;
			GARLIC_divmod(GARLIC_random(), 4, &div, &mod);
			do									// genera direcci�n aleatoria
			{
				switch (mod)
				{
					case 0:
						chars[i].xdir=1;
						chars[i].ydir=0;
						break;
					case 1:
						chars[i].xdir=0;
						chars[i].ydir=1;
						break;
					case 2:
						chars[i].xdir=-1;
						chars[i].ydir=0;
						break;
					case 3:
						chars[i].xdir=0;
						chars[i].ydir=-1;
						break;
				}
				newx = chars[i].x + chars[i].xdir;		// nueva posici�n seg�n
				newy = chars[i].y + chars[i].ydir; 	// direcci�n aleatoria
				mod = (mod + 1) % 4;				// siguiente direcci�n
				j++;								// contador de intentos
			} while (j < 4 && lab[newy][newx] == B);	// hasta 4 intentos o via libre
		}
		if (lab[newy][newx] == P || lab[newy][newx] == F)
		{
			GARLIC_printchar(chars[i].x, chars[i].y+4, (char) SPACE, 0);
			lab[chars[i].y][chars[i].x] = F;
			
			chars[i].x = newx;
			chars[i].y = newy;
			
			if (lab[newy][newx] == P)
			{
				chars[i].score++;
				update_score(i);
				points--;
			}
			lab[newy][newx] = B;
			GARLIC_printchar(chars[i].x, chars[i].y+4, chars[i].c, chars[i].color);
		}
	}
}


/* Programa principal */
int labe(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	if (arg < 0) arg = 0;			// limitar valor m�nimo del argumento 
	if (arg > 3) arg = 3;			// limitar valor m�ximo del argumento

	GARLIC_clear();
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa LABE  -  PID %2(%d) %0--\n", GARLIC_pid());
	
	nchars = arg + 1;
	labx = nchars*8;
	laby = 16;
	
	init_puppets();
	init_lab();
	init_chars();
	do
	{
		mov_chars();
		GARLIC_delay(0);
	} while (points > 0); 	// repetir mientras queden puntos
	return 0;
}

int pong(int arg)                /* funci�n de inicio : no se usa 'main' */
{
    int x, y, dirx, diry;

    if (arg < 0) arg = 0;            // limitar valor m�nimo del argumento 
    if (arg > 3) arg = 3;            // limitar retardo m�ximo 3 segundos

    GARLIC_clear();
                                    // esccribir mensaje inicial
    GARLIC_printf("-- Programa PONG  -  PID %2(%d) %0--\n", GARLIC_pid());

    x = 0; y = 0;                    // posici�n inicial
    dirx = 1; diry = 1;                // direcci�n inicial
    GARLIC_printchar( x, y, 95, arg);    // escribir caracter por primera vez
    do
    {
        GARLIC_delay(arg);
        GARLIC_printchar( x, y, 0, arg);    // borrar caracter anterior
        x += dirx;
        y += diry;                        // avance del caracter
        if ((x == 31) || (x == 0))
            dirx = -dirx;                // rebote izquierda o derecha
        if ((y == 23) || (y == 0))
            diry = -diry;                // rebote arriba o abajo
        if ((x == 0) && (y == 0))
            y = 1;                        // forzar posiciones (x+y) impares
        else if ((x == 0) && (y == 1))
        {    y = 0;                        // forzar posiciones (x+y) pares
            diry = 1;                        // forzar direcci�n derecha
        }
        GARLIC_printchar( x, y, 95, arg);    // reescribir caracter
    } while (1);                 // no acaba nunca
    return 0;
}

/* definicion de variables globales */
const unsigned int numeros[] = { 0, 3, 5, 7,
								11, 17, 23, 37,
								127, 227, 233, 257,
								1019, 2063, 3001, 4073,
								15099, 26067, 37109, 68139,
								481021, 573949, 721905, 951063, 
								1048576, 2131331, 3910491, 5110611,
								10631069, 16777216, 18710911, 20931097,
								268435456, 471103972, 631297553, 825266928,
								1153631781, 2879320213, 3127223846, 4294967295};
				
char * const frases[] = {"Por fin lleg�. Salimos en seguida para Carmona.\n",
					"El chofer alzaba una ceja, pisaba el acelerador y dec�a, ",
					"volviendose a medias hacia nosotras:\n",
					"\t-Podridita que est� la carretera.\n",
					"Me preguntaba Mrs. Adams y yo le traducia: ",
					"<<La carretera, que esta podrida.>> ",
					"Ella miraba por un lado y hacia los comentarios mas raros. ",
					"�Como puede pudrirse una carretera?\n",
					"Es Carmona una ciudad toda murallas y tuneles, la mas fuerte de Andalucia en los tiempos de Jul",
					"io Cesar. Y fuimos directamente a la ne-\ncropolis. ",
					"Un chico de aire avispado fue a avisar al guardia, que",
					" era un hombre flaco, alto, sin una onza de grasa, ",
					"con el perfil de una medalla romana. ",
					"Aparentaba cincuenta y cinco a�os. ",
					"<<A la paz de Dios>>, ",
					"dijo cuando llego.\n"};

int prnt(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	unsigned int i, j;
	
	if (arg < 0) arg = 0;			// limitar valor m�ximo y 
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento
	
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa PRNT  -  PID (%d) --\n", GARLIC_pid());
	
	GARLIC_printf("\nPrueba juego de caracteres:\n");
	for (i = 32; i < 128; i++)		// imprimir todo el repertorio de c�digos
		GARLIC_printf("%c", i);		// ASCII visibles (>31) y est�ndar (<128)

	GARLIC_printf("\n\nPrueba numeros:\n");
	for (i = 0; i < 10; i++)
	{
		for (j = 0; j < arg+1; j++)
			GARLIC_printf("%d (0x%x)\t", numeros[i*4+j], numeros[i*4+j]);
		GARLIC_printf("\n");
	}

	GARLIC_printf("\n\nPrueba frases:\n");
	for (i = 0; i < (arg+1)*4; i++)
		GARLIC_printf("%s", frases[i]);
	
	GARLIC_printf("\n\nPruebas mixtas::\n");
	GARLIC_printf("\n%%a%%\tprueba %s: %c%d\n%%", "string%%char", 64, 0);
	i = GARLIC_random();
	GARLIC_printf("b%%\taleatorio decimal: %d%%\n\t\t  hexadecimal: 0x%x%%\n", i, i);
	GARLIC_printf("%%c%%\tcodigos de formato reconocidos: %%c %%d %%x %%s\n", i, 0);
	GARLIC_printf("%%d%%\tcodigos de formato no reconocidos: %%i %%f %%e %%g %%p\n\n");

	return 0;
}

