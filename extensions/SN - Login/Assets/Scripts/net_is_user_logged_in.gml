///net_is_user_logged_in(clientSocket)
/*
 * SERVER ONLY
 *
 * Checks if the user with the given client socket is logged in. A client van be connected
 * but not logged in. This script checks if the connected client is logged in as well.
 *
 * clientSocket: The client socket to check.
*/


if(instance_exists(obj_login_controller))
{
    return (ds_map_find_value(obj_login_controller.loggedInUsers, argument0) != undefined);
}   
return false;
