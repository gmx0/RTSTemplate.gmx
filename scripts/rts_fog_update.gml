// Per-player grid: 0 shroud, 1 explored, 2 currently visible.
var player,grid,cx,cy,radius,tx,ty;
player=argument0;
if !instance_exists(player) return false;
grid=player.player_fog;
for(ty=0;ty<global.rts_rows;ty+=1) for(tx=0;tx<global.rts_cols;tx+=1) {
 if grid[# tx,ty]==2 grid[# tx,ty]=1;
}
with(obj_unit) if unit_owner==player {
 cx=floor(x/32); cy=floor(y/32); radius=ceil(unit_vision/32);
 for(ty=max(0,cy-radius);ty<=min(global.rts_rows-1,cy+radius);ty+=1)
 for(tx=max(0,cx-radius);tx<=min(global.rts_cols-1,cx+radius);tx+=1) {
  if point_distance(x,y,tx*32+16,ty*32+16)<=unit_vision grid[# tx,ty]=2;
 }
}
return true;
