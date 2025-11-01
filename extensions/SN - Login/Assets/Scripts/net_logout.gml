///net_logout()
/*
 * CLIENT ONLY
 * 
 * Sends a packet to the server telling it that we want to log out.
*/
net_packet_create("Logout");
net_packet_send();
