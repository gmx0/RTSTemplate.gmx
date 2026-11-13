rts_nav_init();
global.rts_definitions=ds_map_create();
global.rts_match_result=""; global.rts_elapsed=0;
global.rts_shutdown=false;
global.rts_resource_x=496; global.rts_resource_y=368;
if !variable_global_exists("rts_original") global.rts_original=false;
// Shipped defaults are included files. External mod files override individually.
var filename;
filename="mods/core/units/infantry.ini";
if !file_exists(filename) filename="core_infantry.ini";
if !rts_definition_load(filename) {
 if filename!="core_infantry.ini" rts_definition_load("core_infantry.ini");
}
filename="mods/core/units/base.ini";
if !file_exists(filename) filename="core_base.ini";
if !rts_definition_load(filename) {
 if filename!="core_base.ini" rts_definition_load("core_base.ini");
}
global.rts_resource_stock=1000;
