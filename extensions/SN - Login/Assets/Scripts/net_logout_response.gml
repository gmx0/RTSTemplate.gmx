///net_logout_response(dataList, [clientSocket])
/*
 * Executes on client/server when they recieve a packet with the Logout packet identifier.
*/

if(net_is_server())
{
    var username = ds_map_find_value(obj_login_controller.loggedInUsers, argument[1]);
    net_packet_create("Logout");
    if(net_is_user_logged_in(argument[1]))
    {
        ds_map_delete(obj_login_controller.loggedInUsers, argument[1]);
        net_packet_add(true);
    }
    else
    {
        net_packet_add(false);
    }
    net_packet_send(argument[1]);
}
if(net_is_client())
{
    if(ds_list_find_value(argument[0], 1))
    {
        obj_login_controller.loggedIn = false;
        show_message("Sucessully logged out!");
    }
    else
    {
        show_message("Could not log out..");
    }
}
