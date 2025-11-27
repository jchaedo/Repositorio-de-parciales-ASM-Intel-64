EXTERN free
EXTERN strcmp

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0           ; [0:4)
USUARIO_NIVEL_OFFSET EQU 4        ; [4:5)
USUARIO_SIZE EQU 8              ; [0:8)

PRODUCTO_USUARIO_OFFSET EQU 0       ; [0:8)
PRODUCTO_CATEGORIA_OFFSET EQU 8     ; [8:17)
PRODUCTO_NOMBRE_OFFSET EQU 17       ; [17:42)
PRODUCTO_ESTADO_OFFSET EQU 42       ; [42:44)
PRODUCTO_PRECIO_OFFSET EQU 44       ; [44:48)
PRODUCTO_ID_OFFSET EQU 48           ; [48:52)
PRODUCTO_SIZE EQU 56            ; [0:56)

PUBLICACION_NEXT_OFFSET EQU 0       ; [0:8)
PUBLICACION_VALUE_OFFSET EQU 8      ; [8:16)
PUBLICACION_SIZE EQU 16         ; [0:16)

CATALOGO_FIRST_OFFSET EQU 0         ; [0:8)
CATALOGO_SIZE EQU 8             ; [0:8)


;catalogo* removerCopias(catalogo* h)
; rdi --> h
global removerCopias
removerCopias:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12    ; para el catalogo h
    push r13    ; para la publicacion actual en el loop

    ; --- fin prólogo ---

    
    mov r12, rdi
    mov r13, [r12 + CATALOGO_FIRST_OFFSET]

    .loop:
        cmp r13, 0
        je .finLoop

        mov rdi, r13
        call removerAparicionesPosterioresDe

        mov r13, [r13 + PUBLICACION_NEXT_OFFSET]

    jmp .loop
    
    .finLoop:

    mov rax, r12

    ; epílogo

    pop r13
    pop r12
    
    pop rbp
ret




; void removerAparicionesPosterioresDe(publicacion_t* publicacion);
; rdi --> publicacion
removerAparicionesPosterioresDe:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12        ; para la publicacion de referencia
    push r13        ; para la publicacion anterior en el loop
    
    push r14        ; para la publicacion actual en el loop
    sub rsp, 8      ; alineamos la pila

    ; --- fin prólogo ---

    mov r12, rdi
    mov r13, rdi
    mov r14, qword [r12 + PUBLICACION_NEXT_OFFSET]

    .loop:
        cmp r14, 0
        je .finLoop

        mov rdi, r12
        mov rsi, r14
        call tienenProductosIguales
        cmp ax, 0
        je .noTienenProductosIguales

            mov r8, qword [r14 + PUBLICACION_NEXT_OFFSET]
            mov qword [r13 + PUBLICACION_NEXT_OFFSET], r8

            ; liberamos la memoria del producto
            
            mov rdi, qword [r14 + PUBLICACION_VALUE_OFFSET]
            call free

            ; liberamos la memoria de la publicacion
            mov rdi, r14
            call free

            mov r14, qword [r13 + PUBLICACION_NEXT_OFFSET]

            jmp .continue
        
        .noTienenProductosIguales:

            mov r13, r14
            mov r14, qword [r14 + PUBLICACION_NEXT_OFFSET]

        .continue:
        
    jmp .loop
    
    .finLoop:

    ; epílogo

    add rsp, 8
    pop r14

    pop r13
    pop r12
    
    pop rbp
ret

; uint16_t tienenProductosIguales(publicacion_t *pub1, publicacion_t *pub2);
; rdi --> pub1
; rsi --> pub2
tienenProductosIguales:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12    ; para el producto de la pub1
    push r13    ; para el producto de la pub2
    
    ; --- fin prólogo ---

    mov r12, [rdi + PUBLICACION_VALUE_OFFSET]
    mov r13, [rsi + PUBLICACION_VALUE_OFFSET]

    ; el nombre y el usuario de ambos son iguales?
    
    lea rdi, qword [r12 + PRODUCTO_NOMBRE_OFFSET]
    lea rsi, qword [r13 + PRODUCTO_NOMBRE_OFFSET]
    call strcmp
    cmp rax, 0
    jne .false

    mov r8, qword [r12 + PRODUCTO_USUARIO_OFFSET]
    mov r9, qword [r13 + PRODUCTO_USUARIO_OFFSET]
    cmp r8, r9
    jne .false

    ; si sigue es que cumple todas las condiciones
    
    mov ax, 1
    jmp .fin

    .false:
    xor ax, ax

    .fin:

    ; epílogo

    pop r13
    pop r12
    
    pop rbp
ret