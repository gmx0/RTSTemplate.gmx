///net_token_response(dataList, [clientSocket])
/*
 * Executes when client/server recieves a packet with the Packet Identifier "token"
*/

if(net_is_server())
{
    var username = net_get_username_from_token(ds_list_find_value(argument[0], 1));
    if(username == "" || net_is_user_logged_in(argument[1]))
    {
        net_packet_create("Token");
        net_packet_add(false);
        net_packet_send(argument[1]);
        return false;
    }
    net_packet_create("Token");
    net_packet_add(true);
    net_packet_send(argument[1]);
    ds_map_add(obj_login_controller.loggedInUsers, argument[1], username);
}
if(net_is_client())
{
    var answer = ds_list_find_value(argument[0], 1);
    if(answer)
    {
        obj_login_controller.loggedIn = true;
        show_message("Login with token successful!");
    }
    else
    {
        show_message("Login failed!");
    }
}
