#include "../ejs.h"

void borrarTuitsDeFeed(usuario_t *usuario, feed_t *feed) {

  // if (feed->first == NULL) return;
  
  publicacion_t *p = feed->first;
  publicacion_t *pAnt = NULL;
  publicacion_t *pSig = NULL;
  while (p != NULL) {
    pSig = p->next;

    if (p->value->id_autor == usuario->id) {

      // si eliminamos la publicacion:
      if (pAnt != NULL) {
        
        pAnt->next = pSig;
      } else {
        
        feed->first = pSig; // la siguiente pub se convierte en el principio de la lista feed
      }
      free(p);
    } else {

      // si no eliminamos la publicacion:
      pAnt = p;
    }
    p = pSig;
    if (pSig != NULL) pSig = p->next;
  }
}

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear){

  int posNuevoBloqueado = usuario->cantBloqueados;
  usuario->bloqueados[posNuevoBloqueado] = usuarioABloquear;
  usuario->cantBloqueados++;
  borrarTuitsDeFeed(usuario, usuarioABloquear->feed);
  borrarTuitsDeFeed(usuarioABloquear, usuario->feed);
}
