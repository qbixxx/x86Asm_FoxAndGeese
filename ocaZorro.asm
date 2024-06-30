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

extern strcmp

extern fputs
extern fopen
extern fread
extern fclose
extern fwrite
;posición = (fila * número_de_columnas) + columna
;=(1 * 7)+2

section .data
    eL                          db    "   ",0
    diff                        dq    1
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
    tableroNameFile                    db    "tablero.bin",0
    partidaFileName                db    "partida.bin",0
    ocasComidasFileName         db    "ocasComidas.bin",0
    mjeOk                       db    10,"> Archivo abierto con exito!",10,10,0
    mjeErrorOpen                db    10,"> Error en apertura de archivo",10,10,0
    tamTablero                  db    49
    mjeChar                     db    " %c ",0
    nL                          db    "",10,0
    line                        db    7
    mjeFila                     db    "ingrese fila:",0
    mjeColum                    db    "ingrese columna:",0

    posCercanas                 dq    -7,7,1,-1,8,-8,6,-6
    posLejanas                  dq    -14,14,2,-2,16,-16,12,-12

    mjePosDestino               db    "Usted se mueve a la fila %li, columna %li",10,0

    prueba                      db    "prueba",10,0
    
    formatNum                   db    "%i",0
    indexer                     db    " %i ",0

    mjeCoord                    db    "Se mueve a fila %i, columna %i",10,0
    
    mjePosInvalidaZorro         db    "El zorro no puede moverse a esa posicion",10,0
    mjePosInvalidaNoHayOca      db    "No hay una oca en la posicion seleccionada, ingrese otra posición",10,0
    mjePosInvalidaOcaEncerrada  db    "La oca no puede moverse, seleccione otra",10,0
    mjePosInvalidaOcaDestino    db    "Posicion invalida para la oca",10,0

    checkNadieGana              db    0

    mjeOcasComidas              db "Ocas comidas: %i",0
    

    ;Registro del archivo
    registro times  0           db    "" 
    tablero times   49          db    0



    regOcasComidas times 0      db    0

    ;guardar y cargar partida
    titulo                      db    "Este es el juego de la oca. ¿Desea empezar nueva partida?",10,0
    begin                       db    "El juego de la oca ya empezo",10,0
    mjeNewRound                    db    "Escriba 'nuevo' para empezar un nuevo juego",0
    mjeContinue                    db    "Escriba 'cargar' para continuar una partida no terminada",0
    mjeOpcionInvalida           db    "La opcion ingresada es inválida",10,0

    msgSaveGame                 db    "Escriba 'guardar' para guardar la partida",10,0
    msgSalir                    db    "Escriba 'salir' para terminar el juego",10,0
    msgReanudar                 db    "Escriba 'seguir' para continuar la partida",10,0

    opGuardarStr                db    "guardar",0
    opSalirStr                  db    "salir",0
    opSeguirStr                 db    "seguir",0
    opNuevoStr                  db    "nuevo",0
    opCargarStr                 db    "cargar",0

    msgSaveError                db    "Error al intentar guardar",10,0
    msgSaveSuccess              db    "Partida exitosamente guardada",10,0


    msgPartidaNoGuardada        db    "¿seguro de que desea salir?",10,0
    msgGanaElZorro              db    "El zorro gana",10,0
    msgGananLasOcas             db    "Las ocas ganan",10,0
    msgAdios                    db    "hasta la proxima",10,0

    mjeA                        db "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

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

    checkOcaEnMedioResult       resq    1
    posOcaEnMedio               resq    1

    ;filOcaOrigen                resq    1          ;no los usamos
    ;colOcaOrigen                resq    1
    filOcaDestino               resq    1           ;los usamos para el printf mostrando fila y columna destino
    colOcaDestino               resq    1
    
    posDestino                  resq    1

    jugTurno                    resb    8

    ;para el archivo
    fileID                      resq    1
    ocasComidasStr              resq    1
    ocasComidas                 resb    1

    ocasComidasHandle           resq    1

    strDestino                  resb    100
    strInput                    resb    50

    


