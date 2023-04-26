/*------------------------------------------------------------------------------

	"GARLIC_API.h" : cabeceras de funciones del API (Application Program
					Interface) del sistema operativo GARLIC 2.0 (c�digo fuente
					disponible en "GARLIC_API.s")

------------------------------------------------------------------------------*/
#ifndef _GARLIC_API_h_
#define _GARLIC_API_h_


	/* GARLIC_pid: devuelve el identificador del proceso actual */
extern int GARLIC_pid();


	/* GARLIC_random: devuelve un n�mero aleatorio de 32 bits */
extern int GARLIC_random();


	/* GARLIC_divmod: calcula la divisi�n num / den (numerador / denominador),
		almacenando el cociente y el resto en las posiciones de memoria indica-
		das por *quo y *mod, respectivamente (pasa resultados por referencia);
		la funci�n devuelve 0 si la divisi�n es correcta, o diferente de 0
		si hay alg�n problema (divisi�n por cero).
		ATENCI�N: s�lo procesa n�meros naturales de 32 bits SIN signo. */
extern int GARLIC_divmod(unsigned int num, unsigned int den,
							unsigned int * quo, unsigned int * mod);


	/* GARLIC_printf: escribe un string en la ventana del proceso actual,
		utilizando el string de formato 'format' que se pasa como primer
		par�metro, insertando los valores que se pasan en los siguientes
		par�metros (hasta 2) en la posici�n y forma (tipo) que se especifique
		con los marcadores incrustados en el string de formato:
			%c	: inserta un car�cter (seg�n c�digo ASCII)
			%d	: inserta un natural (32 bits) en formato decimal
			%x	: inserta un natural (32 bits) en formato hexadecimal
			%s	: inserta un string
			%%	: inserta un car�cter '%' literal
		Adem�s, tambi�n procesa los metacar�cteres '\t' (tabulador) y '\n'
		(salto de l�nia), junto con c�digos de formato para cambiar el color
		actual de los caracteres:
			%0	:	fija el color blanco
			%1	:	fija el color amarillo
			%2	:	fija el color verde
			%3	:	fija el color rojo
		El �ltimo color seleccionado ser� persistente en las siguientes llamadas
		a la funci�n. */
extern void GARLIC_printf(char * format, ...);


	/* GARLIC_printchar: escribe un car�cter (c), especificado como c�digo de
		baldosa (c�digo ASCII - 32), en la posici�n (vx, vy) de la ventana del
		proceso actual, donde (vx) tiene rango [0..31] y (vy) tiene rango
		[0..23], con el color especificado por par�metro (0 -> blanco,
		1 -> amarillo, 2 -> verde, 3 -> rojo) */
extern void GARLIC_printchar(int vx, int vy, char c, int color);


	/* GARLIC_printmat: escribe una matriz de car�cteres (m) en la posici�n
		(vx, vy) de la ventana del proceso actual, donde (vx) tiene rango
		[0..31] y (vy) tiene rango [0..23], con el color especificado por
		par�metro (0 -> blanco,	1 -> amarillo, 2 -> verde, 3 -> rojo);
		 la matriz consistir� en 8x8 posiciones	con c�digos ASCII, aunque las
		posiciones que contengan un c�digo inferior a 32 (espacio en blanco) no
		modificar�n las casillas correspondientes de la ventana. */
extern void GARLIC_printmat(int vx, int vy, char m[][8], int color);


	/* GARLIC_delay: retarda la ejecuci�n del proceso actual el n�mero de
		segundos que se especifica por el par�metro (nsec); el rango permitido
		ser� de [0..600] (max. 10 minutos); el valor 0 provocar� que el proceso
		se desbanque y pase a READY, lo cual corresponde a un tiempo de retardo
		muy peque�o, aunque no se puede determinar exactamente cu�l (el que
		resulte de volver a restaurar el proceso). */
extern void GARLIC_delay(unsigned int nsec);


	/* GARLIC_clear: borra todo el contenido de la ventana del proceso que
		invoca esta funci�n. La siguiente llamada a la funci�n GARLIC_print
		empezar� a escribir a partir de la primera fila de la ventana. */
extern void GARLIC_clear();


	/* GARLIC_getstring: recibe por par�metro la direcci�n de u vector de 
		caracteres donde guardar el string introducido por teclado, as� como el
		n�mero m�ximo de caracteres que puede contener el vector (excluido el 
		centinela), y devuelve como resultado el n�mero de caracteres le�dos 
		finalmente (excluido el centinela).
	*/
extern int GARLIC_getstring(char * string, int max_char);


	/* GARLIC_getXUbuttons: permite a los programas realizar una consulta no 
		bloqueante del estado de los botones X e Y.
			� Bit 0: =1 boton pulsado, =0 boton no pulsado.
			� Bit 1: =1 boton pulsado, =0 boton no pulsado.
	*/
extern char GARLIC_getXYbuttons();



#endif // _GARLIC_API_h_
