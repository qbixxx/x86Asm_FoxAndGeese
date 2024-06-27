global main

extern puts
extern sprintf
extern printf
extern sscanf
extern gets
extern fopen
extern fopen
extern fread
extern fclose
extern fwrite
;posición = (fila * número_de_columnas) + columna
;=(1 * 7)+2
section .data
    eL                    db    "   ",0
    ;diff                  dd    1
    diff                  dq    1
    mjeDiff               db    "Diferencia: %i",10,0
    nameZorro             db    "Zorro",0
    nameOca               db    "Oca",0
    mjePosDestino         db    "Posicion destino: %i",10,0  
    mjePosZorro           db    "Posicion Zorro: %i",10,0  
    mjeFin                db    "> Fin de programa",10,0
    mjeTurnoZorro         db    "Turno de Zorro",10,0
    mjeTurnoOca           db    "Turno de Oca",10,0
    zorroCounter times 49 db    0
    mode                  db    "rb",0
    fileName              db    "tablero.bin",0
    mjeOk                 db    10,"> Archivo abierto con exito!",10,10,0
    mjeErrorOpen          db    10,"> Error en apertura de archivo",10,10,0
    mjeErrorLectura       db    10,"> Error en la lectura del archivo",10,10,0
    tamTablero            db    49
    mjeChar               db    " %c ",0
    nL                    db    10,0
    line                  db    7
    mjeFila               db    10,"Ingrese fila (de 0 a 6):",10,0
    mjeColum              db    "Ingrese columna (de 0 a 6):",10,0

    mjePiezaPos           db    "En la posicion %i hay un %c",10,0

    mjeNoHayOca           db    "En la posicion seleccionada no hay una oca",10,0

    prueba  db "prueba",10,0
    
    formatNum       db      "%i",0
    indexer         db      " %i ",0

    mjeCoord        db      10,"Se mueve a fila %i, columna %i",10,0
    
    mjePosInvalid   db      "Posicion no valida",10,0

    ;Registro del archivo
    registro times  0     db    "" 
    tablero times   49    db    0

section .bss
    
    ;posZorro        resb    8
    ;posOca          resb    8
    posZorro        resq    1
    posOca          resq    1
    bufferCol       resb    8
    bufferFil       resb    8
    buffer          resb    500
    fileHandle      resq    1
    bufferTablero   resb    96; 49*2
    charActual      resq    1

    intCol         resq     1
    intFil         resq     1

    ;posicion        resb    10
    posDestino      resq    1   

    jugTurno        resb    8

section .text
main:
    ;Abro archivo
    mov     rdi,fileName
    mov     rsi,mode
    sub     rsp,8
    call    fopen
    add     rsp,8
    
    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError ; Error de apertura?

    ; Mje exito de apertura
    mov     rdi,mjeOk
    sub     rsp,8
    call    printf 
    add     rsp,8

    ;Leo archivo

    mov     rdi,registro
    mov     rsi,49
    mov     rdx,1
    mov     rcx,qword[fileHandle]
    sub     rsp,8
    call    fread
    add     rsp,8

    cmp     rax,0
    ;jle     endProg
    jle     errorLectura
    jg      noErrorLectura

    errorLectura:
    mov     rdi,mjeErrorLectura
    sub     rsp,8
    call    puts
    add     rsp,8
    jmp     endProg

    noErrorLectura:

    ;lectura de registro exitosa:
   
    mov     r12,[nameZorro]
    mov     [jugTurno],r12

    ;call    printTablero

    gameLoop: 
    
    call    printTablero
;-------------------------------------------------------------------------------
;FALTA
    ;Luego del tablero, en una linea mostramos el comando para salir sin guardar
    ;y el comando para guardar y salir
    ;-->Debería ser una combinacion de fila y columna para cada una
;-------------------------------------------------------------------------------
    mov     r12,[jugTurno]
    
    cmp     r12,[nameZorro]
    jne     notZorro
    ;call    findPosZorro
    call    turnoZorro
    ;aca puedo CHECHEAR luego del movimiento, si zorro gano, seteando r15 = 1
    ;si gano ZORRO mando un mensaje, luego acá bifurco a "endMain:"
    jmp     sigTurno
    
    notZorro:

    ;cmp     r12,[nameOca]
    call    turnoOca
    ;aca puedo CHECHEAR luego del movimiento, si zorro gano, seteando r15 = 1
    ;si gano OCA mando un mensaje, luego acá bifurco a "endMain:"

    sigTurno:
