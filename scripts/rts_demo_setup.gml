// rm_test creation: controller and targeting must already exist.
if !ds_map_exists(global.rts_definitions,"core.units.infantry") || !ds_map_exists(global.rts_definitions,"core.structures.base") {
 global.rts_match_result="Content load failed: check included INI files";
 show_debug_message(global.rts_match_result); exit;
}
var human,enemy;
human=player_add(obj_player_1,0,obj_unit_1,c_aqua);
human.player_resources=100;
if global.rts_original {
 rts_unit_build_def(528,400,"core.units.infantry",human);
} else {
 enemy=player_add(obj_player,1,obj_unit,c_orange); enemy.player_resources=100;
 enemy.player_ai_policy=rts_skirmish_policy;
 // Authored wall with a central passage; never use randomized walkability.
 for(var ty=4;ty<20;ty+=1) if ty<10 || ty>13 global.rts_terrain[# 15,ty]=1;
 rts_unit_build_def(112,112,"core.structures.base",human);
 rts_unit_build_def(880,624,"core.structures.base",enemy);
 rts_unit_build_def(144,144,"core.units.infantry",human);
 rts_unit_build_def(848,592,"core.units.infantry",enemy);
}
with(obj_player) rts_fog_update(id);
