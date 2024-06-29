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
    eL                          db    "   ",0
    diff                        dd    1
    mjeDiff                     db    "Diferencia: %i",10,0
    nameZorro                   db    "Zorro",0
    nameOca                     db    "Oca",0
    mjePos                      db    "Posicion: %i",10,0  
    mjePosZorro                 db    "Posicion Zorro: %i",10,0  
    mjePosOca                   db    "Posicion Oca: %i",5,0
    mjeFin                      db    "> Fin de programa",10,0
    mjeTurnoZorro               db    "Turno de Zorro",10,0
    mjeTurnoOca                 db    "Turno de Oca",10,0
    zorroCounter times 49       db    0
    readMode                    db    "rb",0
    saveMode                    db    "wb",0
    fileName                    db    "tablero.bin",0
    saveFileName                db    "partida.bin",0
    ocasComidasFileName         db    "ocasComidas.bin",0
    mjeOk                       db    10,"> Archivo abierto con exito!",10,10,0
    mjeErrorOpen                db    10,"> Error en apertura de archivo",10,10,0
    tamTablero                  db    49
    mjeChar                     db    " %c ",0
    nL                          db    10,0
    line                        db    7
    mjeFila                     db    "ingrese fila:",10,0
    mjeColum                    db    "ingrese columna:",10,0

    

    mjePosDestino               db    "Usted se mueve a la fila %li, columna %li",10,0

    prueba                      db    "prueba",10,0
    
    formatNum                   db    "%i",0
    indexer                     db    " %i ",0

    mjeCoord                    db    "Se mueve a fila %i, columna %i",10,0
    
    mjePosInvalidaZorro         db    "posicion invalida del zorro",10,0
    mjePosInvalidaNoHayOca      db    "No hay una oca en la posicion seleccionada",10,0                        Posicion invalida de origen de oca",10,0
    mjePosInvalidaOcaEncerrada  db    "La oca no puede moverse, seleccione otra",10,0
    mjePosInvalidaOcaDestino    db    "Posicion invalida para la oca",10,0


    ;Registro del archivo
    registro times  0           db    "" 
    tablero times   49          db    0



    regOcasComidas times 0      db    0

    ;guardar y cargar partida
    titulo                      db    "Este es el juego de la oca. ¿Desea empezar nueva partida?",10,0
    begin                       db    "El juego de la oca ya empezo",10,0
    newRound                    db    "escriba 'nueva partida' para empezar un nuevo juego",10,0
    continue                    db    "escriba 'cargar' para continuar una partida no terminada",10,0
    mjeOpcionInvalida           db    "La opcion ingresada es inválida",10,0

    msgSaveGame                 db    "Escriba 'guardar' para guardar la partida",10,0
    msgSalir                    db    "Escriba 'salir' para terminar el juego",10,0
    msgReandular                db    "Escriba 'seguir' para continuar la partida",10,0

    msgSaveError                db    "Error al intentar guardar",10,0
    msgSaveSuccess              db    "Partida exitosamente guardada",10,0


    msgPartidaNoGuardada        db    "¿seguro de que desea salir?",10,0
    msgGanaElZorro              db    "El zorro gana",10,0
    msgGananLasOcas             db    "Las ocas ganan",10,0
    msgAdios                    db    "hasta la proxima",10,0

    partidaGuardada             dq    0

section .bss
    
    posZorro                    resq    1
    posOca                      resq    1
    bufferCol                   resb    8
    bufferFil                   resb    8
    buffer                      resb    500
    fileHandle                  resq    1
    bufferTablero               resb    96; 49*2
    charActual                  resq    1

    intCol                      resq     1
    intFil                      resq     1

    posicionX                   resb    10
    posicionO                   resb    10

    ;filOcaOrigen                resq    1          ;no los usamos
    ;colOcaOrigen                resq    1
    filOcaDestino               resq    1           ;los usamos para el printf mostrando fila y columna destino
    colOcaDestino               resq    1
    
    posDestino                  resq    1

    jugTurno                    resb    8

    ;para el archivo
    fileID                      resq    1
    ocasComidasStr              resq    1
    ocasComidas                 resq    1

    ocasComidasHandle           resq    1


