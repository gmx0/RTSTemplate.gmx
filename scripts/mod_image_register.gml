///mod_image_register(group, identifier, fname, subimg, xorig, yorig)
var _group = string(argument0);
var _id = string(argument1);
var _fname = string(argument2);

if !file_exists(_fname)
{
    show_debug_message("Mod image missing: " + _id + " -> " + _fname);
    return false;
}

if image_stream_add(_group, _id, _fname, argument3, argument4, argument5)
{
    mod_map_set(global.mod_image_groups, _id, _group);
    return true;
}

return false;
