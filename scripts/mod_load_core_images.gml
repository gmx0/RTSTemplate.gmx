///mod_load_core_images(group)
var _group = string(argument0);

mod_image_register(_group, "core.units.infantry", "mods\\core\\images\\units\\infantry.png", 1, 0.5, 0.5);

if image_stream_is_received(_group)
{
    image_stream_finish(_group);
    mod_image_resolve_all();
}

return true;
