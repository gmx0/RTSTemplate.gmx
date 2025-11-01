//player unit,unit template
//adds templates
var un;
un=argument0;
//un.template_obj=argument1; //template object is the main template, adding templates are sub templates
 with un
 {
 templates_add(argument1,true);
 }
return un;
