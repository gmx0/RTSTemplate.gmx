// Shared player/AI admission. Arguments: actor, unit, verb, x, y, target, product.
var actor,un,verb,result,tx,ty,target,field;
actor=argument0; un=argument1; verb=argument2;
if !instance_exists(actor) || !instance_exists(un) return "missing_instance";
if un.object_index!=obj_unit && !object_is_ancestor(un.object_index,obj_unit) return "not_unit";
if un.unit_owner!=actor return "not_owner";
if global.rts_match_result!="" return "match_over";
result="accepted"; tx=argument3; ty=argument4; target=argument5;
with(un) {
 if verb!="move" && verb!="stop" && verb!="attack" && verb!="produce" && verb!="cancel" result="unknown_command";
 else if (verb=="move" && (!rts_ability_has("move") || unit_blocks)) || (verb=="attack" && !rts_ability_has("attack")) || (verb=="produce" && !rts_ability_has("produce")) result="missing_ability";
 else if verb=="produce" result=rts_production_enqueue(actor,argument6);
 else if verb=="cancel" result=rts_production_cancel(actor,argument6);
 else if verb=="attack" {
  if !instance_exists(target) result="missing_target";
  else if target.object_index!=obj_unit && !object_is_ancestor(target.object_index,obj_unit) result="invalid_target";
  else if target.unit_owner==actor || target.unit_owner==noone result="invalid_target";
  else if !rts_visible(actor,target) result="hidden_target";
  else {unit_command_target=target; unit_command_active=false;}
 }
 else if verb=="move" {
  if tx<0 || ty<0 || tx>=room_width || ty>=room_height result="outside_room";
  else {
   field=rts_nav_request(tx,ty);
   if field<0 result="blocked";
   else if field[# floor(x/32),floor(y/32)]<0 result="unreachable";
   else {unit_command_x=tx; unit_command_y=ty; unit_command_target=noone; unit_command_active=true;}
  }
 }
 else {unit_command_target=noone; unit_command_active=false; unit_command_x=x; unit_command_y=y;}
 unit_command_result=result;
}
return result;
