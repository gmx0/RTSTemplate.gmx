//remove instance to a targeting list
//usually done at death, but can be done for stealth

//arg0 = name of targeting map
//arg1 = instance id
var _ins,_targ,_pos;
_targ=ds_map_find_value(global._target,argument0);
_ins=argument1;
_pos=ds_list_find_index(_targ,argument1);
if _pos=-1
return false;
ds_list_delete(_targ,_pos);
return true;
