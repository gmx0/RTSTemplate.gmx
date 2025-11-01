if ds_list_find_index(template_list,argument0)<=-1
{
ds_list_add(template_list,argument0);
if argument1
event_perform_object(argument0,ev_create,0);
//why perform again or not?
//because of previous variables, remember, these can be removed and added at any time
return true;
}
return false;
