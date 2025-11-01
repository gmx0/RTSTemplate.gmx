/// collision_cone_list(x1,y1,radius,dir,obj,prec,notme)
//
//  Returns a list data structure populated with the ids of instances 
//  colliding with a given circle, or noone if no instances found.
//
//      x1,y1       center of the collision cone (filled), real
//      radius      radius of the collision cone (filled), real
//      dir         direction of the collision cone, real
//      width       width of the collision cone as an angle, real
//      obj         object to check for collision (or all), real
//      prec        true for precise collision checking, bool
//      notme       true to ignore the calling instance, bool
//
/// GMLscripts.com/license
{
    var x1,y1,radius,dir,width,obj,prec,notme,dsid,i;
    x1 = argument0;
    y1 = argument1;
    radius = argument2;
    dir = argument3;
    width = argument4;
    obj = argument5;
    prec = argument6;
    notme = argument7;
    dsid = ds_list_create();
    with (obj) {
        if (!notme || id != other.id) {
            i = noone;
            if abs(angle_difference(dir,point_direction(x1,y1,x,y)))<(width*0.5)
            i = collision_circle(x1,y1,radius,id,prec,false);
            if (i != noone) 
            ds_list_add(dsid,i);
        }
    }
    if (ds_list_empty(dsid)) {
        ds_list_destroy(dsid);
        dsid = noone;
    }
    return dsid;
}


