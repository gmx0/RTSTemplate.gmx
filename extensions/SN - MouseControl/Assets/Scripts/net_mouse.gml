///net_mouse(dataList, clientSocket)
/*
 * Is executed when the server recieves a Mouse packet
*/

if(ds_grid_width(obj_mouse_controller.mouse) < argument1)
{
    ds_grid_resize(obj_mouse_controller.mouse, argument1, ds_grid_height(obj_mouse_controller.mouse));
    ds_grid_resize(obj_mouse_controller.justPressed, argument1, ds_grid_height(obj_mouse_controller.justPressed));
    ds_grid_resize(obj_mouse_controller.justReleased, argument1, ds_grid_height(obj_mouse_controller.justReleased));
}   
ds_grid_set(obj_mouse_controller.mouse, argument1 - 1, 0, ds_list_find_value(argument0, 1));
if(ds_list_size(argument0) > 2)
    ds_grid_set(obj_mouse_controller.mouse, argument1 - 1, 1, ds_list_find_value(argument0, 2));
if(ds_list_size(argument0) > 3)
{
    var _left = ds_list_find_value(argument0, 3);
    var _current = ds_grid_get(obj_mouse_controller.mouse, argument1 - 1, 2);
    if(_left && !_current)
        ds_grid_set(obj_mouse_controller.justPressed, argument1 - 1, 0, true);
    if(!_left && _current)
        ds_grid_set(obj_mouse_controller.justReleased, argument1 - 1, 0, true);
    
    ds_grid_set(obj_mouse_controller.mouse, argument1 - 1, 2, _left);
}
if(ds_list_size(argument0) > 4)
{
    var _middle = ds_list_find_value(argument0, 4);
    var _current = ds_grid_get(obj_mouse_controller.mouse, argument1 - 1, 3);
    if(_middle && !_current)
        ds_grid_set(obj_mouse_controller.justPressed, argument1 - 1, 1, true);
    if(!_middle && _current)
        ds_grid_set(obj_mouse_controller.justReleased, argument1 - 1, 1, true);
    
    ds_grid_set(obj_mouse_controller.mouse, argument1 - 1, 3, _middle);
}    
if(ds_list_size(argument0) > 5)
{
    var _right = ds_list_find_value(argument0, 5);
    var _current = ds_grid_get(obj_mouse_controller.mouse, argument1 - 1, 4);
    if(_right && !_current)
        ds_grid_set(obj_mouse_controller.justPressed, argument1 - 1, 2, true);
    if(!_right && _current)
        ds_grid_set(obj_mouse_controller.justReleased, argument1 - 1, 2, true);
    
    ds_grid_set(obj_mouse_controller.mouse, argument1 - 1, 4, _right);
}    
