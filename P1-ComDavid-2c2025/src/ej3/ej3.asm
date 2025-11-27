extern malloc

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


; usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t));
; rdi --> ids
; rsi --> cantidadDeIds
; rdx --> deQueNivelEs
global asignarNivelesParaNuevosUsuarios
asignarNivelesParaNuevosUsuarios:
    ; --- prólogo ---
    push rbp
    mov rbp, rsp

    push r12        ; vamos a utilizarlo para guardar ids
    push r13        ; vamos a utilizarlo para guardar cantidadDeIds

    push r14        ; vamos a utilizarlo para guardar deQueNivelEs
    push r15        ; vamos a utilizarlo para el contador del loop

    push rbx ; vamos a utilizarlo para el puntero a los nuevos usuarios que vamos a devolver
    sub rsp, 8

    ; --- fin prólogo ---

    ; preservamos el valor de los parámetros
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

    ; como pide el enunciado, en el caso de tener 0 ids, devolvemos null
    cmp r13, 0
    je .devolvemosNull

    mov rdi, r13
    shl rdi, 3      ; * 8 porque cada elem del array es un puntero
    call malloc
    mov rbx, rax

    xor r15, r15

    .loop:
        cmp r15, r13
        jge .devolvemosArray
        
        mov rdi, USUARIO_SIZE
        call malloc
        mov r10, rax

        ; inicializamos el nuevo usuario
        mov r8d, dword [r12 + r15 * 4]  ; --> ES 4 PORQUE EL ARRAY DE IDS TIENE VALORES UINT32_T
        mov dword [r10 + USUARIO_ID_OFFSET], r8d

        mov edi, r8d
        call r14
        mov byte [r10 + USUARIO_NIVEL_OFFSET], al

        ; guardamos el usuario en el array

        mov qword [rbx + r15 * 8], r10

        inc r15
    jmp .loop

    .devolvemosNull:
        mov rax, 0
        jmp .fin

    .devolvemosArray:
        mov rax, rbx

    .fin:

    ; epílogo

    add rsp, 8
    pop rbx

    pop r15
    pop r14
    
    pop r13
    pop r12
    
    pop rbp
ret