///net_salt_get(username)
/*
 * CLIENT ONLY
 *
 * Requests the salt from the server
 *
 * username: The username of the user that wants the salt
*/
net_packet_create("Salt");
net_packet_add(argument0);
net_packet_send();
