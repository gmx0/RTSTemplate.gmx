# Next-priority RTS systems

Implemented 2026-11-14 after publishing the first-priority branch. The multiple-template model and shared flowfield backend remain intact.

## Transports and garrisons

Attach `storage_transport` and declare `capacity` to opt a unit into hosting passengers. `passenger_layers` defaults to land; passenger `transport_slots` defaults to one. The Transport and Headquarters demonstrate mobile and static hosts. Unit-target Enter is available on ordinary mobiles; a friendly-host contextual click also enters. Host Unload uses the same executor for mobile transports and static garrisons. Boarding is immediate on reaching contact; it does not teleport an approaching passenger.

Reservations live on approaching passengers and count against host capacity. Replacing an order, host loss or ownership change cancels reservations. Nested transports and structures cannot board. Queued Enter is rejected rather than reserving capacity ambiguously behind an unrelated order. Contained units keep their entity IDs and snapshot records but do not move, fire, provide sight, receive direct orders, appear as minimap contacts or enter spatial queries. Incoming projectiles stop tracking a unit that boards. Garrison firing ports and transport-assisted group travel are not included.

Unload searches bounded terrain- and occupancy-safe local exits. It releases as many passengers as fit and retains the rest. Host destruction evacuates passengers to safe exits and destroys passengers that cannot escape. `change_owner` evacuates old-owner cargo and cancels reservations before changing the host's owner; capture is rejected if stored passengers cannot safely exit. Passenger allegiance never transfers implicitly. Host and passenger IDs, incoming reservations and manual trait attachments survive snapshots.

## Cargo economy

The original Engineer retains direct-credit harvesting. The new Cargo harvester declares `requires_dropoff`, `harvest_capacity: 20` and `harvest_rate: 10`. It collects finite stock, keeps cargo on the unit, chooses the nearest completed owned `accepts_cargo` depot and travels there. Headquarters and Outpost accept cargo. Delivery pays once and resumes the retained resource target if it still has stock. Missing/destroyed depots retain cargo and a retryable delivery intent. Explicit new orders cancel automatic return intent without erasing carried cargo. Depleted deposits deliver partial loads; fractional credit remainders stay in cargo. Destroyed haulers lose carried cargo. Saves retain cargo and the return target.

## Deploy and pack

Definitions opt into a shared transformation with `transforms_to` and optional `transform_label`. Mobile constructor and Outpost demonstrate both directions. The command checks destination content, placement and prerequisites, and refuses transformation while carrying resource cargo, holding passengers/reservations or producing units. It transforms the existing wrapper in place: entity ID, owner, selection, health/shield ratios, experience, cooldowns, effects and manually attached extra traits remain. Form-specific templates, stats, footprint and navigation blockers change; active orders stop. Snapshots retain both transformed definition and actual attached templates. There is no separate transformation instance or parallel pathfinder.

## Combat capabilities

`target_domains` filters ordinary command admission and automatic targeting by movement layer (`land`, `air`, `water`, `amphibious`); omission preserves the previous all-domain behavior. The Shield trooper is ground-only and declares four rounds. Ammunition is spent only on a fired shot. Units with `supply_weapon_ammo` refill compatible same-owner nearby weapons using declared `rearm_range`/`rearm_rate` while completed and powered. Headquarters demonstrates two rounds per second inside 160 pixels. Unlimited-ammo weapons retain `ammo = -1`.

`apply_status(id, duration, modifiers)` stores simulation-time effects with optional `speed_multiplier`, `armor_bonus` and `stunned`. Same-ID application replaces that effect. Active speed multipliers multiply, armor bonuses add, and stun freezes unit simulation/blocks ordinary orders. Expiry, movement, damage, command admission and snapshots use this state. Shield-trooper projectiles demonstrate two seconds of suppression at 70% movement speed through `hit_status`. Cargo/ammunition/status displays share selection details. No generalized buff editor, projectile-counter system or new damage-type matrix is claimed.

## Objectives and results

`start_match(false, rules)` accepts match-owned objective declarations. Supported rules are `destroy` by definition, `earn` by newly received resource income, and `survive` by elapsed simulation time with a living owned health unit. Every rule must complete for a participant to win; simultaneous completion is a draw. Default rules preserve destroy-opposing-Headquarters victory. `Economy race` in Menu / Help starts an earn-250 match. The HUD displays current rules and income progress. Starting credits, refunds and spending do not count as income. A match evaluation occurs after the simulation slice, so terminal resolution does not depend on which HQ destruction callback ran first.

Match facts retain per-participant unit losses and earned credits. Rules and facts serialize with the world. The existing result banner displays the terminal outcome; there is no separate campaign scoring or results screen. Survival rules apply equally to both sides and can produce a draw if both remain alive at the threshold. Custom rule authoring currently uses code/data, not a public scenario editor.

## Validation

`python tools/verify.py --network` executes the original suite, the first-priority suite and `tests/next_priority.gd`, plus actual ENet host/client validation. Next-priority checks exercise capacity reservations/cancellation, boarding, safe/blocked unload, garrisons, death/capture, cargo delivery/depot recovery, transformation identity and trait preservation, ammunition/status/domain rules, objective thresholds and snapshot state. Rendered HUD/menu captures are checked separately. Full hidden-information network privacy, dense transport stress tests, exported builds and long-duration balance remain outside this qualification.
