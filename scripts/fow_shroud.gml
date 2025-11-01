surface_set_target(global.fow_);
draw_set_blend_mode(bm_add);
//draw_set_blend_mode(bm_normal);
draw_set_alpha(argument0);
draw_rectangle(0,0,room_width*global.precision,room_height*global.precision,0);
draw_set_alpha(1);
draw_set_blend_mode(bm_normal);
surface_reset_target();
