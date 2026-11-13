# RTSTemplate project state

Updated for the Markdown incorporation pass. This describes the current GameMaker implementation; the old snapshot at baseline commit `d6aa81f` predates the runtime integration. GodotPort has its own implementation and validation records.

## Entry points and architecture

`RTSTemplate.project.gmx` is the GameMaker Studio 1.4 manifest. `rm_test` creates `obj_control`, creates the category registry, then calls `rts_demo_setup`. It starts a two-player skirmish; F2 switches to the original single-infantry scenario. `rm_menu` Start enters rm_test. The network demonstration room remains separate.

`obj_unit` retains `template_list`: a list of GameMaker objects whose Create, Step and Draw events execute in the unit context. Content definitions select multiple traits. `unit_build` preserves the object/template API, initializes its primary template immediately and accepts an optional explicit owner. `rts_unit_build_def` builds using a stable definition ID and explicit player instance. Player ownership is separate from unit object type; selection scans all obj_unit descendants and filters by owner.

## Data-driven content

Included files `datafiles/core_infantry.ini` and `datafiles/core_base.ini` contain stable IDs, display names, image IDs, trait lists, stats and production data. They are registered as exported included files. The loader prefers external `mods/core/units/infantry.ini` / `base.ini` when present; invalid external definitions fall back to packaged defaults. The missing legacy test_mod.txt manifest entry was removed.

`rts_template_resolve` whitelists health, visual, bipedal, weapon, constructor and structural. Definitions are loaded into owned maps and lists; duplicate IDs/traits and unknown traits are rejected. No arbitrary GML code executes from mod files. Custom image registration still uses the existing external-image system. Missing infantry art falls back to spr_unit and simple owner-colored geometry.

## Commands and abilities

`rts_command` is the common admission API for human and AI intent: move, stop, attack, produce and cancel. It validates ownership, capability, coordinates, reachability, target type/visibility, costs and queue limits as applicable. Result strings are returned and recorded on the unit; player input also keeps a result for the HUD. Orders can be changed while paused, but simulation waits for resume. Match-end commands are rejected.

Bipedal, weapon and constructor declare move, attack and produce respectively. Removing these supported provider templates revokes the corresponding capability even if the caller suppresses template Destroy execution. Structural attachment/removal updates navigation occupancy; structural units cannot receive movement commands. The registry is an extension point, not a generic dependency solver for arbitrary mod traits.

## Navigation

`rts_nav_*` owns a 32-pixel terrain grid, counted blocker grid and a bounded cache of BFS integration fields shared by target tile. There are no obj_node instances in rm_test. Buildings invalidate the cache when attached, removed or destroyed. Movement follows tile centers without cutting blocked corners and ends at the requested point. Admission rejects blocked and unreachable destinations. The old obj_flowfield scripts remain as references for other demonstration rooms.

Current scope is a uniform-cost land layer. There is no formation system, local unit separation, footprint larger than one blocker cell, weighted terrain, or air/naval layer in the new GameMaker service.

## Production, economy and combat

Constructors declare products; queues snapshot the object/template or stable definition ID, duration, cost and original payer. Admission charges once. Completion creates an owned unit on a free neighboring navigation cell; blocked exits retain the completed job until space opens. Cancellation and producer destruction refund unfinished work to the original payer. Removing the production ability suspends its queue. Unit/catalog/job data is released explicitly.

The demonstration headquarters trains infantry. A finite central resource point gives 5 credits/second to one nearby owner; opposing mobile units contest it. No worker harvesting trip, construction placement, technology tree or generalized multi-resource economy is implemented.

Weapons acquire currently visible opponents in range, use cooldowns, apply direct-hit damage and destroy dead units. Explicit attacks on visible opponents can pursue through navigation. This is a basic combat slice: no projectiles, armor, line-of-fire terrain blocking or combat balance claim. Eliminating the opponent headquarters wins; losing yours loses.

## Visibility and presentation

Each player owns one fog grid: shroud, explored, visible. End Step refreshes sight from owned units. `rts_point_visible` and `rts_visible` serve world rendering, selection, attack admission, automatic acquisition and minimap markers. Terrain remains dim after exploration while enemy units disappear outside current sight. The old room-sized surface helpers remain available but obj_fow now draws the grid-based layer in rm_test. Radar, cloak detection and terrain-occluded vision are future work.

The HUD exposes resources, order results, selection/queue details, controls and match outcome. Minimap right-click translates into the same order path as world input. Camera panning is unnecessary for this room-sized demonstration.

## Ownership and cleanup

- Unit: template/status lists, abilities map, product catalog and queued jobs.
- Player: selection list and fog grid.
- World: definition maps/lists, terrain/blocker grids and cached navigation fields.
- Category map: category lists registered with ds_map_add_list; map destruction releases flagged lists.
- Image framework: group/stream resources and its registry; world teardown releases the main group.

Unit destruction removes category and selection references and releases a structure blocker. Controller room-end cleanup destroys units before players and services. A guard makes explicit controller destruction after room-end cleanup harmless. The signal list and mod registries are released there too. Other old prototype rooms/systems may still require their own lifecycle audits.

## Networking and remaining work

SimpleNetwork transport remains present. GameMaker does not yet replicate authoritative RTS commands, spawns or snapshots; no multiplayer or save/replay equivalence is claimed. GodotPort documents separate ENet, save and gameplay implementations that can inform future work.

Next priorities: compile and exercise the new slice in GameMaker, broaden runtime assertions after any failures, then improve separation/spawn placement, construction/economy and template dependencies before RTS networking. See GAMEMAKER_VALIDATION.md for the exact verification boundary.
