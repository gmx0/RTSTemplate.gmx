var viewer,grid,tx,ty,state;
viewer=global.rts_viewer;
if !instance_exists(viewer) exit;
grid=viewer.player_fog;
draw_set_color(c_black);
for(ty=0;ty<global.rts_rows;ty+=1) for(tx=0;tx<global.rts_cols;tx+=1) {
 state=grid[# tx,ty];
 if state!=2 {
  if state==0 draw_set_alpha(1); else draw_set_alpha(0.65);
  draw_rectangle(tx*32,ty*32,tx*32+32,ty*32+32,false);
 }
}
draw_set_alpha(1); draw_set_color(c_white);
