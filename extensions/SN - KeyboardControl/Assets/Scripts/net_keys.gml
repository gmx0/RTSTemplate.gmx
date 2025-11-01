///net_keys(dataList, clientSocket)
if(instance_exists(obj_keyboard_controller))
{
    with(obj_keyboard_controller)
    {
        ds_grid_resize(clientKeys, max(ds_grid_width(clientKeys), ds_list_size(obj_server.sockets)), ds_list_find_value(argument0, 1));
        ds_grid_resize(justReleased, max(ds_grid_width(justReleased), ds_list_size(obj_server.sockets)), ds_list_find_value(argument0, 1));
        ds_grid_resize(justPressed, max(ds_grid_width(justPressed), ds_list_size(obj_server.sockets)), ds_list_find_value(argument0, 1));
        for(var i = 0; i < ds_grid_height(clientKeys); i++)
        {
            var pressed = (ds_list_find_value(argument0, 2) & power(2, i) == power(2, i));
            if(ds_grid_get(clientKeys, argument1 - 1, i) && !pressed)
            {
                ds_grid_set(justReleased, argument1 - 1, i, true);
            }
            if(!ds_grid_get(clientKeys, argument1 - 1, i) && pressed)
            {
                ds_grid_set(justPressed, argument1 - 1, i, true);
            }
            ds_grid_set(clientKeys, argument1 - 1, i, pressed);
        }
    }
}
