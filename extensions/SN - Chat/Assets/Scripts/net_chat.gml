///net_chat(dataList, [clientSocket])
if(net_is_server() && instance_exists(obj_chat))
{
    with(obj_chat)
    {
        ds_list_insert(chat, 0, ds_list_find_value(argument[0], 1));
        net_packet_create("Chat");
        for(var i = 0; i < min(ds_list_size(chat), maxChatHistory); i ++)
        {
            net_packet_add(ds_list_find_value(chat, i));
        }
        net_packet_send(Net.AllClients);
    }
}
if(net_is_client() && instance_exists(obj_chat))
{
    with(obj_chat)
    {
        ds_list_clear(chat);
        for(var i = 1; i < ds_list_size(argument[0]); i ++)
        {
            ds_list_add(chat, ds_list_find_value(argument[0], i));
        }
    }
}
