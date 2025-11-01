///net_login_response(DataList, [clientSocket])
/*
 * Executes when client/server recieve a packet with the identifier "Login"
*/

if(net_is_server())
{
    //If user is already logged in
    if(net_is_user_logged_in(argument[1]))
    {
        net_packet_create("Login");
        net_packet_add(false);
        net_packet_send(argument[1]);
        return false;
    }
    
    var username = ds_list_find_value(argument[0], 1);
    var password = ds_list_find_value(argument[0], 2);
    var correct = net_is_credentials_valid(username, password);
    net_packet_create("Login");
    if(correct)
    {
        ds_map_add(obj_login_controller.loggedInUsers, argument[1], username);
        net_packet_add(true);
        var token = net_salt_create(32);
        net_register_token(username, token);
        net_packet_add(token);
    }
    else
    {
        net_packet_add(false);
    }
    net_packet_send(argument[1]);
}
if(net_is_client())
{
    var answer = ds_list_find_value(argument[0], 1);
    if(answer)
    {
        obj_login_controller.loggedIn = true;
        ini_open("token.ini");
        ini_write_string("token", "0", string(ds_list_find_value(argument[0], 2)));
        ini_close();
        show_message("Login successful!");
    }
    else
    {
        show_message("Login failed!");
    }
}
