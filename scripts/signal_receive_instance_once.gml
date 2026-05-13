///signal_receive_instance_once(id,signal name)
// 
//if signal_receive_instance_once(ID,SIGNAL_NAME)
//{
//Do stuff for specific instance or object
//then removes the signal for all
//}
//
//PUT IN End Step EVENT

signal_exists();
var sig=ds_list_find_index(global.signal_list,string(argument0)+"."+string(argument1));
if sig>-1
{
ds_list_delete(global.signal_list,sig);
return true;
}
else
{
    var sig=ds_list_find_index(global.signal_list,string(argument0.object_index)+"."+string(argument1));
    if sig>-1
    {
    ds_list_delete(global.signal_list,sig);
    return true;
    }
}
return false;

