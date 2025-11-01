///net_mouse_is_down(mouseButton, clientSocket)
/*
 * SERVER ONLY
 *
 * Checks if the given client is pressing the given mouse button.
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
        Y = 2;
    else if(argument0 == mb_middle)
        Y = 3;
    else if(argument0 == mb_right)
        Y = 4;
    else
        return false;
    return (ds_grid_get(obj_mouse_controller.mouse, argument1 - 1, Y));
}
return false;
