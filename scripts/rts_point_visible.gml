var viewer,tx,ty;
viewer=argument0; tx=floor(argument1/32); ty=floor(argument2/32);
if !instance_exists(viewer) return false;
if tx<0 || ty<0 || tx>=global.rts_cols || ty>=global.rts_rows return false;
return viewer.player_fog[# tx,ty]==2;
