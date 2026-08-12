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
 {
 _evuser=ev_user0;
 switch argument0
 {
 case 0: _evuser=ev_user0; break;
 case 1: _evuser=ev_user1; break; 
 case 2: _evuser=ev_user2; break; 
 case 3: _evuser=ev_user3; break; 
 case 4: _evuser=ev_user4; break;
 case 5: _evuser=ev_user5; break; 
 case 6: _evuser=ev_user6; break; 
 case 7: _evuser=ev_user7; break; 
 case 8: _evuser=ev_user8; break; 
 case 9: _evuser=ev_user9; break; 
 case 10: _evuser=ev_user10; break; 
 case 11: _evuser=ev_user11; break; 
 case 12: _evuser=ev_user12; break; 
 }
 event_perform_object(_obj,ev_other,_evuser);
 }
}