section .text
main:
    jmp     mainMenu
    
    openSaved:
    sub     rsp, 8
    call    cargarOcasComidas
    add     rsp, 8

    ;Abro archivo
    mov     rdi, partidaFileName
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    jmp     openFile

    newGame:
    mov     rdi, tableroNameFile
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    mov     qword[ocasComidas], 0
    
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

    mov     rdi, nameZorro
    mPuts

    sub     rsp,8
    call    printTablero
    add     rsp,8

    mov     rdi,mjeOcasComidas
    mov     rsi,[ocasComidas]
    sub     rsp,8
    call    printf
    add     rsp,8

    sub     rsp,8
    call    verificarEstadoJuego   ;setea rax, con 1 
    add     rsp,8

    cmp     rax,1
    jge     endProg
    

    mov     r12,[jugTurno]
    cmp     r12,[nameZorro]
    jne     notZorro

    sub     rsp,8
    call    turnoZorro
    add     rsp,8
    jmp     outG
    
    notZorro:

    sub     rsp,8
    call    turnoOca
    add     rsp,8

    outG:

    jmp     gameLoop

    endMain:
ret

turnoOca:
 
    mov     rdi,mjeTurnoOca
    mPuts
    

    ;agregar mensaje para que se ingrese posicion Origen
    sub     rsp, 8
    call    checkPosOca
    add     rsp, 8

    ;agregar mensaje para que se ingrese posicion Destino
    sub     rsp, 8
    call    checkPosOcaDestino
    add     rsp, 8
    

    moverOca:



   ; mov     rbx,[posDestino]       ; ??? ya esta un poco mas abajo

    mov     rdi,mjeA
    call    puts

    mov     rdi,mjePosDestino;
    mov     rsi,[filOcaDestino]
    mov     rdx,[colOcaDestino]
    
    sub     rsp,8
    call    printf
    add     rsp,8

    mov     rbx,[posDestino]
    mov     byte[tablero+rbx],"O"

    mov     rbx,[posOca]
    mov     byte[tablero+rbx],"_"


    
    mov     r13,[nameZorro]
    mov     [jugTurno],r13
ret


checkPosOca:

    pedirPosOca:
    
    sub     rsp,8
    call    pedirPos            ;setea intFil y intCol
    add     rsp,8

    ;encuentro la posicion origen de la oca 

    mov     rdi,nameOca
    call    puts

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
    sub     rsp,8
    call    printf
    add     rsp,8

    jmp     pedirPosOca

    badPosOcaEncerrada:
    mov     rdi,mjePosInvalidaOcaEncerrada
    sub     rsp,8
    call    printf
    add     rsp,8

    jmp     pedirPosOca


    ;mov     r10,[intFil]
    ;mov     [filOcaOrigen],r10      No hace falta, no hay un mensaje que lo necesite
    ;mov     r10,[intCol]
    ;mov     [colOcaOrigen],r10



    checkOcaNoEncerrada:

    xor     r10, r10
    add     r10, [posOca]
    add     r10, 7;sur
    cmp     byte[tablero+r10], "_"
    ;jne     badPosOcaEncerrada              ; VER
    je      finChequeoOca

    add     r10, -7
    add     r10, 1;este
    cmp     byte[tablero+r10], "_"
    ;jne     badPosOcaEncerrada
    je      finChequeoOca


    add     r10, -2;oeste
    cmp     byte[tablero+r10], "_"
    
    jne     badPosOcaEncerrada
    
    finChequeoOca:
ret

checkPosOcaDestino:
    
    pedirPosOcaDestino:

    sub     rsp,8
    call    pedirPos        ;setea intFil y intCol
    add     rsp,8

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
    sub     rsp,8
    call    printf
    add     rsp,8

    jmp     pedirPosOcaDestino


    checkDestinoOca:

    mov     r10,[intFil]                ;los guardo para mostrarlos luego
    mov     [filOcaDestino],r10
    mov     r10,[intCol]
    mov     [colOcaDestino],r10

    ;chequeo si posDestino esta al sur, este, o oeste de posOca
    mov     rax,[posOca]
    add     rax,7
    cmp     [posDestino],rax
    ;jne     badPosOcaDestino
    ;je      finChequeoOcaDestino
    je      finChequeoOcaDestino

    mov     rax,[posOca]
    add     rax,1
    cmp     [posDestino],rax
    ;jne     badPosOcaDestino
    ;je      finChequeoOcaDestino
    je      finChequeoOcaDestino


    mov     rax,[posOca]
    add     rax,-1
    cmp     [posDestino],rax
    jne     badPosOcaDestino


    finChequeoOcaDestino:
ret

findPosZorro:

    ;encuentro e imprimo la posicion del zorro

    xor     rbx,rbx

    l:

    cmp     byte[tablero+rbx],"X"

    jne     sig
    mov     qword[posZorro],rbx
    jmp     outP
    sig:

    inc     rbx
    cmp     rbx,49
    je      outP

    jmp     l

    outP:

    ;mov     rdi,mjePosZorro    
    ;mov     rsi,[posZorro]
    ;sub     rsp,8
    ;call    printf
    ;add     rsp,8

ret

turnoZorro:

    ;mov     rdi, msgSaveGame
    ;mPutsNotMain
    ;mov     rdi, msgReanudar
    ;mPutsNotMain
    ;mov     rdi, msgSalir
    ;mPutsNotMain
    ; 
    ;mGets   strInput
;
    ;mov     rdi,strInput
    ;mov     rsi,opGuardarStr
    ;sub     rsp,8
    ;call    strcmp
    ;add     rsp,8
    ;cmp     rax,0
    ;je      saveGame
;
    ;mov     rdi,strInput
    ;mov     rsi,opSalirStr
    ;sub     rsp,8
    ;call    strcmp
    ;add     rsp,8
    ;cmp     rax,0
    ;je      exit


    seguirPartida:
    mov     rdi,mjeTurnoZorro
    sub     rsp,64       ;
    call    printf      ;
    add     rsp,64  
    mov     rdi,mjeOcasComidas
    mov     rsi,[ocasComidas]
    sub     rsp,8
    call    printf
    add     rsp,8
    

    ;sub     rsp,8
    call    findPosZorro        ;setea posZorro
    ;add     rsp,8

;-------------------------------------------
    sub     rsp,8
    call    checkPosZorroDestino    ;setea posDestino
    add     rsp,8                ;dentro pedimos posicion, y chequeamos, y la vuelta, mandamos el mensaje de "usted se mueve a..."

 
    ;moverZorro:

    mov     rdi,mjePosDestino
    mov     rsi,[intFil]
    mov     rdx,[intCol]
    sub     rsp,8
    call    printf
    add     rsp,8

    ;cmp     byte[checkOcaEnMedioResult],1
    ;je      saltarOca

    
    mov     rbx,[posDestino]
    mov     byte[tablero+rbx],"X"
    mov     rbx,[posZorro]
    mov     byte[tablero+rbx],"_"

    finTurnoZorro:
    mov     r13,[nameOca]
    mov     [jugTurno],r13      
    
    mov     qword[partidaGuardada],0
ret