section .text
main:
    jmp     mainMenu
    
    openSaved:
    sub     rsp, 8
    call    cargarOcasComidas
    add     rsp, 8

    ;Abro archivo
    mov     rdi, saveFileName
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    jmp     openFile

    newGame:
    mov     rdi, fileName
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    mov     [ocasComidas], 0
    
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
    mov     rsi, 49
    mov     rdx, 1
    mov     rcx,qword[fileHandle]
    sub     rsp, 8
    call    fread
    add     rsp, 8

    cmp     rax, 0
    jle     endProg

    ;lectura de registro exitosa:


    mov     rdi,[fileHandle]
    sub     rsp, 8
    call    fclose
    add     rsp, 8

    mov     r12,[nameZorro]
    mov     [jugTurno],r12



    gameLoop: 
    
    call    printTablero

    sub     rsp,8
    call    verificarEstadoJuego   ;setea rax, con 1 
    add     rsp,8

    cmp     rax,1
    jge     endProg
    

    mov     r12,[jugTurno]
    cmp     r12,[nameZorro]
    jne     notZorro

    call    turnoZorro
    jmp     outG
    
    notZorro:

    call    turnoOca

    outG:

    loop    gameLoop

    endMain:
ret

turnoOca:
 
    mov     rdi,mjeTurnoOca
    mPuts

    sub     rsp, 8
    call    checkPosOca
    add     rsp, 8

    sub     rsp, 8
    call    checkPosOcaDestino
    add     rsp, 8
    

    moverOca:

    mov     rbx,[posDestino]

    mov     rdi,mjePosDestino;
    mov     rsi,[filOcaDestino]
    mov     rdx,[colOcaDestino]
    sub     rsp,64
    call    printf
    add     rsp,64

    mov     rbx,[posDestino]
    mov     byte[tablero+rbx],"O"

    mov     rbx,[posOca]
    mov     byte[tablero+rbx],"_"


    
    mov     r13,[nameZorro]
    mov     [jugTurno],r13
ret


checkPosOca:

    queOcaDeseaMover:
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
    mov     [posOca],rax


    mov     rbx,[posOca]
    

    cmp     byte[tablero+rbx],"O"

    jne     badPosOcaOrigen
    je      checkOcaNoEncerrada
    
    badPosOcaOrigen:
    mov     rdi,mjePosInvalidaNoHayOca
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     queOcaDeseaMover

    badPosOcaEncerrada:
    mov     rdi,mjePosInvalidaOcaEncerrada
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     queOcaDeseaMover

    checkOcaNoEncerrada:
/*
    mov     r10,[intFil]
    mov     [filOcaOrigen],r10
    mov     r10,[intCol]
    mov     [colOcaOrigen],r10
*/
    xor     r10, r10
    add     r10, rbx
    add     r10, 7;sur
    cmp     byte[tablero+r10], "_"
    jne     badPosOcaEncerrada

    add     r10, -7
    add     r10, 1;este
    cmp     byte[tablero+r10], "_"
    jne     badPosOcaEncerrada
    add     r10, -2;oeste
    cmp     byte[tablero+r10], "_"
    jne     badPosOcaEncerrada

    finChequeoOca:
ret

checkPosOcaDestino:
    
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
    mov     [posDestino],rax


    mov     rbx,[posDestino]

    cmp     byte[tablero+rbx],"_"

    je      checkDestinoOca

    badPosOcaDestino:
    mov     rdi,mjePosInvalidaOcaDestino
    sub     rsp,64
    call    printf
    add     rsp,64

    jmp     posCaidaOca


    checkDestinoOca:


    mov     r10,[intFil]
    mov     [filOcaDestino],r10
    mov     r10,[intCol]
    mov     [colOcaDestino],r10

