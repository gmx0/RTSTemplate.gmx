///net_mouse_get_y(clientSocket)
/*
 * SERVER ONLY
 *
 * Gives the mouse y of the given client
 *
 * clientSocket: The client to check
 *
 * Returns: The y coordinate of the mouse of the client
*/
if(net_is_server() && instance_exists(obj_mouse_controller))
{
    return (ds_grid_get(obj_mouse_controller.mouse, argument0 - 1, 1));
}
return false;