;----------------------------------------------------------------
;FALTA
    ; CHECKEAR SI ZORRO O OCAS GANARON, para cortar el loop
    ;--- Las ocas rodearon al zorro
    ;--- El zorro se comio 12 ocas
;----------------------------------------------------------------
    loop    gameLoop

    ;call    printTablero
    ;
    ;cmp
;
    ;call    turnoZorro
    ;
    ;call    findPosZorro
;
    ;call    endProg

;endMain:
    ;call    endProg
ret
  

turnoOca:
    
    mov     rdi,mjeTurnoOca
    sub     rsp,8
    call    puts
    add     rsp,8
    
    call    checkPosOca

    mov     rdi,mjeCoord
    mov     rsi,[intFil]
    mov     rdx,[intCol]
    sub     rsp,64
    call    printf
    add     rsp,64

    ;calculo la posicion: posición = (fila * número_de_columnas) + columna

;    call posCaidaOca; a hacer


    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posDestino],rax
    
    mov     rdi,mjePosDestino
    mov     rsi,[posDestino]
    sub     rsp,64
    call    printf
    add     rsp,64
    
    mov     rbx,[posDestino]
    mov     al,byte[tablero+rbx]
    cmp     al,"_"
    jne     badPosZorro

        
    xor     r12,r12
    mov     r12,[posDestino]
    mov     rbx,[posZorro]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    cmp     qword[diff],-7;norte
    je      moverOca
    cmp     qword[diff],7;sur
    je      moverOca
    cmp     qword[diff],1;este
    je      moverOca
    cmp     qword[diff],-1;oeste
    je      moverOca
    cmp     qword[diff],8;sur este
    je      moverOca
    cmp     qword[diff],-8;nor oeste
    je      moverOca
    cmp     qword[diff],6;sur oeste
    je      moverOca
    cmp     qword[diff],-6;nor este
    je      moverOca


    
    moverOca:
  
    xor     rbx,rbx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    xor     r14,r14
    mov     rbx,[posDestino]
    mov     rdi,mjePiezaPos;
    mov     rsi,[posDestino]
    mov     al,[tablero+rbx]
    mov     dl,al
    sub     rsp,64
    call    printf
    add     rsp,64

    mov     rax,[posZorro]
    mov     byte[tablero+rax],"_"
    mov     byte[tablero+rbx],"X";


    

    mov     r13,[nameOca]
    mov     [jugTurno],r13
ret


checkPosOca:

    sub     rsp,8
    call    pedirPos
    add     rsp,8

    ;encuentro e imprimo la posicion del zorro        

    xor     rbx,rbx
    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posDestino],rax


    mov     rbx,[posDestino]
    

    cmp     byte[tablero+rbx],"O"

    jne     badPosOca
    je      outOca
    badPosOca:
    mov     rdi,mjeNoHayOca
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     checkPosOca

    outOca:


ret


findPosZorro:

    ;encuentro e imprimo la posicion del zorro

    xor     rbx,rbx

    l:

    cmp     byte[tablero+rbx],"X"

    jne     sig
    mov     [posZorro],rbx
    jmp     outP
    sig:

    inc     rbx
    cmp     rbx,49
    je      outP

    jmp     l

    outP:

    mov     rdi,mjePosZorro    
    mov     rsi,[posZorro]
    sub     rsp,64
    call    printf
    add     rsp,64
ret

turnoZorro:
    
    mov     rdi,mjeTurnoZorro
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64  

    sub     rsp,8
    call    findPosZorro    ;se setea posZorro
    add     rsp,8

    pedirPosZorro:
    sub     rsp,8
    call    pedirPos        ; se setean intFil intCol
    add     rsp,8