/*

    ;calculo posOca
    mov     rbx,[filOcaOrigen]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[colOcaOrigen]

    imul    rax,rbx
    add     rax,r13
    mov     [posOca],rax

    ;calculo posDestino
    mov     rbx,[filOcaDestino]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[colOcaDestino]

    imul    rax,rbx
    add     rax,r13
    mov     [posDestino],rax
*/   

    ;chequeo si posDestino esta al sur, este, o oeste de posOca
    mov     rax,[posOca]
    add     rax,7
    cmp     [posDestino],rax
    jne     badPosOcaDestino
    je      finChequeoOcaDestino


    mov     rax,[posOca]
    add     rax,1
    cmp     [posDestino],rax
    jne     badPosOcaDestino
    je      finChequeoOcaDestino


    mov     rax,[posOca]
    add     rax,-1
    cmp     [posDestino],rax
    jne     badPosOcaDestino
    je      finChequeoOcaDestino

    finChequeoOcaDestino:
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
/*
    mov     rdi,mjePosZorro    
    mov     rsi,[posZorro]
    sub     rsp,8
    call    printf
    add     rsp,8
*/
ret

turnoZorro:

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

    ;falta actualizar posZorro

    

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
    
mainMenu:
    mov     rdi, titulo
    mPuts
    pedirOpcion:
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
    jne     opcionInvalida
    
opcionInvalida:
    mov     rdi,mjeOpcionInvalida
    mPuts
    jmp     pedirOpcion



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
    jmp     endMain

saveGame:

    mov     rdi, saveFileName
    mov     rsi, saveMode
    sub     rsp, 64
    call    fopen     
    add     rsp, 64
    
    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError

    

    guardar:
    mov     rdi, registro
    mov     rsi, 49
    mov     rdx, 1
    mov     rcx, qword[fileHandle]
    sub     rsp, 64
    call    fwrite
    add     rsp, 64

    cmp     byte[rax], 0
    jle     saveError

    mov     rdi, qword[fileHandle]
    sub     rsp, 64
    call    fclose
    add     rsp, 64

    sub     rsp, 8
    call    guardarOcasComidas
    add     rsp, 8

    inc     [partidaGuardada]
    jmp     turnoZorro


    saveError:
    mov     rdi, msgSaveError
    mPutsNotMain
    mov     rdi, [fileHandle]
    sub     rsp, 64
    call    fclose
    add     rsp, 64
    jmp     turnoZorro


exit:
    cmp     [partidaGuardada], 1
    jge     salir
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
    
    ; salir(sin guardar):
    ; al no guardar la partida, hay que sobreescribir partida.bin para que sea igual a tablero.bin

    mov     rdi,fileName                ;abro tablero.bin para leer
    mov     rsi,readMode
    sub     rsp,8
    call    fopen
    add     rsp,8

    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError

    mov     rdi,registro                ;copio en registro(cabecera de tablero) todo el contenido de tablero.bin
    mov     rsi, 49
    mov     rdx, 1
    mov     rcx,qword[fileHandle]
    sub     rsp, 8
    call    fread
    add     rsp, 8

    mov     rdi,qword[fileHandle]       ;cierro tablero.bin
    sub     rsp,8
    call    fclose
    add     rsp,8

    mov     rdi,saveFileName            ;abro partida.bin, para copiar dentro el contenido de tablero.bin
    mov     rsi,saveMode
    sub     rsp,8
    call    fopen
    add     rsp,8

    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError

    mov     rdi,tablero                 ;copio en partida.bin 
    mov     rsi, 49
    mov     rdx, 1
    mov     rcx,qword[fileHandle]           
    call    fwrite                          
    add     rsp,8                           


    mov     rdi,qword[fileHandle]              ;cierro partida.bin
    sub     rsp,8                              
    call    fclose
    add     rsp,8

    mov     rdi,ocasComidasFileName            ;abro ocasComidas.bin para escribir un 0
    mov     rsi,saveMode
    sub     rsp,8
    call    fopen
    add     rsp,8

    mov     qword[fileHandle],rax
    cmp     qword[fileHandle],0
    jle     openError

    mov     [ocasComidas],0
    
    mov     rdi,ocasComidasStr
    mov     rsi,formatNum
    mov     rdx,[ocasComidas]
    sub     rsp,8
    call    sprintf
    add     rsp,8

    mov     rdi,ocasComidasStr
    mov     rsi,[fileHandle]
    sub     rsp,8
    call    fputs
    add     rsp,8               


