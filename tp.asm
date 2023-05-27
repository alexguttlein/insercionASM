;Ordenamiento por método de Inserción

;Dado un archivo que contiene n números en BPF c/signo de 8 bits (n <= 30) se pide codificar en
;assembler Intel 80x86 un programa que imprima por pantalla que movimiento se realiza (por ejemplo
;“Iniciando el ciclo de i menor a la longitud del vector”) y contenido de dicho archivo ordenado en forma
;ascendente o descendente de acuerdo a lo que elija el usuario, usando un algoritmo de ordenamiento
;basado en el método de inserción.

;   procedure insercion (int[] vector)
;       i ← 1
;       while i < length(vector)
;           j ← i
;           while j > 0 and vector[j-1] > vector[j]
;               swap vector[j] and vector[j-1]
;               j ← j - 1
;           end while
;           i ← i + 1
;       end while
;   end procedure

;El método de ordenamiento por inserción es una manera muy natural de ordenar para un ser humano.
;Inicialmente se tiene un solo elemento, que obviamente es un conjunto ordenado. Después, cuando
;hay k elementos ordenados de menor a mayor, se toma el elemento k+1 y se compara con todos los
;elementos ya ordenados, deteniéndose cuando se encuentra un elemento menor (todos los elementos
;mayores han sido desplazados una posición a la derecha) o cuando ya no se encuentran elementos
;(todos los elementos fueron desplazados y este es el más pequeño). En este punto se inserta el
;elemento k+1 debiendo desplazarse los demás elementos

;Nota: no es correcto generar el archivo con un editor de textos de forma tal que cada registro sea una tira de 16
;caracteres 1 y 0. Se aconseja el uso de un editor hexadecimal.


global	main
extern  puts 
extern  printf
extern  fopen
extern  fclose
extern  fread 
extern  sscanf

section	.data
    fileName        db  "archivo1.dat",0
    modo            db  "rb",0
    msjErrorOpen	db	"Error apertura de archivo.",0,10

	msjDebug		db	"leyendo...",0

	longRegistro	dw	0 
	msjLong			db	"El registro tiene %hi valores",10,0

	;debugFormat		db	"numero leido: %hi",10,0
	debugFormat		db	"%hi  ",0
	debugRsi		db	"rsi: %i",10,0
	debugVector		dw	1,2,3,4,5

section	.bss
    registro		resb	30
	idArchivo       resq    1
    registroValido  resb    1
	
	valorLeido		resw	1
	vectorLeido		resb	30
	vectorOrdenado	resb	30
	
section	.text
main:
    call	aperturaArchivos
	cmp		byte[registroValido],'n'
	je		finProg

	call	leerRegistro
	call	leerVector

	call	cierreArchivo

;mov		rcx,msjLong
;mov		dx,word[longRegistro]
;sub		rsp,32
;call	printf
;add		rsp,32

finProg:
ret

;***************************************************************

;-------------------------
;APERTURA ARCHIVO
;-------------------------
aperturaArchivos:
	mov		byte[registroValido],'n'

	mov		rcx,fileName
	mov		rdx,modo
	sub		rsp,32
	call	fopen
	add		rsp,32

	cmp		rax,0
	jle		errorOpen
	mov		qword[idArchivo],rax

    mov		byte[registroValido],'s'
	jmp		openValido

errorOpen:
	mov		rcx,msjErrorOpen
	sub		rsp,32
	call	puts
	add		rsp,32
openValido:
ret

;***************************************************************

;-------------------------
;LEER REGISTRO
;-------------------------
leerRegistro:
	mov		rsi,0
leerSiguiente:
	mov		rcx,registro 		;registro entrada
	mov		rdx,1				;longitud registro
	mov		r8,1				;bloque: siempre va 1
	mov		r9,[idArchivo]		;idArchivo
	sub		rsp,32
	call	fread
	add		rsp,32

	cmp		rax,0
	jle		finLectura

	mov		rcx,[registro]
	mov		word[valorLeido],cx	;me guardo el valor leido en una variable

	;mov		word[vectorLeido+rsi],cx

;mov		rcx,debugRsi
;mov		rdx,rsi
;sub		rsp,32
;call	printf
;add		rsp,32

;mov		rcx,debugFormat
;mov		dx,word[vectorLeido+rsi]
;sub		rsp,32
;call	printf
;add		rsp,32

;mov 	rcx,msjDebug
;sub		rsp,32
;call	puts  
;add		rsp,32
	push	rsi
	call	ordenarValores
	pop		rsi

	add		rsi,2

	add		word[longRegistro],1	;aumento el conteo de longitud del registro
	jmp		leerSiguiente			;leo el siguiente valor
finLectura:
ret

;***************************************************************

;-------------------------
;ORDENAR VALORES
;-------------------------
ordenarValores:
	sub		rsi,rsi
compararSiguiente:	
	sub		rax,rax	
	mov		ax,word[longRegistro]
	imul	ax,2

	cmp		rsi,rax						;comparo long de registro con rsi para saber si estoy en una posicion sin valor
	je		insertarValor				;si no hay siguiente registro, se inserta directo al final

;falta comparar si el valor leido es menor al del vector
	


	add		rsi,2
	jmp		compararSiguiente			;si es mayor, se tiene que comparar con el siguiente valor

insertarValor:	
	sub		rcx,rcx
	mov		cx,word[valorLeido]
	mov		word[vectorOrdenado+rsi],cx
ret

;***************************************************************

;-------------------------
;CIERRE ARCHIVO
;-------------------------
cierreArchivo:
	mov		rcx,[idArchivo]
	sub		rsp,32
	call	fclose
	add		rsp,32
ret

;***************************************************************

;-------------------------
;LEER VECTOR
;-------------------------
leerVector:
;prueba para revisar si el vector tiene todos los valores
	mov		rsi,0
	sub		rcx,rcx
	mov		cx,word[longRegistro]
inicioVec:
	push	rcx

	mov		rcx,debugFormat
	mov		dx,word[vectorOrdenado+rsi]
	sub		rsp,32
	call	printf
	add		rsp,32

	add		rsi,2
	pop		rcx
		loop inicioVec
ret