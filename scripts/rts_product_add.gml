// Unit context: unit object, template object, duration in steps, cost.
// Catalog entries are owned lists. Templates should declare each product once.
var row, i, definition;
definition="";
if argument_count>4 definition=argument4;
for(i=0;i<ds_list_size(unit_products);i+=1) {
 row=unit_products[| i];
 if row[| 0]==argument0 && row[| 1]==argument1 && row[| 4]==definition return i;
}
row=ds_list_create();
ds_list_add(row,argument0,argument1,max(1,argument2),max(0,argument3),definition);
ds_list_add(unit_products,row);
return ds_list_size(unit_products)-1;
