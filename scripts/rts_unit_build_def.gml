// x, y, stable definition ID, explicit owner. Keeps multiple-template composition.
var key,definition,list,un,i,product,pdef;
key=argument2;
if !ds_map_exists(global.rts_definitions,key) return noone;
definition=global.rts_definitions[? key]; list=definition[? "templates"];
if !rts_nav_free(floor(argument0/32),floor(argument1/32)) return noone;
un=instance_create(argument0,argument1,obj_unit);
un.unit_owner=argument3;
if instance_exists(argument3) un.unit_side=argument3.player_side;
with(un) {
 unit_def_id=key; unit_name=definition[? "name"];
 unit_image_id=definition[? "image"];
 for(i=0;i<ds_list_size(list);i+=1) templates_add(list[| i],true);
 unit_hp_max=definition[? "hp"]; unit_hp=unit_hp_max;
 unit_move_speed=definition[? "speed"]; unit_vision=definition[? "vision"];
 unit_damage=definition[? "damage"]; unit_range=definition[? "range"];
 unit_fire_delay=definition[? "cooldown"]; unit_objective=definition[? "objective"];
 sprite_index=spr_unit; image_speed=0;
 product=definition[? "product"];
 if product!="" && ds_map_exists(global.rts_definitions,product) {
  pdef=global.rts_definitions[? product];
  rts_product_add(obj_unit,obj_template,pdef[? "build_steps"],pdef[? "cost"],product);
 }
}
return un;
