/*
if object_exists(template_obj)
{
event_perform_object(template_obj,ev_step,ev_step_normal);
}
*/

//template object already included in the list
var i;
for (i=0;i<ds_list_size(template_list);i+=1;)
{
 _obj=ds_list_find_value(template_list,i);
 if object_exists(_obj)
 event_perform_object(_obj,ev_step,ev_step_normal);
}
