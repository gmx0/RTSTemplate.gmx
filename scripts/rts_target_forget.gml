// Remove a destroyed unit from every category and player selection list.
var target,key,list,pos;
target=argument0;
if variable_global_exists("_target") {
 if ds_exists(global._target,ds_type_map) {
  key=ds_map_find_first(global._target);
  repeat ds_map_size(global._target) {
   list=global._target[? key]; pos=ds_list_find_index(list,target);
   while pos>=0 {ds_list_delete(list,pos); pos=ds_list_find_index(list,target);}
   key=ds_map_find_next(global._target,key);
  }
 }
}
with(obj_player) {
 pos=ds_list_find_index(player_select,target);
 while pos>=0 {ds_list_delete(player_select,pos); pos=ds_list_find_index(player_select,target);}
}
