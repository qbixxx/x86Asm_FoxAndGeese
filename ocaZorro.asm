global main


%macro mGetsNotMain 1
    mov     rdi, %1
    sub     rsp, 64
    call    gets
    add     rsp, 64
%endmacro

%macro mPutsNotMain 0
    sub     rsp, 64
    call    puts
    add     rsp, 64
%endmacro


%macro mGets 1
    mov     rdi, %1
    sub     rsp, 8
    call    gets
    add     rsp, 8
%endmacro

%macro mPuts 0
    sub     rsp, 8
    call    puts
    add     rsp, 8
%endmacro
extern puts
extern sprintf
extern printf
extern sscanf
extern gets

extern fopen
extern fread
extern fclose
extern fwrite
;posición = (fila * número_de_columnas) + columna
;=(1 * 7)+2

section .data
    eL                      db    "   ",0
    diff                    dd    1
    mjeDiff                 db    "Diferencia: %i",10,0
    nameZorro               db    "Zorro",0
    nameOca                 db    "Oca",0
    mjePos                  db    "Posicion: %i",10,0  
    mjePosZorro             db    "Posicion Zorro: %i",10,0  
    mjePosOca               db    "Posicion Oca: %i",5,0
    mjeFin                  db    "> Fin de programa",10,0
    mjeTurnoZorro           db    "Turno de Zorro",10,0
    mjeTurnoOca             db    "Turno de Oca",10,0
    zorroCounter times 49   db    0
    mode                    db    "rb",0
    savemode                db    "wb",0
    fileName                db    "tablero.bin",0
    saveFileName            db    "partida.bin",0
    mjeOk                   db    10,"> Archivo abierto con exito!",10,10,0
    mjeErrorOpen            db    10,"> Error en apertura de archivo",10,10,0
    tamTablero              db    49
    mjeChar                 db    " %c ",0
    nL                      db    10,0
    line                    db    7
    mjeFila                 db    "ingrese fila:",10,0
    mjeColum                db    "ingrese columna:",10,0

    mjePiezaPos             db    "En la posicion %i hay un %c",10,0

    prueba                  db    "prueba",10,0
    
    formatNum               db    "%i",0
    indexer                 db    " %i ",0

    mjeCoord                db    "Se mueve a fila %i, columna %i",10,0
    
    mjePosInvalid           db    "Posicion no valida",10,0

    ;Registro del archivo
    registro times  0       db    "" 
    tablero times   49      db    0

    titulo                  db    "Este es el juego de la oca. ¿Desea empezar nueva partida?",0
    begin                   db    "El juego de la oca ya empezo",0
    newRound                db    "escriba 'nueva partida' para empezar un nuevo juego",0
    continue                db    "escriba 'cargar' para continuar una partida no terminada",0

    msgSaveGame             db    "escriba 'guardar' para guardar la partida",0
    msgSalir                db    "escriba 'salir' para terminar el juego",0
    msgReandular            db    "escriba 'seguir' para continuar la partida",0

    msgSaveError            db    "error al intentar guardar",0
    msgSaveSuccess          db    "partida exitosamente guardada",0


    msgPartidaNoGuardada    db    "¿seguro de que desea salir?",0
    msgGanaElZorro          db    "El zorro gana",0
    msgGananLasOcas         db    "Las ocas ganan",0
    msgAdios                db    "hasta la proxima",0

section .bss
    
    posZorro            resb    8
    posOca              resb    8
    bufferCol           resb    8
    bufferFil           resb    8
    buffer              resb    500
    fileHandle          resq    1
    bufferTablero       resb    96; 49*2
    charActual          resq    1

    intCol              resd     1
    intFil              resd     1

    posicionX           resb    10
    posicionO           resb    10

    jugTurno            resb    8

    ;para el archivo
    fileID              resq    1
    ocasComidas         resw    0
    partidaGuardada     resb    0

