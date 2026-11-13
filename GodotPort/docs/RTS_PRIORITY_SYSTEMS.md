# First-priority RTS systems

Implemented 2026-11-14 in the Godot project. The original GameMaker files are separate and unchanged by this work.

## Commands and ability composition

`world.execute_command(player, command)` is the synchronous gameplay admission boundary for input, GUI, network and AI. It returns `{code, affected}`. `apply_command` retains its Boolean compatibility API. Codes include `accepted`, `invalid_issuer`, `invalid_command`, `invalid_source`, `invalid_target`, `locked`, `unavailable`, `insufficient_funds`, `prerequisite`, `queue_full`, `cooldown` and `blocked`. Invalid ownership in any requested source rejects the command before mutation. For supported group actions, eligible members execute and `affected` records their count; incompatible members are skipped. Train chooses the first eligible requested producer and creates one queue entry. Accepted commands are logged. Network callers receive authoritative result feedback.

The multiple-template registry and runtime attach/remove lifecycle remain in place. `abilities.gd` derives default actions from the unit's currently attached capabilities. Content may declare aliases in a unit definition's `abilities` dictionary:

```json
"abilities": {
  "advance": {"command": "move", "label": "Advance", "cost": 7, "cooldown": 3, "key": 71}
}
```

Here `71` is Godot's G key code. Aliases reuse existing command executors, eligibility and target modes; arbitrary code execution is not supported. `cost` and `cooldown` are optional, nonnegative values; cooldown is measured in simulation seconds. GUI buttons and hotkeys derive from declarations. Targeted actions arm the cursor, and target admission happens on submission. Accepted orders pay once per accepted source and start cooldown immediately, including queued orders. Canceling targeting spends nothing. Command execution always rechecks current capability, construction, ownership, funds and cooldown. Core cooldowns and participant-relative Reveal expiry serialize in unit snapshots.

## Production lifecycle

`production_check` supplies shared eligibility and rejection reasons. `cancel_production` removes an unspawned item and refunds exactly its stored paid cost once. The HUD exposes cancel-first; the command API also accepts a zero-based `slot` for other queue items. Producer death discards its queue without a refund.

Production states are `idle`, `queued`, `producing`, `no_power`, `prerequisite` and `exit_blocked`. Power/prerequisite loss preserves progress. Completion checks 24 bounded exit candidates around the producer, respecting the product's movement layer, terrain footprint, room bounds and live entity occupancy. A blocked exit retains the finished paid item and retries on later simulation ticks. It never searches the whole map to teleport a product. Successful spawn retains the ordinary rally order. Queue progress, paid costs and status survive saves and replication.

## AI ownership

`ai_policy.gd` separates read-only observation, ranked candidate evaluation and command execution. Observation includes owned units, currently disclosed enemy contacts and disclosed resource deposits. Execution calls `world.execute_command`, records results and allows one accepted action per lane per think cycle; a rejected candidate permits a later candidate in the lane. Economy and production are separate lanes; combat lanes are per unit. Existing four-second think cadence remains.

Idle engineers resume harvesting, producers evaluate their declared armed products, and idle combat units engage disclosed contacts. After 50 seconds, absent a contact, units scout the fixed opposite starting area. Those coordinates are map policy, not a hidden enemy-unit lookup. No adaptive learning, construction planner or enemy-position memory is claimed.

## Fog and disclosure

`fog.state` remains quantized terrain exploration/current-visibility presentation. `point_visible` checks live eligible observers against exact circular sight. `entity_disclosed` is the shared gameplay rule for command targets, combat, engineer interactions and AI: ownership, participant-specific Reveal, or current sight plus compatible detection for cloak. Detection needs a completed living same-owner detector and, by default, sufficient participant power. `detector_range` defaults to 250; `detector_requires_power` defaults to true. Sight alone does not detect cloak. Reveals use `unit.revealed_until[str(participant)]` with simulation-time expiry. No new live Reveal ability is added.

Rendering, visual picking and minimap contacts call `can_see`, which delegates to disclosure while fog is enabled. The existing fog debug toggle may show all entities visually, but does not change gameplay admission or AI knowledge. Exploration memory never authorizes an entity-target command. Owned units remain disclosed. Under-construction observers do not supply sight. Terrain fog updates retain their 150ms cadence while gameplay sight reads live state.

The LAN prototype still replicates full world snapshots. These changes enforce simulation rules, not network information privacy; a modified client can inspect hidden snapshot data.

## Validation

Run `python tools/verify.py --network`. This imports the project, executes the existing gameplay suite and `tests/priority.gd`, then launches actual ENet host/client processes. The priority suite exercises rejection side effects, runtime declarations/hotkeys, cooldown/cost/save state, refunds, blocked exits, power and prerequisite pauses, disclosure/detector/Reveal rules and AI execution ownership. `tests/visual.gd` captures the real rendered engineer HUD and menu for layout review. This validates Godot execution only, not GameMaker runtime behavior.
