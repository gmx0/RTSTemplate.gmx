# Port scope and system mapping

The GM source is a framework prototype, not a finished RTS. `docs/PROJECT_STATE.md` in the original describes combat, economy and integrated pathfinding as future work. The Godot version implements those connections to make the converted systems testable in a playable game.

## Mapping

| Source system | Godot implementation | Functional difference |
| --- | --- | --- |
| obj_control, rts/player/unit init, game_pause | world.gd | Fixed physics delta; host-owned pause |
| obj_entity, obj_unit, unit_build | unit.gd / world.spawn | Nodes with stable integer network IDs |
| templates_add/remove/events/check_preqs | unit.gd / trait.gd / content.gd | Explicit per-unit trait objects, prerequisites and lifecycle |
| obj_player variants, select scripts | world.gd input and command validation | Click/box, additive selection, contextual orders, queues, groups |
| obj_node, obj_flowfield, scr_calculateFlowField, FlowField_move | flow_field.gd | Shared pure-data BFS fields; integrated with commands; no random blocked tiles |
| sb_* and vect_* | steering.gd / Vector2 | Seek, arrive, flee, pursuit, separation, alignment, cohesion, wander and path following helpers; movement uses separation; demo uses wander/cohesion |
| collision_* / line_intersect / point_in_polygon | targeting.gd / Geometry2D / Godot Rect2 and Vector2 APIs | Native geometry replaces generic GML math wrappers |
| targeting_map_* | targeting.gd | Same named categories, plus spatial buckets |
| terrain_* and movement categories | flow_field.gd | Land/water/rock grid with air/naval/amphibious passability |
| fow_* / obj_fow | fog.gd | Explored and currently visible tiles per owner, used for rendering and targeting |
| minimap_* / obj_gui_minimap | minimap.gd | Native Control, live units/fog/camera and click commands |
| obj_gui_* / GUI templates | hud.gd / native Controls | Buttons, cards, checkbox, text entry, anchored layout, notification and menu; native containers replace custom anchor/drag logic |
| image_* / Custom Sprite Framework / mod_image_* | content.gd / Texture2D and ImageTexture | Native resource loading replaces manual texture pages, buffers and async image streams |
| signal_* | signal_bus.gd | Native broadcast signal plus frame poll/consume/recipient API |
| obj_server/client/packet_controller, net_* | network.gd / ENet and RPC | Reliable typed RPC transport; host authority, peer-to-owner assignment and snapshots |
| rm_menu | HUD menu | Skirmish launches directly; menu exposes game modes and networking |
| rm_test | Original rm_test mode | Same single 10-HP infantry starting point, now movable |
| room_test | Host/Join controls in HUD menu | Replaces modal server/client prompts with ENet connection controls |
| obj_drone* | Steering demo | Flocking scout demo using the source steering concepts |

## Templates with runnable behavior

Health, regeneration, armor, shield, movement layer markers, visual image fallback, weapon/projectile damage, veterancy, engineer harvest/repair, resource/supply stock, cost validation, constructor production, timed construction, power plant/user, radar and cloak detector. Structural blocks navigation. Composition prerequisite checks prevent removing traits that another attached trait requires.

`test_infantry`, `test_engineer`, `test_structure` become definitions under `core.*`, rather than behavior attached from hard-coded GML. `core.units.infantry` retains the source's 10 HP. Extra stats, enemy AI and the skirmish are functional defaults, not recovered source balance values.

## Source extension points retained without invented gameplay

Many original templates contain only comments or field initialization. Their IDs remain recognized by the registry and their original events remain in `source_inventory.json`. They do **not** acquire finished gameplay just by being listed:

- attachment/attachment_upgrade/connect: attachment graph and upgrade application are extension points;
- storage_transport/squad: transport loading and squad ownership are extension points;
- disguise/disruptor/detector_disguise/detector_psi: specialized stealth and disruption are extension points;
- hero/interface/interface_strategy/interface_tactics: specialized control schemes are extension points;
- netheral/orbital/turret: targeting/category support exists, with no separate orbital simulation or independently rotating attached turret;
- terraform/sequences/supply_weapon_ammo/warhead: terrain editing, authored sequences, ammo supply logistics and splash warheads are extension points;
- mindcontrol: ownership-change trait event exists, with no player-facing capture ability;
- naval: navigation layer works, but the default map has no ship production unit;
- GUI tree/card/clickmenu: native controls and the build/command cards replace the prototype roles; no bespoke tech-tree editor was present to convert.

Other deliberate limits: no Steam integration (none found in this template), no replay player, no mod hot reload or arbitrary GML execution, no exact source rendering/room-layout recreation. Save/load is offline. Full faction/upgrade data and a generalized multi-resource economy remain future work; the current demonstration uses credits and power.

## First-priority extensions

[RTS priority systems](RTS_PRIORITY_SYSTEMS.md) documents the Godot command-result boundary, capability-derived ability declarations, production cancellation and blocked exits, separated AI policy and gameplay disclosure. Multiple attached templates and shared flowfields remain the runtime architecture.

## Reference tools

- https://github.com/Infiland/GM2Godot — inspected as a reference. Current README targets newer `.yyp` projects, so it was not run against this GM 1.4 `.gmx` project.
- https://github.com/coppolaemilio/gamemaker-godot-dictionary — terminology reference.

No third-party converter source or dependencies are included. Original source and assets are retained as user-project migration material.
