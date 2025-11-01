//fow_clean(x,y,radius)
var xx,yy;
surface_set_target(global.fow_); 
draw_set_blend_mode(bm_subtract);
draw_primitive_begin(pr_trianglefan);
draw_vertex_color(argument0*global.fow_precision,argument1*global.fow_precision,c_white, 1);
for(i=0; i<=360; i+=10)
{
xx = lengthdir_x(argument2*global.fow_precision, i);
yy = lengthdir_y(argument2*global.fow_precision, i);
draw_vertex_color(argument0*global.fow_precision+xx,argument1*global.fow_precision+yy,c_black,0);
}
draw_primitive_end(); 
draw_set_blend_mode(bm_normal);
surface_reset_target();
