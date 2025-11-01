///net_button_is_pressed(name, clientSocket)
/*
 * SERVER ONLY
 *
 * Checks if the button that is binded to the name is pressed for the 
 * given client.
 *
 * name:         The button, e.g. "MoveLeft".
 * clientSocket: The client to check for.
 *
 * Returns: true if the buttons is down, false otherwise.
*/
if(!net_is_server())
{
    return false;
}
if(!instance_exists(obj_keyboard_controller))
{
    return false;
}
var name = argument0, client = argument1 - 1;
var _index = ds_list_find_index(obj_keyboard_controller.names, name);
if(_index == -1)
{
    return false;
}
return ds_grid_get(obj_keyboard_controller.justPressed, client, _index);
