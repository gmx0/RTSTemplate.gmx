// Player context. Admission owns rules; policy only chooses intent.
if global.rts_elapsed mod 60!=0 exit;
var actor,goalx,goaly;
actor=id; goalx=global.rts_resource_x; goaly=global.rts_resource_y;
// After scouting the resource point, pressure the opposing corner.
if global.rts_elapsed>room_speed*30 {goalx=144; goaly=144;}
with(obj_unit) if unit_owner==actor {
 if rts_ability_has("produce") && ds_list_size(unit_production)<2 rts_command(actor,id,"produce",0,0,noone,0);
 if rts_ability_has("move") && !instance_exists(unit_command_target) rts_command(actor,id,"move",goalx,goaly,noone,-1);
}
