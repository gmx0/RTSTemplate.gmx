//arg0 = background/tileset index
//arg1 = string name of terrain, "Grass", "Road", etc.

//ds_map_add(global.terrain_map,back_,"Terrain Type");
ds_map_add(global.terrain_map,argument0,argument1);

if ds_list_find_value(global.terrain_list,argument1)=-1
ds_list_add(global.terrain_list,argument1);
