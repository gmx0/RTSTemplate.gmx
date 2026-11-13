// Category lists are registered with ds_map_add_list and owned by the map.
// Destroying the map releases those flagged lists recursively.
ds_map_destroy(global._target);
