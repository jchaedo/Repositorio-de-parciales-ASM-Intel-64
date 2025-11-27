extern malloc

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

NULL EQU 0

; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
; rdi --> usuario
; rsi --> esTuitSobresaliente
global trendingTopic 
trendingTopic:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp
    
    push r12
    mov r12, rdi
    push r13
    mov r13, rsi

    push r14
    push r15

    push rbx
    sub rsp, 8

    ; --- fin prólogo ---

    ; contamos la cantidad de tuits sobresalientes

    xor rbx, rbx

    call cantTuitsSobresalientes
    ; si no hay tuits sobresalientes, devolvemos 0 inmediatamente
    cmp rax, 0
    je .fin

    inc rax         ; necesitamos una posición más en el array para NULL
    shl rax, 3
    mov rdi, rax
    call malloc
    mov rbx, rax    ; preservamos el valor de truitsSobresalientes

    ; ahora tenemos el array de truitsSobresalientes que vamos a devolver en rax
    
    ; obtenemos la primera publicación del usuario
    mov r14, [r12 + USUARIO_FEED_OFFSET]
    mov r14, [r14 + FEED_FIRST_OFFSET]
    ; vamos a guardarlos la posición del array que queremos llenar en r15
    xor r15, r15

    .loop:
        cmp r14, NULL
        je .insertarNullAlFinal

        ; verificamos si es un tuit sobresaliente del usuario pasado por parámetro
        
        ; primero vemos si es tuit sobresaliente
            mov rdi, [r14 + PUBLICACION_VALUE_OFFSET]
            call r13    ; esTuitSobresaliente(p->value)
            cmp rax, 0
            je .continuarCiclo
        
        ; luego vemos si es del usuario

            ; r8 tiene el tuit
            mov r8, [r14 + PUBLICACION_VALUE_OFFSET]

            ; comparamos el id del tuit con el del usuario
            mov r10d, dword [r8 + TUIT_ID_AUTOR_OFFSET]
            mov r11d, dword [r12 + USUARIO_ID_OFFSET]
            cmp r10d, r11d
            jne .continuarCiclo

                mov qword [rbx + r15 * 8], r8
                inc r15

        .continuarCiclo:

        mov r14, [r14 + PUBLICACION_NEXT_OFFSET]

    jmp .loop

    .insertarNullAlFinal:

    mov qword [rbx + r15 * 8], NULL

    .fin:

    mov rax, rbx

    ; epílogo
    
    add rsp, 8
    pop rbx

    pop r15
    pop r14

    pop r13
    pop r12

    pop rbp

ret


; size_t cantTuitsSobresalientes(usuario_t *user, uint8_t (*esTuitSobresaliente)(tuit_t *));
; rdi --> usuario
; rsi --> esTuitSobresaliente
cantTuitsSobresalientes:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12
    mov r12, rdi    ; preservamos el usuario en r12
    push r13
    mov r13, rsi    ; preservamos el puntero a la función esTuitSobresaliente en r13

    push r14
    push r15
    
    ; --- fin prólogo ---]

    ; obtenemos la primera publicación del usuario
    mov r14, [r12 + USUARIO_FEED_OFFSET]
    mov r14, [r14 + FEED_FIRST_OFFSET]
    ; vamos a guardar la cantidad de tuits sobresalientes en r15
    xor r15, r15

    .loop:
        cmp r14, NULL
        je .fin

        ; verificamos si es un tuit sobresaliente del usuario pasado por parámetro
        
        ; primero vemos si es tuit sobresaliente
            mov rdi, [r14 + PUBLICACION_VALUE_OFFSET]
            call r13    ; esTuitSobresaliente(p->value)
            cmp rax, 0
            je .continuarCiclo
        
        ; luego vemos si es del usuario
            ; r8 tiene el tuit
            mov r8, [r14 + PUBLICACION_VALUE_OFFSET]

            ; comparamos el id del tuit con el del usuario
            mov r10d, dword [r8 + TUIT_ID_AUTOR_OFFSET]
            mov r11d, dword [r12 + USUARIO_ID_OFFSET]
            cmp r10d, r11d
            jne .continuarCiclo

            inc r15

        .continuarCiclo:

        mov r14, [r14 + PUBLICACION_NEXT_OFFSET]

    jmp .loop

    .fin:

    mov rax, r15

    ; epílogo

    pop r15
    pop r14
    
    pop r13
    pop r12
    
    pop rbp
    
ret