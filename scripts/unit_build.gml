//x,y,player unit,unit template
//adds templates
var un;
un=instance_create_z(argument0,argument1,0,argument2);
un.template_obj=argument3;
 with un
 {
 templates_add(template_obj); 
 //^^ why this isn't in the template creation code is because 
 //variables of object_index stay as the main object, not the template object
 }
return un;
