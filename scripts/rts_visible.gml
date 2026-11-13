var viewer,target;
viewer=argument0; target=argument1;
if !instance_exists(viewer) || !instance_exists(target) return false;
if target.unit_owner==viewer return true;
return rts_point_visible(viewer,target.x,target.y);
