// Unit context: declare or change an ability.
if ds_map_exists(unit_abilities,argument0) ds_map_replace(unit_abilities,argument0,argument1);
else ds_map_add(unit_abilities,argument0,argument1);
