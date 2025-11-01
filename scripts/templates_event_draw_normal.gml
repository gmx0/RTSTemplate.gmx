/*
 if object_exists(template_obj)
 {
 event_perform_object(template_obj,ev_draw,0);
 }
 */

var i;
for (i=0;i<ds_list_size(template_list);i+=1;)
{
 _obj=ds_list_find_value(template_list,i);
 if object_exists(_obj)
 event_perform_object(_obj,ev_draw,0);
}
