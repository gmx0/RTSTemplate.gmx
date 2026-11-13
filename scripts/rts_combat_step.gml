// Unit context: automatic acquisition and direct-hit weapon, gated by shared fog.
if unit_fire_timer>0 unit_fire_timer-=1;
if !rts_ability_has("attack") || !instance_exists(unit_owner) exit;
var target,best,scan,damage,tx,ty,range_to;
target=unit_command_target;
if instance_exists(target) {
 if target.unit_owner==unit_owner || !rts_visible(unit_owner,target) target=noone;
}
if !instance_exists(target) {
 target=noone; best=unit_range;
 with(obj_unit) if unit_owner!=other.unit_owner && unit_owner!=noone {
  scan=point_distance(x,y,other.x,other.y);
  if scan<=best && rts_visible(other.unit_owner,id) {target=id; best=scan;}
 }
}
unit_command_target=target;
if !instance_exists(target) exit;
range_to=point_distance(x,y,target.x,target.y);
if range_to<=unit_range {
 if unit_fire_timer<=0 {
  unit_fire_timer=unit_fire_delay; damage=unit_damage;
  with(target) {unit_hp-=damage; if unit_hp<=0 instance_destroy();}
 }
} else if rts_ability_has("move") && !unit_command_active {
 // Approach an adjacent free cell rather than the blocked structure center.
 best=1000000; tx=-1; ty=-1;
 for(var ix=-1;ix<=1;ix+=1) for(var iy=-1;iy<=1;iy+=1) {
  var px,py,dist;
  px=floor(target.x/32)+ix; py=floor(target.y/32)+iy;
  if rts_nav_free(px,py) {
   dist=point_distance(x,y,px*32+16,py*32+16);
   if dist<best {best=dist; tx=px*32+16; ty=py*32+16;}
  }
 }
 if tx>=0 {unit_command_x=tx; unit_command_y=ty; unit_command_active=true;}
}
