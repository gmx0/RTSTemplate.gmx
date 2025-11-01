///net_register(username, password)
/*
 * CLIENT ONLY
 *
 * Registers a new client. The password will be salted and encoded in the process.
 *
 * username: The username of the client
 * password: The password of the client
*/

var salt = net_salt_create();
net_packet_create("Register");
net_packet_add(argument0, sha1_string_utf8(argument1 + salt), salt);
net_packet_send();
