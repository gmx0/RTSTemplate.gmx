//https://www.youtube.com/watch?v=NXJgt0lmCqM

global.fow_precision=argument0; //precision 1 is default, lower than 1 is less precise, higher than 1 is more precise
global.fow_=surface_create(room_width*global.fow_precision,room_height*global.fow_precision);

surface_set_target(global.fow_);
draw_clear(c_black);
draw_set_color(c_black);
draw_rectangle(0,0,room_width*global.fow_precision,room_height*global.fow_precision,false);
surface_reset_target();
