var key;
key=ds_map_find_first(global.rts_fields);
repeat ds_map_size(global.rts_fields) {
 ds_grid_destroy(global.rts_fields[? key]);
 key=ds_map_find_next(global.rts_fields,key);
}
ds_map_clear(global.rts_fields);
