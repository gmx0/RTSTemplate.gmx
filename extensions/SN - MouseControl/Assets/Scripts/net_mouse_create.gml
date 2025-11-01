///net_mouse_create()
/*
 * Initializes the mouse controller.
 *
 * Returns: None
*/
if(!instance_exists(obj_mouse_controller))
{
    instance_create(0, 0, obj_mouse_controller);
}
