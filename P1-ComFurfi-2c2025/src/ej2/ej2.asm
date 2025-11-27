extern free

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

; void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear);
; rdi --> usuario
; rsi --> usuarioABloquear
global bloquearUsuario 
bloquearUsuario:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp    ; pila alineada
    push r12    ; vamos a preservar el usuario en r12
    mov r12, rdi
    push r13    ; vamos a preservar el usuarioABloquear en r13
    mov r13, rsi

    ; --- fin prólogo ---

    ; int posNuevoBloqueado = usuario->cantBloqueados;
    xor r9, r9
    mov r9d, dword [r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    ; ponemos usuario->bloqueados en r10 (ahora tenemos un ptr al array de bloqueados)
    mov r10, [r12 + USUARIO_BLOQUEADOS_OFFSET]

    ; y ahora vamos a poner al usuarioABloquear en el última posición del array
    mov [r10 + r9 * 8], r13

    ; luego, aumentamos la cant de usuarios bloqueados
    ; usuario->cantBloqueados++;
    inc dword [r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    ; borramos los tuits del bloqueador en el feed del bloqueado
    mov rdi, r12
    mov rsi, [r13 + USUARIO_FEED_OFFSET]
    call borrarTuitsDeFeed

    ; borramos los tuits del bloqueado en el feed del bloqueador
    mov rdi, r13
    mov rsi, [r12 + USUARIO_FEED_OFFSET]
    call borrarTuitsDeFeed

    ; epílogo

    pop r13
    pop r12

    pop rbp

ret

; void borrarTuitsDeFeed(usuario_t *usuario, feed_t *feed);
; rdi --> usuario
; rsi --> feed
borrarTuitsDeFeed:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp    ; pila alineada
    push r12        ; vamos a preservar el usuario en r12
    mov r12, rdi
    push rbx        ; vamos a preservar el feed en rbx
    mov rbx, rsi
    push r13        ; vamos a utilizar r13
    push r14        ; vamos a utilizar r14
    push r15        ; vamos a utilizar r15

    ; --- fin prólogo ---

    xor r13, r13                            ; publicacion anterior
    mov r14, [rbx + FEED_FIRST_OFFSET]      ; publicacion actual
    xor r15, r15                            ; publicacion siguiente
    
    .loop:
        cmp r14, NULL
        je .fin
        
        mov r15, [r14 + PUBLICACION_NEXT_OFFSET]    ; publicacion siguiente

        ; r9 = publicacion->value->id_autor

        mov r9, [r14 + PUBLICACION_VALUE_OFFSET]
        mov r9d, dword [r9 + TUIT_ID_AUTOR_OFFSET]

        cmp r9d, dword [r12 + USUARIO_ID_OFFSET]
        jne .noEliminamosPublicacion

            ; como no saltamos, tenemos que eliminar la publicación actual
            
            cmp r13, NULL
            je .esPrimerPublicacion

                mov [r13 + PUBLICACION_NEXT_OFFSET], r15    ; ahora la publicacion va a estar conectada con la siguiente
                jmp .hacemosFree

            .esPrimerPublicacion:

                mov [rbx + FEED_FIRST_OFFSET], r15

            .hacemosFree:

            mov rdi, r14
            call free
            jmp .sigueWhile
            
        .noEliminamosPublicacion:

            mov r13, r14
        
        .sigueWhile:

        mov r14, r15
        jmp .loop

    .fin:

    ; epílogo

    pop r15

    pop r14
    pop r13
    
    pop rbx
    pop r12
    
    pop rbp

ret