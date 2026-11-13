// Explicit content whitelist: mod files cannot execute scripts or arbitrary objects.
switch(argument0) {
 case "visual": return obj_template_visual_image;
 case "health": return obj_template_health;
 case "bipedal": return obj_template_bipedal;
 case "weapon": return obj_template_weapon;
 case "constructor": return obj_template_constructor;
 case "structural": return obj_template_structural;
}
return noone;
