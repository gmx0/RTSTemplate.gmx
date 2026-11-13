//x,y,player unit,unit template
//adds templates
var un;
un=instance_create_z(argument0,argument1,0,argument2);
un.template_obj=argument3;
// Optional explicit owner; legacy callers resolve by registered player unit object.
var owner, i;
owner=noone;
if argument_count>4 owner=argument4;
else for(i=0;i<array_length_1d(global.player);i+=1) {
 var candidate;
 candidate=global.player[i];
 if instance_exists(candidate) {
  if argument2==candidate.player_unit || object_is_ancestor(argument2,candidate.player_unit) {owner=candidate; break;}
 }
}
un.unit_owner=owner;
if instance_exists(owner) un.unit_side=owner.player_side;
 with un
 {
 templates_add(template_obj,true);
 sprite_index=object_get_sprite(template_obj);
 //^^ why this isn't in the template creation code is because
 //variables of object_index stay as the main object, not the template object
 }
return un;
