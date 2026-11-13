rts_target_forget(id);
if unit_blocks && ds_exists(global.rts_blockers,ds_type_grid) rts_nav_block(x,y,-1);
// Destroying a producer refunds unfinished work to its original payers.
while ds_list_size(unit_production)>0 rts_production_cancel(unit_owner,0);
while ds_list_size(unit_products)>0 {
 ds_list_destroy(unit_products[| 0]); ds_list_delete(unit_products,0);
}
ds_list_destroy(unit_production); ds_list_destroy(unit_products);
ds_map_destroy(unit_abilities);
ds_list_destroy(unit_status); ds_list_destroy(template_list);
