///net_salt_response(datalist, [clientSocket])
/*
 * This will execute when the client/server recieves a packet with the "Salt" Packet
 * Identifier.
*/
if(net_is_server())
{
    var username = ds_list_find_value(argument[0], 1);
    var salt = "";
    
    ini_open("login.ini");
    var key = 0;
    while(ini_key_exists("users", string(key)))
    {
        var user = ini_read_string("users", string(key), "");
        if(user == username)
        {
            net_packet_create("Salt");
            net_packet_add(ini_read_string("salts", string(key), ""));
            net_packet_send(argument[1]);
            ini_close();
            return false;
        }
        key += 1;
    }
    ini_close();
    net_packet_create("Salt");
    net_packet_add(":");
    net_packet_send(argument[1]);
}
if(net_is_client())
{
    obj_login_controller.salt = ds_list_find_value(argument[0], 1);
    if(string_length(obj_login_controller.salt) == 1)
    {
        show_message("Could not login. User does not exist");
        obj_login_controller.salt = "";
    }
}