checkPosZorroDestino:

    pedirPosZorro:
    sub     rsp,8
    call    pedirPos        ;setea intFil y intCol
    add     rsp,8


    mov     rbx,[intFil]
    mov     rax,7;[line] ; nro de columnas

    mov     r13,[intCol]

    imul    rax,rbx
    add     rax,r13
    mov     [posDestino],rax


    ;me fijo si esta vacia
    mov     rbx,[posDestino]
    mov     al,byte[tablero+rbx]
    cmp     al,"_"
    jne     badPosZorro


    ;Me fijo si es una posicion proxima inmediata
    xor     r12,r12
    mov     r12,[posDestino]
    mov     rbx,[posZorro]

    sub     r12,rbx
    mov     [diff],r12;[Zorro] diferencia (recorrido/salto) = posApuntada - posActual 

    mov     qword[checkOcaEnMedioResult],0

    ;mov     rbx,0
    ;iterarVectorPosCercanas:
    ;cmp     rbx,8
    ;je      seguirCheckPosLejanas
    


    ;cercanas
    cmp     r12,-7;norte
    je      finCheckPosZorroDestino
    cmp     r12,7;sur
    je      finCheckPosZorroDestino
    cmp     r12,1;este
    je      finCheckPosZorroDestino
    cmp     r12,-1;oeste
    je      finCheckPosZorroDestino
    cmp     r12,8;sur este
    je      finCheckPosZorroDestino
    cmp     r12,-8;nor oeste
    je      finCheckPosZorroDestino
    cmp     r12,6;sur oeste
    je      finCheckPosZorroDestino
    cmp     r12,-6;nor este
    je      finCheckPosZorroDestino
    ;inc     rbx

    ;lejanas
    cmp     r12,14
    je      checkOcaEnMedio
    cmp     r12,-14
    je      checkOcaEnMedio
    cmp     r12,2
    je      checkOcaEnMedio
    cmp     r12,-2
    je      checkOcaEnMedio
    cmp     r12,16
    je      checkOcaEnMedio
    cmp     r12,-16
    je      checkOcaEnMedio
    cmp     r12,12
    je      checkOcaEnMedio
    cmp     r12,-12
    je      checkOcaEnMedio
    jmp     pedirPosZorro

    ;:jmp     iterarVectorPosCercanas


    ;cmp     byte[posCercanas+rbx],r12           ;r12 tiene el valor diff
    ;je      finCheckPosZorroDestino
    ;inc     rbx
    ;jmp     iterarVectorPosCercanas

    ;Si se llego aca, entonces posDestino no es cercano
    ;Tengo que ver si es uno lejano, y si lo es, ver si hay una oca en el medio
    ;seguirCheckPosLejanas:  
    ;           mov     rdi,nameZorro
    ;call    puts 
    ;mov     rbx,0
    ;iterarVectorPosLejanas:
    ;cmp     rbx,8
    ;je      badPosZorro
    ;
    ;cmp     qword[posLejanas+rbx],r12
    ;je      checkOcaEnMedio         ;si salta con el je, tengo que setear checkResult
    ;inc     rbx
    ;jmp     iterarVectorPosLejanas


    checkOcaEnMedio:
    
    mov     rbx,[diff]

 
   ; cmp     [diff],0
    ;jl      diffNegativo
    ;jg      diffPositivo

    ;diffNegativo:       ;necesito dividirlo en 2 y restarle eso a posZorro para fijarme si ahi si hay una oca

    ;imul    rbx,-1
    
    mov     rdx,0       ;idiv hace:     rdx:rax / op        donde op (operando) debe ser un registro
    mov     rax,[diff]
    mov     r10,2       ;valor del divisor:2 -> lo copio en un registro, lo requiere idiv   
    idiv    r10
    mov     bl,al     ;resultado de diff/2 lo guardo en rbx

    mov     rdi,indexer
    mov     rsi,rax
    sub     rsp,8
    call    printf
    add     rsp,8


    ;imul    rbx,-1
    xor     r10,r10
    mov     r10b,byte[posZorro]
    cmp     byte[tablero+r10+rbx],"O"
    je      ocaEnMedio 
    jmp     badPosZorro


    ocaEnMedio:

    mov     byte[tablero+rbx+r10],"_"; saco la oca del lugar
    xor     rax,rax
    mov     rax,[ocasComidas]
    inc     al
    mov     [ocasComidas],rax

    ;mov     qword[checkOcaEnMedioResult],1
    ;add     r10,rbx
    ;mov     [posOcaEnMedio],r10     
    jmp     finCheckPosZorroDestino


    badPosZorro:
    mov     rdi,mjePosInvalidaZorro
    call    puts
    

    jmp     pedirPosZorro

    finCheckPosZorroDestino:

ret


pedirPos:


    pedirFila:
    mov     rdi,mjeFila
    call    puts      ;

    mov     rdi,bufferFil
    sub     rsp,8
    call    gets
    add     rsp,8

    mov     rdi,bufferFil
    mov     rsi,formatNum      
	mov		rdx,intFil   ;Formateo el input, str a int    
	sub		rsp,8
	call	sscanf             
	add		rsp,8

    mov     rdi,[intFil]
    sub     rsp,8
    call    checkInt
    add     rsp,8

    cmp     rax,0
    je      pedirFila

  
    pedirColumna:
    mov     rdi,mjeColum
    call    puts

    mov     rdi,bufferCol
    sub     rsp,8
    call    gets
    add     rsp,8
 
    mov     rdi,bufferCol
    mov     rsi,formatNum      
	mov		rdx,intCol   ;Formateo el input, str a int    
	sub		rsp,8
	call	sscanf             
	add		rsp,8
  
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
    mPuts
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

    mov     rdi, nameZorro
    mPuts

    mov     rdi,nL
    mPuts

    mov     rdi, nameZorro
    mPuts
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


    ;mov     rdi,mjeOcasComidas
    ;call    puts



