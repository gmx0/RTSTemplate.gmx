// Tile coordinates. Counts allow overlapping independent blockers.
var tx,ty;
tx=argument0; ty=argument1;
if tx<0 || ty<0 || tx>=global.rts_cols || ty>=global.rts_rows return false;
return global.rts_terrain[# tx,ty]==0 && global.rts_blockers[# tx,ty]==0;
