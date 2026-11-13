// Refund the original payer once, then release the job.
var index, job, payer;
index=argument1;
if index!=floor(index) || index<0 || index>=ds_list_size(unit_production) return "invalid_job";
job=unit_production[| index]; payer=job[| 4];
if instance_exists(payer) payer.player_resources+=job[| 3];
ds_list_delete(unit_production,index); ds_list_destroy(job);
return "accepted";
