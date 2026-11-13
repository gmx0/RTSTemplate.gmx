var tx,ty;
tx=floor(argument0/32); ty=floor(argument1/32);
if tx<0 || ty<0 || tx>=global.rts_cols || ty>=global.rts_rows return false;
global.rts_blockers[# tx,ty]=max(0,global.rts_blockers[# tx,ty]+argument2);
rts_nav_clear();
return true;
