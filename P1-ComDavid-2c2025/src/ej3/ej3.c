#include "../ejs.h"
#include <stdint.h>

usuario_t **
asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds,
                                 uint8_t (*deQueNivelEs)(uint32_t)) {

  if (cantidadDeIds == 0) return NULL;

  usuario_t **nuevosUsuarios = malloc(sizeof(void *) * cantidadDeIds);

  for (size_t i = 0; i < cantidadDeIds; i++) {

    usuario_t *nuevoUsuario = malloc(sizeof(usuario_t));

    // inicializamos el nuevo usuario
    nuevoUsuario->id = ids[i];
    nuevoUsuario->nivel = deQueNivelEs(ids[i]);

    // guardamos el usuario en el array
    nuevosUsuarios[i] = nuevoUsuario;
  }

  return nuevosUsuarios;
}
