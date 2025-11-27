#include "../ejs.h"


size_t cantTuitsSobresalientes(usuario_t *user,
                                uint8_t (*esTuitSobresaliente)(tuit_t *)) {
    size_t cant = 0;

    publicacion_t *p = user->feed->first;
    while (p != NULL) {
        tuit_t *tuit = p->value;
        if (esTuitSobresaliente(tuit) && tuit->id_autor == user->id) cant++;
        p = p->next;
    }
    return cant;
}

tuit_t **trendingTopic(usuario_t *user,
                       uint8_t (*esTuitSobresaliente)(tuit_t *)) {
    
    size_t cantSobresalientes = cantTuitsSobresalientes(user, esTuitSobresaliente);
    if (cantSobresalientes == 0) return NULL;

    tuit_t ** tuitsSobreSalientes = malloc(sizeof(tuit_t*) * (cantSobresalientes + 1));
    publicacion_t *p = user->feed->first;

    size_t posTuit = 0;
    while (p != NULL) {
        tuit_t *tuit = p->value;
        if (esTuitSobresaliente(tuit) && tuit->id_autor == user->id) {
            tuitsSobreSalientes[posTuit] = tuit;
            posTuit++;
        }
        p = p->next;
    }
    tuitsSobreSalientes[posTuit] = NULL;

    return tuitsSobreSalientes;
}