;;; chequear combinaciones de fila y columna para salir y guardar

    mov     rdi,mjeCoord
    mov     rsi,[intFil]
    mov     rdx,[intCol]
    sub     rsp,64
    call    printf
    add     rsp,64

    ;calculo la posicion: posición = (fila * número_de_columnas) + columna
    ;(fila y columna van de 0 a 6) --> posDestino va de 0 a 48

    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posDestino],rax
    
    mov     rdi,mjePosDestino
    mov     rsi,[posDestino]
    sub     rsp,64
    call    printf
    add     rsp,64
    
    mov     rbx,[posDestino]
    mov     al,byte[tablero+rbx]
    cmp     al,"_"
    jne     badPosZorro

        
    ;xor     r12,r12
    mov     r12,[posDestino]
    mov     rbx,[posZorro]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    cmp     qword[diff],-7;norte
    je      moverZorro
    cmp     qword[diff],7;sur
    je      moverZorro
    cmp     qword[diff],1;este
    je      moverZorro
    cmp     qword[diff],-1;oeste
    je      moverZorro
    cmp     qword[diff],8;sur este
    je      moverZorro
    cmp     qword[diff],-8;nor oeste
    je      moverZorro
    cmp     qword[diff],6;sur oeste
    je      moverZorro
    cmp     qword[diff],-6;nor este
    je      moverZorro


        ;agregar caso de salto del zorro sobre oca.
        ;diferencia mas grande [diff] && [diff/2] == O


    badPosZorro:
    mov     rdi,mjePosInvalid
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     pedirPosZorro
    
    moverZorro:
  
    xor     rbx,rbx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    xor     r14,r14
    mov     rbx,[posDestino]
    mov     rdi,mjePiezaPos;
    mov     rsi,[posDestino]
    mov     al,[tablero+rbx]
    mov     dl,al
    sub     rsp,64
    call    printf
    add     rsp,64

    mov     rax,[posZorro]
    mov     byte[tablero+rax],"_"
    mov     byte[tablero+rbx],"X";


    

    mov     r13,[nameOca]
    mov     [jugTurno],r13
ret

pedirPos:
    pedirFila:
    mov     rdi,mjeFila
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64

    mov     rdi,bufferFil
    sub     rsp,8
    call    gets
    add     rsp,8

    mov     rdi,bufferFil
    mov     rsi,formatNum      
	mov		rdx,intFil   ;Formateo el input, str a int    
	sub		rsp,64
	call	sscanf             
	add		rsp,64

    mov     rdi,[intFil]
    sub     rsp,8
    call    checkInt
    add     rsp,8

    cmp     rax,0
    je      pedirFila


; chequear valores de fila
  
    pedirColumna:
    mov     rdi,mjeColum
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64

    mov     rdi,bufferCol
    sub     rsp,8
    call    gets
    add     rsp,8
 
    mov     rdi,bufferCol
    mov     rsi,formatNum      
	mov		rdx,intCol   ;Formateo el input, str a int    
	sub		rsp,64
	call	sscanf             
	add		rsp,64

    mov     rdi,[intCol]
    sub     rsp,8
    call    checkInt
    add     rsp,8

    cmp     rax,0
    je      pedirColumna
ret

checkInt:
    cmp     rax,0       ;del sscanf
    je      endCheckInt

    cmp     rdi,0     ;rax con valor 1
    jl      invalid
    cmp     rdi,6
    jg      invalid

    jmp     endCheckInt
invalid:
    mov     rax,0
endCheckInt:
ret



printTablero:

    ;;;;;;;;;;;;; print index columnas

    mov     rdi,eL
    sub     rsp,64
    call    printf
    add     rsp,64
    mov     r13,0
    index:
    mov     rdi,indexer
    mov     rsi,r13
    sub     rsp,64
    call    printf
    add     rsp,64
    inc     r13
    cmp     r13,6
    jle index

    mov     rdi,nL
    sub     rsp,64
    call    printf
    add     rsp,64
  
   
    ;;;;;;
    mov     rbx,0
    xor     r13,r13
    setSecIndex:
    
    xor     r12,r12
    
    mov     rdi,indexer
    mov     rsi,r13

    sub     rsp,64
    call    printf
    add     rsp,64

    set:

    

    mov     rdi,mjeChar
    mov     rsi,[tablero+rbx];rax,[tablero+rbx]
    ;mov     [charActual],al
    ;push    rax
    ;mov     rsi,[charActual]
    ;xor     rsi,rsi
    ;pop     rsi
    sub     rsp,64
    call    printf
    add     rsp,64    

    inc     rbx
    inc     r12

    cmp     r12,7
    je      out
    jmp     set
    
    out:

    inc     r13
    
    mov     rdi,nL ;Nueva linea
    sub     rsp,64
    call    printf
    add     rsp,64

    cmp     rbx,49
    jl      setSecIndex

ret
    
 

openError:
    mov     rdi,mjeErrorOpen
    sub     rsp,8
    call    printf 
    add     rsp,8

endProg:
    mov     rdi,mjeFin
    sub     rsp,64
    call    printf 
    add     rsp,64
ret