ret
    
mainMenu:

    mov     rdi, titulo
    mPuts
    pedirOpcion:
    mov     rdi, mjeContinue
    mPuts
    mov     rdi, mjeNewRound
    mPuts

    mGets   strInput
    
    mov     rdi,strInput
    mov     rsi,opCargarStr
    sub     rsp,8
    call    strcmp
    add     rsp,8
    cmp     rax,0
    je      openSaved

    mov     rdi,strInput
    mov     rsi,opNuevoStr
    sub     rsp,8
    call    strcmp
    add     rsp,8
    cmp     rax,0
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

    mov     rdi, partidaFileName
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

    inc     qword[partidaGuardada]
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
    cmp     byte[partidaGuardada], 1
    jge     salir
    mov     rdi, msgPartidaNoGuardada
    mPutsNotMain
    mov     rdi, msgSalir
    mPutsNotMain
    mov     rdi, msgReanudar
    mPutsNotMain

    mGets   strInput
    
    ;cmp     qword[strInput], opSeguirStr
    ;je      turnoZorro

    mov     rdi,strInput
    mov     rsi,opSeguirStr
    sub     rsp,8
    call    strcmp
    add     rsp,8
    cmp     rax,0
    je      turnoZorro
    
    
    
    
    ; salir(sin guardar):
    ; al no guardar la partida, hay que sobreescribir partida.bin para que sea igual a tablero.bin

    mov     rdi,tableroNameFile                ;abro tablero.bin para leer
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

    mov     rdi,partidaFileName            ;abro partida.bin, para copiar dentro el contenido de tablero.bin
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

    mov     qword[ocasComidas],0
    
    mov     rdi,ocasComidasStr
    mov     rsi,formatNum
    mov     rdx,[ocasComidas]                   ;Formateo String a Int
    sub     rsp,8
    call    sprintf
    add     rsp,8

    mov     rdi,ocasComidasStr
    mov     rsi,[fileHandle]
    sub     rsp,8
    call    fputs
    add     rsp,8               



    ;mov     rdi, ocasComidasFileName
    ;mov     rsi, saveMode
    ;sub     rsp, 8
    ;call    fopen
    ;add     rsp, 8
    
    ;mov     [ocasComidas],0
    ;mov     rdi,regOcasComidas
    ;mov     rsi,1
    ;mov     rdx,1
    ;mov     rcx,ocasComidasHandle
    ;sub     rsp,8
    ;call    fputs
    ;add     rsp,8

    ;mov     rdi, [fileHandle]
    ;sub     rsp, 64
    ;call    fclose
    ;add     rsp, 64

 
    salir:  
    jmp     endProg
    

cargarOcasComidas:
    mov     rdi, ocasComidasFileName
    mov     rsi, readMode
    sub     rsp, 8
    call    fopen
    add     rsp, 8
    mov     qword[ocasComidasHandle],rax
    cmp     byte[ocasComidasHandle],0
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
    cmp     byte[ocasComidasHandle],0
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
    cmp     qword[ocasComidas], 12
    jge     victoriaZorro

    sub     rsp, 8
    call    findPosZorro
    add     rsp, 8

    ;comparo lo que esta cerca del zorro, si esta rodeado de ocas

    mov     qword[checkNadieGana],0          ;si es 0 no gana nadie
    
    xor     rax,rax
    mov     rbx,0
    iterarPosCercanas:
    cmp     rbx,8
    je      iterarPosLejanas            ;Si entra aca es porque el zorro esta encerrado en la cercanía

    
    mov     al,byte[posZorro]
    add     al,byte[posCercanas+rbx]
    inc     rbx
    cmp     byte[tablero+rax],"_"  
    jne     iterarPosCercanas
    je      nadieGana


    mov     rbx,0
    iterarPosLejanas:
    cmp     rbx,8
    je      victoriaOcas                   ;Si entra aca es porque además no puede saltar a ninguna oca que lo encierra

    mov     al,byte[posZorro]
    add     al,byte[posLejanas+rbx]
    inc     rbx
    cmp     byte[tablero+rax],"_" 
    jne     iterarPosLejanas
    je      nadieGana                       


    
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