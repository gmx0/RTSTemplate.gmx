//arg0 = tile layer for terrain

global.terrain_layer=argument0;

//To do:
//there are terrain categories
//each terrain category has a set of backgrounds/tileset
//for example, a Grass Terrain will have all the grass backgrounds/tilesets

global.terrain_map=ds_map_create();
//ds_map_add(global.terrain_map,back_,"Terrain Type");

global.terrain_list=ds_list_create();
