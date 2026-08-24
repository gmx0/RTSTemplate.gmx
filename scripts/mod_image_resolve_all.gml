///mod_image_resolve_all()
var _count = 0;

if ds_map_size(global.mod_image_groups) <= 0
{
    return 0;
}

var _id = ds_map_find_first(global.mod_image_groups);
while !is_undefined(_id)
{
    var _group = global.mod_image_groups[? _id];
    var _image = image_group_find_image(_group, _id);
    mod_map_set(global.mod_images, _id, _image);
    _count += 1;
    _id = ds_map_find_next(global.mod_image_groups, _id);
}

return _count;
