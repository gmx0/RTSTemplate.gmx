///Units detect what terrain they're on and act accordingly
//Should terrain be polygon based or tile based?
//though if using flowfield, can use tiles
//
// tiles in GMS2 can be detected for collisions, plus you can pass through two arguments?? 
// https://www.youtube.com/watch?v=XxL4_a2Ci1s

//
// argument0 = X coordinate to get tile (in pixels, not tiles)
// argument1 = Y coordinate to get tile (in pixels, not tiles)
//
// returns string name of terrain

var t;
t=tile_layer_find(global.terrain_layer,argument0,argument1);
return ds_map_find_value(global.terrain_map,tile_get_background(t)); //returns string name of terrain
