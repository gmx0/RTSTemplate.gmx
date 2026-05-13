///signal_receive_once(signal name)
// 
//if signal_receive_once(SIGNAL_NAME)
//{
//Do stuff 
//then removes the signal for all
//}
//
//PUT IN End Step EVENT

signal_exists();
var sig=ds_list_find_index(global.signal_list,string(argument0));
if sig>-1
{
ds_list_delete(global.signal_list,sig);
return true;
}
else
return false;

