// Unit context. Payer and declared catalog index. Charge exactly once.
var payer, index, product, job;
payer=argument0; index=argument1;
if index!=floor(index) || index<0 || index>=ds_list_size(unit_products) return "invalid_product";
if ds_list_size(unit_production)>=unit_queue_limit return "queue_full";
product=unit_products[| index];
if !object_exists(product[| 0]) || !object_exists(product[| 1]) return "invalid_product";
if payer.player_resources<product[| 3] return "insufficient_resources";
job=ds_list_create();
ds_list_add(job,product[| 0],product[| 1],product[| 2],product[| 3],payer,product[| 4]);
payer.player_resources-=product[| 3];
ds_list_add(unit_production,job);
return "accepted";
