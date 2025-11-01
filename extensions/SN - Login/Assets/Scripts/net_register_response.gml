///net_register_response(Datalist, [clientSocket])
/*
 * Will be executed when client/server recieve a packet with the Register Packet
 * Identifier.
*/
if(net_is_server())
{
    var username = ds_list_find_value(argument[0], 1);
    var password = ds_list_find_value(argument[0], 2);
    var salt = ds_list_find_value(argument[0], 3);
    if(net_is_username_taken(username))
    {
        net_packet_create("Register");
        net_packet_add(false, "Username has been taken");
        net_packet_send(argument[1]);
        return false;
    }
    if(string_length(username) <= 3)
    {
        net_packet_create("Register");
        net_packet_add(false, "Username is too short");
        net_packet_send(argument[1]);
        return false;
    }
    if(string_length(password) < 6)
    {
        net_packet_create("Register");
        net_packet_add(false, "Password is too short");
        net_packet_send(argument[1]);
        return false;
    }
    
    net_register_add_user(username, password, salt);
    net_packet_create("Register");
    net_packet_add(true);
    net_packet_send(argument[1]);
}
if(net_is_client())
{
    if(ds_list_find_value(argument[0], 1))
    {
        show_message("Registration sucessful!");
    }
    else
    {
        show_message("Could not register..");
    }
}
