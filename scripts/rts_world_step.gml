if keyboard_check_pressed(vk_space) global.pause=!global.pause;
if keyboard_check_pressed(vk_f2) {global.rts_original=!global.rts_original; room_restart(); exit;}
if keyboard_check_pressed(vk_f8) rts_priority_selftest();
if instance_exists(global.rts_viewer) {
 var actor; actor=global.rts_viewer;
 with(obj_unit) if unit_owner==actor && unit_select {
  if keyboard_check_pressed(ord("T")) actor.player_command_result=rts_command(actor,id,"produce",0,0,noone,0);
  if keyboard_check_pressed(ord("C")) actor.player_command_result=rts_command(actor,id,"cancel",0,0,noone,0);
  if keyboard_check_pressed(ord("X")) actor.player_command_result=rts_command(actor,id,"stop",0,0,noone,-1);
 }
}
if game_ispaused() || global.rts_match_result!="" exit;
global.rts_elapsed+=1;
// A finite contested resource point: nearby mobile units extract 5 credits/sec.
if global.rts_elapsed mod room_speed==0 && global.rts_resource_stock>0 {
 var claimant,contested;
 claimant=noone; contested=false;
 with(obj_unit) if instance_exists(unit_owner) && rts_ability_has("move") && point_distance(x,y,global.rts_resource_x,global.rts_resource_y)<=80 {
  if claimant==noone claimant=unit_owner;
  else if claimant!=unit_owner contested=true;
 }
 if instance_exists(claimant) && !contested {
  var amount; amount=min(5,global.rts_resource_stock);
  claimant.player_resources+=amount; global.rts_resource_stock-=amount;
 }
}
