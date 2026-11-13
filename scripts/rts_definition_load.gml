// Load a single INI definition atomically. Registry owns its map and template list.
var filename,key,definition,list,count,i,trait,names;
filename=argument0;
if !file_exists(filename) {show_debug_message("Missing definition: "+filename); return false;}
ini_open(filename);
key=ini_read_string("unit","id","");
count=ini_read_real("unit","template_count",0);
if key=="" || count<1 || count>16 || count!=floor(count) {ini_close(); return false;}
definition=ds_map_create(); list=ds_list_create();
for(i=0;i<count;i+=1) {
 trait=rts_template_resolve(ini_read_string("templates",string(i),""));
 if trait==noone || ds_list_find_index(list,trait)>=0 {
  ini_close(); ds_list_destroy(list); ds_map_destroy(definition); return false;
 }
 ds_list_add(list,trait);
}
ds_map_add(definition,"templates",list);
ds_map_add(definition,"id",key);
ds_map_add(definition,"name",ini_read_string("unit","name",key));
ds_map_add(definition,"image",ini_read_string("unit","image",""));
ds_map_add(definition,"hp",max(1,ini_read_real("stats","hp",10)));
ds_map_add(definition,"speed",clamp(ini_read_real("stats","speed",2),0,8));
ds_map_add(definition,"vision",clamp(ini_read_real("stats","vision",160),32,1024));
ds_map_add(definition,"damage",max(0,ini_read_real("stats","damage",0)));
ds_map_add(definition,"range",max(32,ini_read_real("stats","range",96)));
ds_map_add(definition,"cooldown",max(1,ini_read_real("stats","cooldown",30)));
ds_map_add(definition,"cost",max(0,ini_read_real("production","cost",25)));
ds_map_add(definition,"build_steps",max(1,ini_read_real("production","build_steps",90)));
ds_map_add(definition,"product",ini_read_string("production","product",""));
ds_map_add(definition,"objective",ini_read_real("unit","objective",0)!=0);
ini_close();
if ds_map_exists(global.rts_definitions,key) {
 ds_list_destroy(list); ds_map_destroy(definition); return false;
}
ds_map_add(global.rts_definitions,key,definition);
return true;
