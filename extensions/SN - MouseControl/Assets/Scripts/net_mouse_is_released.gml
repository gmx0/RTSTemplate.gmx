///net_mouse_is_released(mouseButton, clientSocket)
/*
 * SERVER ONLY
 *
 * Checks if the given client has just pressed the given mouse button.
 *
 * mouseButton: The button to check
 * clientSocket: The client to check
 *
 * Returns: true if the client is pressing the button, false otherwise
*/
if(net_is_server() && instance_exists(obj_mouse_controller))
{
    var Y;
    if(argument0 == mb_left)
        Y = 0;
    else if(argument0 == mb_middle)
        Y = 1;
    else if(argument0 == mb_right)
        Y = 2;
    else
        return false;
    return (ds_grid_get(obj_mouse_controller.justReleased, argument1 - 1, Y));
}
return false;
