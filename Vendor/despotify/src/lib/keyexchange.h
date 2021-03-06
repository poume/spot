/*
 * $Id: keyexchange.h 182 2009-03-12 08:21:53Z zagor $
 *
 */

#ifndef DESPOTIFY_KEYEXCHANGE_H
#define DESPOTIFY_KEYEXCHANGE_H

#include "session.h"

int send_client_initial_packet (SESSION *);
int read_server_initial_packet (SESSION *);
int do_key_exchange (SESSION * c);
void key_init (SESSION *);
#endif
