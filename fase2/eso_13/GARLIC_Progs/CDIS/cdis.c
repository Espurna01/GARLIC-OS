/*------------------------------------------------------------------------------

	"CDIS.c" : programa pel sistema operatiu GARLIC 2.0;
	
	Converteix un número de metros aleatori (entre 0 i 10^(arg+1)) a milles,
	iardes i peus. Presenta el resultat amb 5 xifres decimals.
	
	autor: mireia.gasco@estudiants.urv.cat

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */

void mostrar_zeros(int);

int _start(int arg)				
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


    //generem un número aleatori de metres
    GARLIC_printf("Calculant metres (aleatori)...\n");
	GARLIC_delay(1);
    GARLIC_divmod(GARLIC_random(), j, &quocient, &metres);
    GARLIC_printf("Calcul finalitzat.\n");
    GARLIC_printf("\nNumero de metres: %d\n", metres);


    //càlcul milles
    GARLIC_printf("\nCalculant conversio a milles...\n");
	GARLIC_delay(1);
    conv = metres * 62;
    GARLIC_divmod(conv, 100000, &quocient, &residu);
    GARLIC_printf("%d metres = %d.",metres, quocient);
    mostrar_zeros(residu);
    GARLIC_printf("%d milles\n", residu);
	

    //càlcul iardes
    GARLIC_printf("\nCalculant conversio a iardes...\n");
	GARLIC_delay(1);
    conv = metres * 109361;
    GARLIC_divmod(conv, 100000, &quocient, &residu);
    GARLIC_printf("%d metres = %d.", metres, quocient);
    mostrar_zeros(residu);
    GARLIC_printf("%d iardes\n", residu);

    //càlcul peus
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

    //calculem el número de xifres que té el número
    GARLIC_divmod(num, j, &quocient, &residu);
    while(quocient != 0) {
        j *= 10;
        numXifres++;
        GARLIC_divmod(num, j, &quocient, &residu);
    }

    //si el número de xifres decimals és menor que 5
    //escribim els zeros que falten després de la coma
    if(numXifres < 5){

        numXifres = 5 - numXifres;

        while(numXifres > 0) {
            GARLIC_printf("0");
            numXifres--;
        }
    }
}