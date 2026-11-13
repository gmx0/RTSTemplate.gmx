// Draw terrain and the resource marker before units; fog covers unseen terrain.
var tx,ty;
draw_set_color(make_color_rgb(65,72,68));
for(ty=0;ty<global.rts_rows;ty+=1) for(tx=0;tx<global.rts_cols;tx+=1)
 if global.rts_terrain[# tx,ty]!=0 draw_rectangle(tx*32,ty*32,tx*32+31,ty*32+31,false);
if global.rts_resource_stock>0 {
 draw_set_color(c_fuchsia);
 draw_triangle(global.rts_resource_x,global.rts_resource_y-14,global.rts_resource_x-12,global.rts_resource_y+10,global.rts_resource_x+12,global.rts_resource_y+10,false);
}
draw_set_color(c_white);
