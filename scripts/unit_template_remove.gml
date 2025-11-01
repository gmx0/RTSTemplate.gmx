//player unit,unit template, perform destroy
//removes templates
//unfortunately cannot remove variables?
var un;
un=argument0;
var pos;
//un.template_obj=argument1; //template object is the main template, adding templates are sub templates
 with un
 {
 pos=templates_remove(argument1,argument2);
 }
return pos;
