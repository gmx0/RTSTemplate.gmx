///mod_image_get(identifier)
var _id = string(argument0);

if ds_map_exists(global.mod_images, _id)
{
    return global.mod_images[? _id];
}

return global.mod_image_fallback;
