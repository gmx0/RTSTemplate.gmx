if game_ispaused() || global.rts_match_result!="" exit;
if unit_command_active {
 if !rts_ability_has("move") || unit_blocks unit_command_active=false;
 else rts_nav_move();
}
rts_combat_step();
if ds_list_size(unit_production)>0 && rts_ability_has("produce") {
 var job,child,px,py,spawnx,spawny;
 job=unit_production[| 0]; job[| 2]=max(0,job[| 2]-1);
 if job[| 2]<=0 {
  spawnx=-1; spawny=-1;
  for(var ix=-1;ix<=1;ix+=1) for(var iy=-1;iy<=1;iy+=1) {
   px=floor(x/32)+ix; py=floor(y/32)+iy;
   if spawnx<0 && rts_nav_free(px,py) {spawnx=px*32+16; spawny=py*32+16;}
  }
  if spawnx>=0 {
   if job[| 5]!="" child=rts_unit_build_def(spawnx,spawny,job[| 5],unit_owner);
   else child=unit_build(spawnx,spawny,job[| 0],job[| 1],unit_owner);
   if instance_exists(child) {ds_list_delete(unit_production,0); ds_list_destroy(job);}
  }
 }
}
