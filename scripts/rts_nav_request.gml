// Shared BFS integration field keyed by exact destination tile.
var tx,ty,key,field,queue,tile,cx,cy,i,nx,ny;
tx=floor(argument0/32); ty=floor(argument1/32);
if !rts_nav_free(tx,ty) return -1;
key=string(tx)+":"+string(ty);
if ds_map_exists(global.rts_fields,key) return global.rts_fields[? key];
if ds_map_size(global.rts_fields)>=64 rts_nav_clear();
field=ds_grid_create(global.rts_cols,global.rts_rows);
ds_grid_clear(field,-1);
field[# tx,ty]=0;
queue=ds_queue_create(); ds_queue_enqueue(queue,ty*global.rts_cols+tx);
while !ds_queue_empty(queue) {
 tile=ds_queue_dequeue(queue); cx=tile mod global.rts_cols; cy=floor(tile/global.rts_cols);
 for(i=0;i<4;i+=1) {
  nx=cx; ny=cy;
  switch(i) {case 0: nx-=1; break; case 1: nx+=1; break; case 2: ny-=1; break; case 3: ny+=1; break;}
  if rts_nav_free(nx,ny) {
   if field[# nx,ny]<0 {
    field[# nx,ny]=field[# cx,cy]+1;
    ds_queue_enqueue(queue,ny*global.rts_cols+nx);
   }
  }
 }
}
ds_queue_destroy(queue); ds_map_add(global.rts_fields,key,field);
return field;
