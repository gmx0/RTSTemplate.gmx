//argument0 = view
if surface_exists(global.fow_)
draw_surface_part_ext(global.fow_,view_xview[argument0]*global.fow_precision,view_yview[argument0]*global.fow_precision,view_wview[argument0]*global.fow_precision,view_hview[argument0]*global.fow_precision,view_xview[argument0],view_yview[argument0],1/global.fow_precision,1/global.fow_precision,c_black,1);
