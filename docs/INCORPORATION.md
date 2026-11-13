# Markdown incorporation decisions

The six project Markdown files were reviewed against current GameMaker source. Design goals are adopted selectively; Godot implementation results are not treated as GameMaker results.

| Source | Adopted here | Deferred |
| --- | --- | --- |
| GAME_DESIGN.md | Stable content IDs, data-selected template composition, cached flowfields, ownership-based commands, basic economy/combat and player fog | Full factions, upgrades, multiple resource types, authoritative networking, saves/replays |
| PROJECT_STATE.md | Sandbox integration and explicit data-structure ownership; document rewritten to match source | Auditing all legacy GUI/network/steering demonstration lifecycles |
| GAMEMAKER_FIRST_PRIORITY.md | Shared command admission, declared capabilities, production lifecycle, AI policy separation and disclosure | General-purpose template dependency graph |
| GodotPort/docs/PORTING.md | Service boundaries and navigation/fog/production concepts translated into GML | Godot APIs and extension-only gameplay placeholders |
| GodotPort/docs/VALIDATION.md | Separate source checks, in-engine smoke checks and human gameplay checks | Old Godot pass counts as evidence for the new GameMaker code |
| GodotPort/README.md | Familiar selection, contextual orders, training, cancellation and minimap controls | Large-map camera, order queues/groups, rally UI, network UI |

## Service contracts

`rts_unit_build_def(x, y, id, owner)` builds from packaged or external INI content while preserving the multiple-template model. Template IDs are explicitly whitelisted in rts_template_resolve. Add new supported traits there, then declare their initialization and cleanup behavior before exposing them to mods.

`rts_command(player, unit, verb, x, y, target, product_index)` owns admission. UI and AI should not assign command state or spend credits directly. The current target argument is meaningful for attack. Product indices address the producer's declared catalog; stable definition IDs are captured by the catalog/queue.

`rts_nav_request(x, y)` returns a service-owned field. Callers must not destroy or retain the handle across blocker/terrain changes. Requests made during a single unit movement call are safe; unit state stores destinations, not cached grid handles. Terrain writers must call rts_nav_clear after editing cells. rts_nav_block updates occupancy and invalidates fields automatically.

`rts_visible(viewer, unit)` is the disclosure boundary. Future targeting, minimap and network implementations should call it rather than inventing separate visibility tests. The current fog is player-specific radial tile sight, not a network information-hiding protocol.

## Lifecycle boundaries

Destroy an entity while its player and world registries are alive. Unit cleanup refunds queued work, removes targeting/selection references, releases occupancy and destroys owned lists/maps. Player cleanup frees fog and selection. World cleanup releases fields, terrain, content, category lists, image groups and signals after entities. F2 exercises a room restart through this path.

## Validation boundary

Static resource/content checks pass independently of engine execution. A direct GMAssetCompiler attempt returned `Permission Error : Unable to obtain permission to execute` before GML compilation. The user will build/test in GameMaker. No new GameMaker runtime pass count, Windows export success or multiplayer result is claimed.
