// Room end: destroy entities before the shared registries they reference.
if global.rts_shutdown exit;
global.rts_shutdown=true;
with(obj_unit) instance_destroy();
with(obj_player) instance_destroy();
rts_nav_clear(); ds_map_destroy(global.rts_fields);
ds_grid_destroy(global.rts_terrain); ds_grid_destroy(global.rts_blockers);
var key,definition;
key=ds_map_find_first(global.rts_definitions);
repeat ds_map_size(global.rts_definitions) {
 definition=global.rts_definitions[? key];
 ds_list_destroy(definition[? "templates"]); ds_map_destroy(definition);
 key=ds_map_find_next(global.rts_definitions,key);
}
ds_map_destroy(global.rts_definitions);
if variable_global_exists("_target") {
 if ds_exists(global._target,ds_type_map) targeting_map_end();
}
if ds_exists(global.mod_images,ds_type_map) ds_map_destroy(global.mod_images);
if ds_exists(global.mod_image_groups,ds_type_map) ds_map_destroy(global.mod_image_groups);
if ds_exists(global.signal_list,ds_type_list) ds_list_destroy(global.signal_list);
// Group deletion releases streamed sprite/texture resources via the image framework.
image_group_destroy("main");
ds_map_destroy(global.m_ex_image);
