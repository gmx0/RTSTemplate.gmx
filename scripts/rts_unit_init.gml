// Instance-owned state; templates declare capabilities after this call.
unit_owner=noone;
unit_side=-1;
unit_abilities=ds_map_create();
unit_products=ds_list_create();
unit_production=ds_list_create();
unit_queue_limit=8;
unit_command_result="idle";
unit_vision=160;
unit_move_speed=2;
unit_command_active=false;

unit_def_id="";
unit_name="Unit";
unit_image_id="";
unit_hp=10; unit_hp_max=10;
unit_damage=0; unit_range=96; unit_fire_delay=30; unit_fire_timer=0;
unit_blocks=false; unit_objective=false;
sprite_index=spr_unit; image_speed=0;
