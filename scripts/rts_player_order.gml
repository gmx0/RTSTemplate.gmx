var actor,px,py,target,best,dist;
actor=argument0; px=argument1; py=argument2; target=noone; best=20;
with(obj_unit) if unit_owner!=actor && unit_owner!=noone && rts_visible(actor,id) {
 dist=point_distance(x,y,px,py);
 if dist<best {best=dist; target=id;}
}
with(obj_unit) if unit_owner==actor && unit_select {
 if instance_exists(target) actor.player_command_result=rts_command(actor,id,"attack",px,py,target,-1);
 else if rts_ability_has("move") actor.player_command_result=rts_command(actor,id,"move",px,py,noone,-1);
}
