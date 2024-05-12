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
    diff                  dd    1
    mjeDiff               db    "Diferencia: %i",10,0
    nameZorro             db    "Zorro",0
    nameOca               db    "Oca",0
    mjePos                db    "Posicion: %i",10,0  
    mjePosZorro           db    "Posicion Zorro: %i",10,0  
    mjeFin                db    "> Fin de programa",10,0
    mjeTurnoZorro         db    "Turno de Zorro",10,0
    mjeTurnoOca           db    "Turno de Oca",10,0
    zorroCounter times 49 db    0
    mode                  db    "rb",0
    fileName              db    "tablero.bin",0
    mjeOk                 db    10,"> Archivo abierto con exito!",10,10,0
    mjeErrorOpen          db    10,"> Error en apertura de archivo",10,10,0
    tamTablero            db    49
    mjeChar               db    " %c ",0
    nL                    db    10,0
    line                  db    7
    mjeFila               db    "ingrese fila:",10,0
    mjeColum              db    "ingrese columna:",10,0

    mjePiezaPos           db    "En la posicion %i hay un %c",10,0

    prueba  db "prueba",10,0
    
    formatNum       db      "%i",0
    indexer         db      " %i ",0

    mjeCoord        db      "Se mueve a fila %i, columna %i",10,0
    
    mjePosInvalid   db      "Posicion no valida",10,0

    ;Registro del archivo
    registro times  0     db    "" 
    tablero times   49    db    0

section .bss
    
    posZorro        resb    8

    bufferCol       resb    8
    bufferFil       resb    8
    buffer          resb    500
    fileHandle      resq    1
    bufferTablero   resb    96; 49*2
    charActual      resq    1

    intCol         resd     1
    intFil         resd     1

    posicion        resb    10

    jugTurno        resb    8

section .text
main:
    ;Abro archivo
    mov     rdi,fileName
    mov     rsi,mode
    call    fopen
    
    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError ; Error de apertura?

    ; Mje exito de apertura
    sub     rsp,8
    mov     rdi,mjeOk
    call    printf 
    add     rsp,8

    ;Leo archivo

    mov     rdi,registro
    mov     rsi,49
    mov     rdx,1
    mov     rcx,qword[fileHandle]
    call    fread

    cmp     rax,0
    jle     endProg
    
    ;lectura de registro exitosa:
   


   ;   

    mov     r12,[nameZorro]
    mov     [jugTurno],r12

    ;call    printTablero

    gameLoop: 
    
    call    printTablero
    mov     r12,[jugTurno]
    
    cmp     r12,[nameZorro]
    jne     notZorro
    ;call    findPosZorro
    call    turnoZorro
    jmp     outG
    
    notZorro:

    ;cmp     r12,[nameOca]
    call    turnoOca

    outG:

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


ret

turnoOca:

    mov     rdi,mjeTurnoOca
    call    puts

    mov     rdi,buffer
    call    gets

    mov     r13,[nameZorro]
    mov     [jugTurno],r13

    ret


findPosZorro:

    ;encuentro e imprimo la posicion del zorro

    xor     rbx,rbx

    l:

    cmp     byte[tablero+rbx],"X"

    jne     sig
    mov     byte[posZorro],bl
    jmp     outP
    sig:

    inc     rbx
    cmp     rbx,49
    je      outP

    jmp     l

    outP:

    mov     rdi,mjePosZorro    
    mov     rsi,[posZorro]
    sub     rsp,8
    call    printf
    add     rsp,8
ret

turnoZorro:
    
    
    mov     rdi,mjeTurnoZorro
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64  

    call    findPosZorro

    pedirPos:
    mov     rdi,mjeFila
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64

    mov     rdi,bufferFil
    call    gets

    mov     rdi,bufferFil
    mov     rsi,formatNum       
	mov		rdx,intFil   ;Formateo el input, str a int    
	sub		rsp,64
	call	sscanf             
	add		rsp,64

    mov     rdi,mjeColum
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64

    mov     rdi,bufferCol
    call    gets
 
    mov     rdi,bufferCol
    mov     rsi,formatNum       
	mov		rdx,intCol   ;Formateo el input, str a int    
	sub		rsp,64
	call	sscanf             
	add		rsp,64


    mov     rdi,mjeCoord
    mov     rsi,[intFil]
    mov     rdx,[intCol]
    sub     rsp,64
    call    printf
    add     rsp,64

    ;calculo la posicion: posición = (fila * número_de_columnas) + columna

    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posicion],rax
    
    mov     rdi,mjePos
    mov     rsi,[posicion]
    sub     rsp,64
    call    printf
    add     rsp,64
    
    mov     ebx,[posicion]
    mov     al,byte[tablero+ebx]
    cmp     al,"_"
    jne     badPos

        
    xor     r12,r12
    mov     r12,[posicion]
    mov     ebx,[posZorro]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    cmp     dword[diff],-7;norte
    je      mover
    cmp     dword[diff],7;sur
    je      mover
    cmp     dword[diff],1;este
    je      mover
    cmp     dword[diff],-1;oeste
    je      mover
    cmp     dword[diff],8;sur este
    je      mover
    cmp     dword[diff],-8;nor oeste
    je      mover
    cmp     dword[diff],6;sur oeste
    je      mover
    cmp     dword[diff],-6;nor este
    je      mover

    badPos:
    mov     rdi,mjePosInvalid
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     pedirPos
    
    mover:
  
    xor     rbx,rbx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    xor     r14,r14
    mov     ebx,[posicion]
    mov     rdi,mjePiezaPos;
    mov     rsi,[posicion]
    mov     al,[tablero+ebx]
    mov     dl,al
    sub     rsp,64
    call    printf
    add     rsp,64

    mov     rax,[posZorro]
    mov     byte[tablero+eax],"_"
    mov     byte[tablero+ebx],"X";


    

    mov     r13,[nameOca]
    mov     [jugTurno],r13
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

    cmp    r12,7
    je     out
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

