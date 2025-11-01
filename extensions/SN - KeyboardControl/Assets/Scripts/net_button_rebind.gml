///net_button_rebind(name, button)
/* 
 * Reinds a button to a name, the name is then used to check if that key is
 * down on the client. 
 *
 * name:   The name of the binding.
 * button: The standard key of the binding.
 *
 * Returns: true if the binding succeeded, false otherwise
*/
if(!instance_exists(obj_keyboard_controller))
    instance_create(0, 0, obj_keyboard_controller);

var _index = ds_list_find_index(obj_keyboard_controller.keys, argument1)
if(_index == -1)
{
    show_error("Trying to rebind " + string(argument0) + ", but there is no bind with that name.", false);
    return false;
}

ds_list_replace(obj_keyboard_controller.names, index, argument0);
ds_list_replace(obj_keyboard_controller.keys, index, argument1);
return true;
