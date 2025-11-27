#include "../ejs.h"
#include <string.h>

void agregarTuitAFeed(tuit_t* tuit, feed_t* feed) {

  // creamos una publicación que contiene un puntero al tuit
  publicacion_t *nuevaPublicacion = malloc(sizeof(publicacion_t));
  nuevaPublicacion->value = tuit;

  // insertamos dicha publicación en el feed pasado por parámetro
  nuevaPublicacion->next = feed->first;
  feed->first = nuevaPublicacion;
}


// Función principal: publicar un tuit
tuit_t *publicar(char *mensaje, usuario_t *user) {

  tuit_t *nuevoTuit = malloc(sizeof(tuit_t));
  
  nuevoTuit->retuits = 0;
  nuevoTuit->favoritos = 0;
  nuevoTuit->id_autor = user->id;
  strcpy(nuevoTuit->mensaje, mensaje);

  // publicamos el tuit en el feed del usuario que publica
  agregarTuitAFeed(nuevoTuit, user->feed);

  // publicamos el tuit en el feed de sus seguidores
  uint32_t i = 0;
  while(i < user->cantSeguidores) {
    agregarTuitAFeed(nuevoTuit, user->seguidores[i]->feed);
    i++;
  }

  return nuevoTuit;
  
}
