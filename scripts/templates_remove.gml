var pos;
 pos=ds_list_find_index(template_list,argument0);
  if !(pos<=-1)
  {
  ds_list_delete(template_list,pos);
   if argument1
   event_perform_object(argument0,ev_destroy,0);
  }
 
return (pos<=-1);
