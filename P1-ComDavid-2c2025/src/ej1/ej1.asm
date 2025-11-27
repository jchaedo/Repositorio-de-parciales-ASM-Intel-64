EXTERN malloc

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
PRODUCTO_SIZE EQU 56            ; [0:56) --> el elem más grande es un ptr

PUBLICACION_NEXT_OFFSET EQU 0       ; [0:8)
PUBLICACION_VALUE_OFFSET EQU 8      ; [8:16)
PUBLICACION_SIZE EQU 16         ; [0:16)

CATALOGO_FIRST_OFFSET EQU 0         ; [0:8)
CATALOGO_SIZE EQU 8             ; [0:8)


; producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo* catalogo)
; rdi --> catalogo
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12    ; vamos a guardar el resultado en r12
    push r13    ; vamos a guardar la publicacion del loop en r13
    
    push r14    ; vamos a guardar la posicion actual del arreglo que devolvemos en r14
    push r15    ; vamos a guardar el producto del loop en r15

    ; --- fin prólogo ---

    ; agarramos la primer publicación del catálogo
    mov r13, qword [rdi + CATALOGO_FIRST_OFFSET]

    ; creamos el array con las publicaciones que cumplen el criterio

    call contarPublicacionesNuevasDeUsuariosVerificados
    inc rax     ; necesitamos un espacio más para el elem null
    shl rax, 3  ; multiplicamos la cant del elem por el tamaño de un puntero (8)

    mov rdi, rax
    call malloc
    mov r12, rax

    ; incializamos un indice que nos dice en que posicion del array va el prox elem
    xor r14, r14

    ; insertamos el último elemento null

    .loop:
        cmp r13, 0
        je .fin

        ; obtenemos el producto de la publicacion actual
        mov r15, qword [r13 + PUBLICACION_VALUE_OFFSET]

        mov rdi, r15
        call esProductoNuevoDeUsuarioVerificado
        cmp ax, 0
        je .continue

            mov qword [r12 + r14 * 8], r15
            inc r14

        .continue:

        mov r13, [r13 + PUBLICACION_NEXT_OFFSET]

    jmp .loop

    .fin:

    ; insertamos el último elemento null
    mov qword [r12 + r14 * 8], 0

    ; guardamos el resultado en rax
    mov rax, r12

    ; epílogo

    pop r15
    pop r14

    pop r13
    pop r12

    pop rbp
ret


; size_t contarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *catalogo);
; rdi --> catalogo
contarPublicacionesNuevasDeUsuariosVerificados:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    ; vamos a usar estos dos regs no volatiles
    push r12    ; para la publicacion actual en el loop
    push r13    ; para el contador de publicaciones que cumple el criterio
    
    ; --- fin prólogo ---

    mov r12, qword [rdi + CATALOGO_FIRST_OFFSET]
    xor r13, r13

    .loop:
        cmp r12, 0
        je .fin

        ; vemos si el producto de la publicacion actual cumple el criterio
        mov rdi, qword [r12 + PUBLICACION_VALUE_OFFSET]

        call esProductoNuevoDeUsuarioVerificado
        cmp ax, 0
        je .continue

            inc r13

        .continue:

        mov r12, [r12 + PUBLICACION_NEXT_OFFSET]

    jmp .loop

    .fin:

    ; guardamos el resultado en rax
    mov rax, r13

    ; epílogo

    pop r13
    pop r12
    
    pop rbp
ret


; uint16_t esProductoNuevoDeUsuarioVerificado(producto_t *producto);
; rdi --> producto
esProductoNuevoDeUsuarioVerificado:
    
    ; NO NECESITAMOS HACER PRÓLOGO PORQUE NO VAMOS A LLAMAR A OTRAS FUNCIONES

    ; obtenemos el estado del producto y el nivel del usuario
    
    mov r8w, word [rdi + PRODUCTO_ESTADO_OFFSET]
    
    mov r10, qword [rdi + PRODUCTO_USUARIO_OFFSET]
    mov r9b, byte [r10 + USUARIO_NIVEL_OFFSET]

    ; de base el resultado sería 0 (no pasa nada con guardarlo en un reg volátil porque no vamos a llamar a otras funciones)
    xor ax, ax
    
    ; si el estado no es 1 o el usuario es nivel 0, entonces no es un producto que cumple el criterio (return 0)
    cmp r8w, 1
    jne .fin
    cmp r9b, 0
    je .fin
    
    ; si seguimos acá, significa que se cumplieron ambas condiciones del criterio, así que cambiamos el rdo a 1
    mov ax, 1
    
    .fin:
ret