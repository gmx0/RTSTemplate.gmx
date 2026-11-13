var viewer,tx,ty,grid,sx,sy,left,top,state;
viewer=global.rts_viewer;
if !instance_exists(viewer) {draw_text(12,12,global.rts_match_result); exit;}
draw_set_alpha(0.9); draw_set_color(c_black); draw_rectangle(0,0,1024,78,false);
draw_set_alpha(1); draw_set_color(c_white);
draw_text(12,8,"Credits: "+string(viewer.player_resources)+"   "+viewer.player_command_result+"   "+global.rts_match_result);
draw_text(12,28,"Click/drag: select | Right click: move/attack | T: train | C: cancel first | X: stop");
draw_text(12,48,"Space: pause | F2: switch skirmish/one-unit sandbox | F8: smoke test | Destroy the enemy base");
if global.pause draw_text(840,8,"PAUSED");
// Minimap shares the exact disclosure predicate with world rendering/targeting.
left=812; top=600; sx=192/room_width; sy=144/room_height;
draw_set_color(c_black); draw_rectangle(left-2,top-2,left+194,top+146,false);
grid=viewer.player_fog;
for(ty=0;ty<global.rts_rows;ty+=1) for(tx=0;tx<global.rts_cols;tx+=1) {
 state=grid[# tx,ty];
 if state==2 draw_set_color(make_color_rgb(75,85,75));
 else if state==1 draw_set_color(make_color_rgb(30,35,30)); else draw_set_color(c_black);
 if state!=0 && global.rts_terrain[# tx,ty]!=0 draw_set_color(c_gray);
 draw_rectangle(left+tx*32*sx,top+ty*32*sy,left+(tx+1)*32*sx,top+(ty+1)*32*sy,false);
}
with(obj_unit) if rts_visible(viewer,id) {
 if instance_exists(unit_owner) draw_set_color(unit_owner.player_color); else draw_set_color(c_gray);
 draw_rectangle(left+x*sx-2,top+y*sy-2,left+x*sx+2,top+y*sy+2,false);
}
draw_set_color(c_white);
var line; line=0;
with(obj_unit) if unit_owner==viewer && unit_select && line<4 {
 draw_text(12,90+line*22,unit_name+" HP "+string(ceil(unit_hp))+"/"+string(unit_hp_max)+" Queue "+string(ds_list_size(unit_production)));
 line+=1;
}