section .text
main:
    jmp     mainMenu
    
    openSaved:
    ;Abro archivo
    mov     rdi, saveFileName
    mov     rsi, mode
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    jmp     openFile

    newGame:
    mov     rdi, fileName
    mov     rsi, mode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    
    openFile:
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
    sub     rsp,8
    call    fread
    add     rsp,8

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
    call puts


    
    call    checkPosOca

    checkDestinoOca

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
    mov     [posicionO],rax
    
    mov     rdi,mjePos
    mov     rsi,[posicionO]
    sub     rsp,64
    call    printf
    add     rsp,64
    
    mov     ebx,[posicionO]
    mov     al,byte[tablero+ebx]
    cmp     al,"_"
    jne     badPosOca

    
    xor     r12,r12
    mov     r12,[posicionX]
    mov     ebx,[posOca]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    cmp     dword[diff],-7;norte
    je      moverOca
    cmp     dword[diff],7;sur
    je      moverOca
    cmp     dword[diff],1;este
    je      moverOca
    cmp     dword[diff],-1;oeste
    je      moverOca
    cmp     dword[diff],8;sur este
    je      moverOca
    cmp     dword[diff],-8;nor oeste
    je      moverOca
    cmp     dword[diff],6;sur oeste
    je      moverOca
    cmp     dword[diff],-6;nor este
    je      moverOca
    jmp     badPosOca

    
    moverOca:
  
    xor     rbx,rbx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    xor     r14,r14
    mov     ebx,[posicionO]
    mov     rdi,mjePiezaPos;
    mov     rsi,[posicionO]
    mov     al,[tablero+ebx]
    mov     dl,al
    sub     rsp,64
    call    printf
    add     rsp,64

    mov     rax,[posZorro]
    mov     byte[tablero+eax],"_"
    mov     byte[tablero+ebx],"O";


    

    mov     r13,[nameOca]
    mov     [jugTurno],r13
ret


checkPosOca:

    mov     rdi,mjeFila
    sub     rsp, 64
    call    puts
    add     rsp, 64

    mov     rdi,bufferFil
    sub     rsp, 64
    call    gets
    add     rsp, 64


    mov     rdi,bufferFil
    mov     rsi,formatNum       
	mov		rdx,intFil   ;Formateo el input, str a int
	sub		rsp,64
	call	sscanf
	add		rsp,64

    mov     rdi,mjeColum
    sub     rsp,64
    call    puts
    add     rsp,64

    mov     rdi,bufferCol
    sub     rsp, 64
    call    gets
    add     rsp, 64
 
    mov     rdi,bufferCol
    mov     rsi,formatNum       
	mov		rdx,intCol   ;Formateo el input, str a int
	sub		rsp,64
	call	sscanf             
	add		rsp,64

    ;encuentro e imprimo la posicion de la oca

    xor     rbx,rbx
    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posicionO],rax


    mov     rbx,[posicionO]
    

    cmp     byte[tablero+rbx],"O"

    jne     badPosOca
    je      posCaidaOca
    badPosOca:
    mov     rdi,mjePosInvalid
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     checkPosOca

    posCaidaOca:

    mov     rdi,mjeFila
    sub     rsp, 64
    call    puts
    add     rsp, 64

    mov     rdi,bufferFil
    sub     rsp, 64
    call    gets
    add     rsp, 64


    mov     rdi,bufferFil
    mov     rsi,formatNum       
	mov		rdx,intFil   ;Formateo el input, str a int
	sub		rsp,64
	call	sscanf
	add		rsp,64

    mov     rdi,mjeColum
    sub     rsp,64
    call    puts
    add     rsp,64

    mov     rdi,bufferCol
    sub     rsp, 64
    call    gets
    add     rsp, 64
 
    mov     rdi,bufferCol
    mov     rsi,formatNum       
	mov		rdx,intCol   ;Formateo el input, str a int
	sub		rsp,64
	call	sscanf             
	add		rsp,64

    ;encuentro el destino

    xor     rbx,rbx
    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posicionO],rax


    mov     rbx,[posicionO]
    

    cmp     byte[tablero+rbx],"_"

    jne     badPosOca
    je      checkDestinoOca

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
    cmp     [ocasComidas], 12
    je      ganaElZorro
    mov     rdi, msgSaveGame
    mPutsNotMain
    mov     rdi, msgReandular
    mPutsNotMain
    mov     rdi, msgSalir
    mPutsNotMain
    mov     rdi, 100
    mGetsNotMain    rdi
    cmp     qword[rdi], "guardar"
    je      saveGame
    cmp     qword[rdi], "salir"
    je      exit



    seguirPartida:
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
    mov     [posicionX],rax
    
    mov     rdi,mjePos
    mov     rsi,[posicionX]
    sub     rsp,64
    call    printf
    add     rsp,64
    
    mov     ebx,[posicionX]
    mov     al,byte[tablero+ebx]
    cmp     al,"_"
    jne     badPosZorro

        
    xor     r12,r12
    mov     r12,[posicionX]
    mov     ebx,[posZorro]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    cmp     dword[diff],-7;norte
    je      moverZorro
    cmp     dword[diff],7;sur
    je      moverZorro
    cmp     dword[diff],1;este
    je      moverZorro
    cmp     dword[diff],-1;oeste
    je      moverZorro
    cmp     dword[diff],8;sur este
    je      moverZorro
    cmp     dword[diff],-8;nor oeste
    je      moverZorro
    cmp     dword[diff],6;sur oeste
    je      moverZorro
    cmp     dword[diff],-6;nor este
    je      moverZorro

    ;agregar caso de salto del zorro sobre oca.
    
    cmp     dword[diff],-14;norte
    je      saltearOca
    cmp     dword[diff],14;sur
    je      saltearOca
    cmp     dword[diff],2;este
    je      saltearOca
    cmp     dword[diff],-2;oeste
    je      saltearOca
    cmp     dword[diff],16;sur este
    je      saltearOca
    cmp     dword[diff],-16;nor oeste
    je      saltearOca
    cmp     dword[diff],12;sur oeste
    je      saltearOca
    cmp     dword[diff],-12;nor este
    je      saltearOca

    ;diferencia mas grande [diff] && [diff/2] == O

    badPosZorro:
    mov     rdi,mjePosInvalid
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     pedirPos

    saltearOca:
    mov     r8b, 2
    mov     ax, posicionX
    div     r8b
    xor     r9, r9
    mov     r9b, al
    mov     ebx,r9d
    mov     al,byte[tablero+ebx]
    cmp     al,"O"
    jne     badPosZorro

    comerOca:
    mov     [al], "_"
    inc     [ocasComidas]

    moverZorro:
  
    xor     rbx,rbx
    xor     rax,rax
    xor     rdi,rdi
    xor     rsi,rsi
    xor     rdx,rdx
    xor     r14,r14
    mov     ebx,[posicionX]
    mov     rdi,mjePiezaPos;
    mov     rsi,[posicionX]
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
    mov     [partidaGuardada], 0
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
    
