//add instance to a targeting list
//arg0 = name of targeting list (might change to just the object index)
//arg1 = instance id
//returns position if already in the targeting list
var _ins,_targ,_pos;
_targ=ds_map_find_value(global._target,argument0);
_ins=argument1;
_pos=ds_list_find_index(_targ,argument1);

    if _pos=-1
    {
    ds_list_add(_targ,argument1);
    return ds_list_size(_targ)-1;
    }
    
return _pos;

