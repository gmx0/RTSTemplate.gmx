var pos,template;
template=argument0; pos=ds_list_find_index(template_list,template);
if pos<0 return false;
ds_list_delete(template_list,pos);
if template==obj_template_bipedal rts_ability_set("move",false);
if template==obj_template_weapon {rts_ability_set("attack",false); unit_command_target=noone;}
if template==obj_template_constructor rts_ability_set("produce",false);
if template==obj_template_structural && unit_blocks {unit_blocks=false; rts_nav_block(x,y,-1);}
if argument1 event_perform_object(template,ev_destroy,0);
return true;
