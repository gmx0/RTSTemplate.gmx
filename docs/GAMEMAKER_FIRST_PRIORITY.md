# GameMaker first-priority API

The five Study RTS Systems priorities are integrated into the GameMaker multiple-template framework and extended by the Markdown incorporation pass.

- Command admission/results: `rts_command(player, unit, verb, x, y, target, product_index)` accepts move, stop, attack, produce and cancel. It returns a stable status string and records per-unit results; player input also records feedback for the HUD. Orders and queue changes are allowed during pause; simulation is suspended. Ownership, abilities, navigation, target disclosure, queue bounds and costs are checked before gameplay mutation.
- Declared abilities: templates use `rts_ability_set(name, enabled)`. Bipedal declares move, weapon declares attack, constructor declares produce. Removing these provider templates revokes the capability. Structural units remain immobile.
- Production lifecycle: `rts_product_add(unit_object, template_object, duration_steps, cost[, definition_id])` declares products. Jobs charge once, complete into owned units, wait at blocked exits, and refund the original payer on cancellation or destruction. Disabling produce suspends the queue. Default base products and infantry costs come from INI definitions.
- AI policy separation: assign a script to `player_ai_policy`; it receives the player instance and calls admission. rts_skirmish_policy chooses training and movement intent; default player policy is idle.
- Fog disclosure: each player owns shroud/explored/current sight. `rts_visible` and `rts_point_visible` are shared by rendering, selection, targeting, attack admission and minimap. Sight does not implement radar, cloak or terrain occlusion.

`unit_build` retains the legacy object/template constructor and accepts an optional owner. `rts_unit_build_def` adds stable data IDs without replacing template_list. The practical sandbox uses that new constructor.

Read PROJECT_STATE.md for the current scope and ownership model, INCORPORATION.md for service contracts, and GAMEMAKER_VALIDATION.md for build/test instructions. Old Godot validation does not establish GameMaker correctness.
