//check if instance is in targeting list
//arg0 = name of targeting map
//arg1 = instance id
//returns position if already in the targeting list

var _ins,_targ,_pos;
_targ=ds_map_find_value(global._target,argument0);
_ins=argument1;
_pos=ds_list_find_index(_targ,argument1);

    if _pos=-1
    return false;
    
return true;