mainMenu:
    mov     rdi, titulo
    mPuts
    mov     rdi, continue
    mPuts
    mov     rdi, newRound
    mPuts
    mov     rdi, 100
    mGets   rdi
    cmp     qword[rdi], "cargar",0
    je      openSaved
    cmp     qword[rdi], "nueva partida",0
    je      newGame


openError:
    mov     rdi,mjeErrorOpen
    sub     rsp,8
    call    printf 
    add     rsp,8
    jmp     mainMenumov

endProg:
    mov     rdi,mjeFin
    sub     rsp,64
    call    printf 
    add     rsp,64
ret

saveGame:
    mov     rdi, registro
    mov     rsi, 5
    mov     rdx, 1
    mov     rcx, fileID
    sub     rsp, 64
    call    fwrite
    add     rsp, 64

    cmp     byte[rax], 0
    jle     saveError

    inc     [partidaGuardada]
    jmp     turnoZorro



    saveError:
    mov     rdi, msgSaveError
    mPutsNotMain
    jmp     turnoZorro


ret

exit:
    cmp     [partidaGuardada], 1
    je      salir
    mov     rdi, msgPartidaNoGuardada
    mPutsNotMain
    mov     rdi, msgSalir
    mPutsNotMain
    mov     rdi, msgReandular
    mPutsNotMain
    mov     rdi, 100
    mGetsNotMain    rdi
    cmp     rdi, "seguir"
    je      turnoZorro

    salir:
    mov     rdi, msgAdios
    mPutsNotMain
    mov     rdi, [fileID]
    sub     rsp, 64
    call    fclose
    add     rsp, 64
    jmp     endProg


ganaElZorro:
    mov     rdi, msgGanaElZorro
    mPutsNotMain
    mov     rdi, msgAdios
    mPutsNotMain
    jmp     endProg

