#include "../ejs.h"


uint16_t tienenProductosIguales(publicacion_t *pub1, publicacion_t *pub2) {
    
   producto_t *prod1 = pub1->value;
   producto_t *prod2 = pub2->value;
   // el nombre y el usuario de ambos son iguales?
   
   if (strcmp(prod1->nombre,prod2->nombre) != 0) return 0;
   if (prod1->usuario != prod2->usuario) return 0;

   // si sigue es que cumple todas las condiciones
   return 1;
}

void removerAparicionesPosterioresDe(publicacion_t* publicacion) {

   publicacion_t* pubAnterior = publicacion;
   publicacion_t* pubActual = publicacion->next;

   while (pubActual != NULL) {

      if (tienenProductosIguales(publicacion, pubActual)) {
         
         pubAnterior->next = pubActual->next;
         // liberamos la memoria del producto
         free(pubActual->value);
         // liberamos la memoria de la publicacion
         free(pubActual);

         pubActual = pubAnterior->next;
      } else {

         pubAnterior = pubActual;
         pubActual = pubActual->next;
      }
   }
}

catalogo_t *removerCopias(catalogo_t *h) {
   
   publicacion_t *pub = h->first;

   while (pub != NULL) {

      removerAparicionesPosterioresDe(pub);
      pub = pub->next;
   }
   
   return h;
}
