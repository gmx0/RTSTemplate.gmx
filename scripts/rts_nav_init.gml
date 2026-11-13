// Pure-data land navigation. Service owns every cached grid.
global.rts_cell=32;
global.rts_cols=ceil(room_width/32);
global.rts_rows=ceil(room_height/32);
global.rts_terrain=ds_grid_create(global.rts_cols,global.rts_rows);
global.rts_blockers=ds_grid_create(global.rts_cols,global.rts_rows);
ds_grid_clear(global.rts_terrain,0);
ds_grid_clear(global.rts_blockers,0);
global.rts_fields=ds_map_create();
