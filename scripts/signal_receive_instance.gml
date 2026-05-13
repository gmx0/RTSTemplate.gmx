///signal_receive_instance(id,signal name)
// 
//if signal_receive_instance(ID,SIGNAL_NAME)
//{
//Do stuff
//}
//
//PUT IN End Step EVENT

signal_exists();
return ds_list_find_index(global.signal_list,string(argument0.object_index)+"."+string(argument1))>-1
       or
       ds_list_find_index(global.signal_list,string(argument0)+"."+string(argument1))>-1;

//Since strings are preferred, to check for signals for specific instances or objects
//if signal_receive(string(id)+".SIGNAL_NAME") {}
//or
//if signal_receive(string(object_index)+".SIGNAL_NAME") {}

