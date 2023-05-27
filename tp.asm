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

	longRegistro	dw	0 
	msjLong			db	"El registro tiene %hi valores",10,0

	msjMovimiento	db	"Se desplaza el valor %hi desde la posicion %hi a la posicion %hi",10,0
	msjInsercion	db	"Se inserta el valor %hi en la posicion %hi",10,0
	saltoDeLinea	db	" ",10,0
	caracterVacio	dw	0

	debugFormat		db	"%hi ",0
	debugRsi		db	"rsi: %i",10,0
	msjDebug		db	"leyendo...",0

section	.bss
    registro		resw	30
	idArchivo       resq    1
    registroValido  resb    1
	
	valorLeido		resw	1
	vectorOrdenado	resw	30
	
section	.text
main:
    call	aperturaArchivo
	cmp		byte[registroValido],'n'
	je		finProg

	call	procesarRegistro
	;call	leerVector

	call	cierreArchivo

finProg:
ret

;***************************************************************

;-------------------------
;APERTURA ARCHIVO
;-------------------------
aperturaArchivo:
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
;PROCESAR REGISTRO
;-------------------------
procesarRegistro:
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
	sub		rbx,rbx
compararSiguiente:	
	sub		rax,rax	
	mov		ax,word[longRegistro]
	imul	ax,2

	cmp		rsi,rax						;comparo long de registro con rsi para saber si estoy en el final del vector
	je		insertarValor				;si no hay siguiente registro, se inserta directo al final

	mov		rdi,rax						;guardo en el rdi la posicion final del vector

	mov		bx,word[valorLeido]
	cmp		word[vectorOrdenado+rsi],bx	;comparo valor del vector con valor leido
	jg		esMenor

	add		rsi,2
	jmp		compararSiguiente			;si es mayor, se tiene que comparar con el siguiente valor

esMenor:
	call	moverValores

insertarValor:	
	sub		rcx,rcx
	mov		cx,word[valorLeido]
	mov		word[vectorOrdenado+rsi],cx

	push	rdi
	call	imprimirInsercion
	pop		rdi

ret

;***************************************************************

;-------------------------
;MOVER VALORES
;-------------------------
moverValores:
	sub		rax,rax
moverSiguiente:
	mov		ax,word[vectorOrdenado+rdi]		;me guardo el valor que hay al final del vector
	mov		word[vectorOrdenado+rdi+2],ax	;muevo el ultimo valor a la posicion siguiente del vector
	
	mov		ax,word[caracterVacio]
	mov		word[vectorOrdenado+rdi],ax

	cmp		rsi,rdi
	je		finMoverValores					;si rsi = rdi es porque llegue a la posicion donde debo insertar
	
	push	rdi
	push	rsi
	call	leerVector
	call	imprimirMovimiento
	call	leerVector
	pop		rsi
	pop		rdi
	
	sub		rdi,2
	jmp		moverSiguiente

finMoverValores:
	push	rsi
	call	leerVector
	pop		rsi
ret

;***************************************************************

;-------------------------
;IMPRIMIR MOVIMIENTO
;-------------------------
imprimirMovimiento:
	sub		rax,rax
	sub		rbx,rbx

	sub		rdi,2		;me posiciono en el elemento de la lista que quiero mover (en words)
	
	mov		rax,rdi
	mov		rbx,2
	
	idiv	bl			;divido por 2 para tener la posicion del elemento a desplazar

	mov		rsi,rax		;guardo la posicion actual del elemento a desplazar
	add		rax,1		;guardo la posicion a la que se movio el elemento

	mov		rcx,msjMovimiento
	mov		dx,word[vectorOrdenado+rdi]
	mov		r8,rsi
	mov		r9,rax
	sub		rsp,32
	call	printf
	add		rsp,32
ret

;***************************************************************

;-------------------------
;IMPRIMIR INSERCION
;-------------------------
imprimirInsercion:
	sub		rax,rax
	sub		rbx,rbx

	mov		rax,rsi
	mov		rbx,2	
	idiv	bl		

	mov		rcx,msjInsercion
	mov		dx,word[vectorOrdenado+rsi]
	mov		r8,rax
	sub		rsp,32
	call	printf
	add		rsp,32

	call	leerVector
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
;LEER VECTOR AL MOVER
;-------------------------
leerVector:
;prueba para revisar si el vector tiene todos los valores
	mov		rsi,0
	sub		rcx,rcx
	sub		rdx,rdx
	mov		cx,word[longRegistro]
	add		cx,1
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

	mov		rcx,saltoDeLinea
	sub		rsp,32
	call	puts
	add		rsp,32
ret