/*
    mov     rdi, ocasComidasFileName
    mov     rsi, saveMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    
    mov     [ocasComidas],0
    mov     rdi,regOcasComidas
    mov     rsi,1
    mov     rdx,1
    mov     rcx,ocasComidasHandle
    sub     rsp,8
    call    fputs
    add     rsp,8

    mov     rdi, [fileHandle]
    sub     rsp, 64
    call    fclose
    add     rsp, 64
    
*/  salir:  
    jmp     endProg

cargarOcasComidas:
    mov     rdi, ocasComidasFileName
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    mov     qword[ocasComidasHandle],rax
    cmp     [ocasComidasHandle],0
    jle     openError

    mov     rdi, ocasComidasStr
    mov     rsi, 1                     ; o 2? porque el archivo puede tener 2 caracteres representando 2 digitos
    mov     rdx, 1
    mov     rcx, ocasComidasHandle
    sub     rsp, 8
    call    fread
    add     rsp, 8
    sub     rsp, 8
    call    closeOcasComidas
    add     rsp, 8


    mov     rdi,ocasComidasStr 
    mov     rsi,formatNum
    mov     rdx,ocasComidas         ;Formateo de str a int
    sub     rsp,64
    call    sscanf
    add     rsp,64
ret

guardarOcasComidas:
    mov     rdi, ocasComidasFileName
    mov     rsi, saveMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    mov     qword[ocasComidasHandle],rax
    cmp     [ocasComidasHandle],0
    jle     openError

    mov     rdi,ocasComidas
    mov     rsi,rax
    sub     rsp, 8
    call    fputs
    add     rsp, 8
    sub     rsp, 8
    call    closeOcasComidas
    add     rsp, 8
ret
closeOcasComidas:
    mov     rdi, [ocasComidasHandle]
    sub     rsp, 8
    call    fclose
    add     rsp, 8
ret
ganaElZorro:
    mov     rdi, msgGanaElZorro
    mPuts
    mov     rdi, msgAdios
    mPuts
    
ret

gananLasOcas:
    mov     rdi, msgGananLasOcas
    mPuts
    mov     rdi, msgAdios
    mPuts

ret

verificarEstadoJuego:
    cmp     [ocasComidas], 12
    je      victoriaZorro

    sub     rsp, 8
    call    findPosZorro
    add     rsp, 8

    ;comparo lo que esta cerca del zorro

    xor     r10, r10
    add     r10, posZorro
    add     r10, -7;norte
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 7;sur
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 1;este
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -1;oeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 8;sureste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -8;noroeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 6;suroeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -6;noreste
    cmp     byte[tablero+r10],"_"
    je      nadieGana
    
    ;comparo lo no tan cerca del zorro

    xor     r10, r10
    add     r10, posZorro
    add     r10, -14;norte
    cmp     byte[tablero+r10],"_"
    je      nadieGana
    
    xor     r10, r10
    add     r10, posZorro
    add     r10, 14;sur
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 2;este
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -2;oeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 16;sureste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -16;noroeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, 12;suroeste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    xor     r10, r10
    add     r10, posZorro
    add     r10, -12;noreste
    cmp     byte[tablero+r10],"_"
    je      nadieGana

    ;como el zorro este encerrado, pierde
    jmp     victoriaOcas
    
    victoriaZorro:
    sub     rsp, 8
    call    ganaElZorro
    add     rsp, 8
    mov     rax, 1
    jmp     finVerificacion
    
    victoriaOcas:
    sub     rsp, 8
    call    gananLasOcas    
    add     rsp, 8
    mov     rax, 2
    jmp     finVerificacion

    nadieGana:
    mov     rax,0


    finVerificacion:
ret
