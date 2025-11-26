#include "../ejs.h"

uint16_t esProductoNuevoDeUsuarioVerificado(producto_t *producto) {
    
    uint16_t estadoProducto = producto->estado;
    uint8_t nivelUsuario = producto->usuario->nivel;
    if (estadoProducto != 1) return 0;
    if (nivelUsuario == 0) return 0;

    // si sigue es que cumple todas las condiciones
    return 1;
}

size_t contarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *catalogo) {
    
    size_t cant = 0;
    publicacion_t *pub = catalogo->first;

    while (pub != NULL) {

        producto_t *prod = pub->value;
        if (esProductoNuevoDeUsuarioVerificado(prod)) cant++;

        pub = pub->next;
    }

    return cant;
}

producto_t *filtrarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *h) {
    
    // creamos el array con las publicaciones que cumplen el criterio
    size_t tam_array_filtrado = contarPublicacionesNuevasDeUsuariosVerificados(h);
    tam_array_filtrado++;   // necesitamos un espacio más para el elem null
    producto_t **res = malloc(sizeof(void *) * tam_array_filtrado);
    
    // agarramos la primera publicación del catálogo
    publicacion_t *pub = h->first;
    size_t posActual = 0;

    while (pub != NULL) {

        producto_t *prod = pub->value;
        if (esProductoNuevoDeUsuarioVerificado(prod)) {
            
            res[posActual] = prod;
            posActual++;
        }
        pub = pub->next;
    }

    // insertamos el último elemento null
    res[posActual] = NULL;

    return (producto_t *) res;
}
