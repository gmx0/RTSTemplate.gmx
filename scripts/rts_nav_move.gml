// Unit context. Route through tile centers, then the exact destination.
var field,cx,cy,best,nextx,nexty,i,nx,ny,px,py,amount,angle;
field=rts_nav_request(unit_command_x,unit_command_y);
if field<0 {unit_command_result="blocked"; unit_command_active=false; return false;}
cx=floor(x/32); cy=floor(y/32);
if !rts_nav_free(cx,cy) {unit_command_result="blocked"; unit_command_active=false; return false;}
best=field[# cx,cy]; nextx=cx; nexty=cy;
if best<0 {unit_command_result="unreachable"; unit_command_active=false; return false;}
for(i=0;i<4;i+=1) {
 nx=cx; ny=cy;
 switch(i) {case 0: nx-=1; break; case 1: nx+=1; break; case 2: ny-=1; break; case 3: ny+=1; break;}
 if rts_nav_free(nx,ny) {
  if field[# nx,ny]>=0 && field[# nx,ny]<best {best=field[# nx,ny]; nextx=nx; nexty=ny;}
 }
}
px=nextx*32+16; py=nexty*32+16;
// Center in the current cell before turning; never cut a blocked corner.
if nextx!=cx && abs(y-(cy*32+16))>0.1 {px=cx*32+16; py=cy*32+16;}
if nexty!=cy && abs(x-(cx*32+16))>0.1 {px=cx*32+16; py=cy*32+16;}
if field[# cx,cy]==0 {px=unit_command_x; py=unit_command_y;}
amount=min(point_distance(x,y,px,py),unit_move_speed);
angle=point_direction(x,y,px,py);
x+=lengthdir_x(amount,angle); y+=lengthdir_y(amount,angle);
if point_distance(x,y,unit_command_x,unit_command_y)<0.1 {
 unit_command_active=false; unit_command_result="completed";
}
return true;
