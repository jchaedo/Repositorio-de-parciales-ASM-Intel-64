extern malloc
extern strcpy

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text


; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0               ; [0:8)
USUARIO_SEGUIDORES_OFFSET EQU 8;        ; [8:16)
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16;  ; [16:20)
USUARIO_SEGUIDOS_OFFSET EQU 24;         ; [24:32)
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32;    ; [32:36)
USUARIO_BLOQUEADOS_OFFSET EQU 40;       ; [40:48)
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48;  ; [48:52)
USUARIO_ID_OFFSET EQU 52;               ; [52:56)
USUARIO_SIZE EQU 56                     ; [0:56)

; tuit_t *publicar(char *mensaje, usuario_t *usuario);
; mensaje -> rdi 
; usuario -> rsi 
global publicar
publicar:
    ; estamos interactuando con c, así que utilizamos las convenciones definidas en la abi
    ; --- prólogo ---
    push rbp    ; pila alineada
    mov rbp, rsp

    push r12    ; preservamos el mensaje en r12 (es reg no volatil)
    mov r12, rdi
    push r13    ; preservamos el usuario en r13 (es reg no volatil)
    mov r13, rsi
    push r14    ; vamos a utilizar r14 también
    push r15    ; vamos a utilizar r15 también

    ; --- fin prólogo ---
    
    ; creamos el nuevo tuit que va a almacenar el mensaje
    mov rdi, TUIT_SIZE
    call malloc

    ; nos guardamos el puntero al tuit ya que vamos a hacer llamadas a funciones de la libc
    mov r14, rax    ; ahora r14 tiene el puntero al nuevo tuit

    ; le asignamos los atributos al nuevo tuit

    mov word [r14 + TUIT_FAVORITOS_OFFSET], 0

    mov word [r14 + TUIT_RETUITS_OFFSET], 0

    mov r9d, dword [r13 + USUARIO_ID_OFFSET]
    mov dword [r14 + TUIT_ID_AUTOR_OFFSET], r9d

    ; copiamos el mensaje con strcpy
    lea rdi, [r14 + TUIT_MENSAJE_OFFSET]
    mov rsi, r12
    call strcpy

    ; publicamos el tuit en el feed del usuario que publica
    mov rdi, r14
    mov rsi, [r13 + USUARIO_FEED_OFFSET]
    call agregarTuitAFeed

    ; vamos a guardarnos el contador en r12 (antes guardabamos el mensaje ahí pero ya no lo vamos a utilizar)
    xor r12, r12
    ; preservamos la cantidad de seguidores, así no tenemos que acceder a memoria cada vez que verifiquemos la guarda
    xor r15, r15
    mov r15d, dword [r13 + USUARIO_CANT_SEGUIDORES_OFFSET]
    ; vamos a guardarnos el array de seguidores en r13 (antes guardabamos el usuario ahí pero ya no lo vamos a utilizar)
    mov r13, qword [r13 + USUARIO_SEGUIDORES_OFFSET]

    .loop:

    cmp r12, r15
    je .fin

    ; el parámetro 1 es el puntero al nuevo tuit
    mov rdi, r14

    ; calculamos la posición del próximo usuario en el array de seguidores (seguidores[i])
    mov rax, [r13 + r12 * 8] ; --> finalmente tenemos el seguidor i

    ; y ahora accedemos al feed y lo guardamos como parámetro 2 en rsi
    mov rsi, [rax + USUARIO_FEED_OFFSET]
    
    call agregarTuitAFeed
    inc r12
    jmp .loop

    .fin:

    mov rax, r14

    ; epílogo

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp

ret

; void agregarTuitAFeed(tuit_t* tuit, feed_t* feed);
; tuit -> rdi
; feed -> rsi
agregarTuitAFeed:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp    ; pila alineada

    push r12    ; preservamos el tuit en r12 (es reg no volatil)
    mov r12, rdi
    push r13    ; preservamos el feed en r13 (es reg no volatil)
    mov r13, rsi

    ; --- fin prólogo ---

    ; creamos una publicación que contiene un puntero al tuit
    mov rdi, PUBLICACION_SIZE
    call malloc

    ; rax tiene el puntero a lo que va a ser nuestra nueva publicación

    mov qword [rax + PUBLICACION_VALUE_OFFSET], r12

    ; insertamos dicha publicación en el feed pasado por parámetro

    ; nuevaPublicacion->next = feed->first;
    mov r9, qword [r13 + FEED_FIRST_OFFSET]
    mov qword [rax + PUBLICACION_NEXT_OFFSET], r9

    ; feed->first = nuevaPublicacion;
    mov qword [r13 + FEED_FIRST_OFFSET], rax

    ; epílogo

    pop r13
    pop r12
    pop rbp
ret