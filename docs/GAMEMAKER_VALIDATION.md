# GameMaker validation

## Completed here

`python tools/verify_gamemaker.py` checks registered scripts/resources, unique object event registrations, included-file existence/count, new RTS call references and delimiters, and packaged INI trait/product references. It does not compile or execute GML. `git diff --check` checks patch whitespace.

A local GameMaker Studio 1.4 GMAssetCompiler invocation stopped with `Permission Error : Unable to obtain permission to execute` before compilation. Runtime/build testing is left to the user in the installed IDE. The historical GodotPort/docs/VALIDATION.md results apply only to the port build they describe.

## Build and smoke test

1. Reopen RTSTemplate.project.gmx so the IDE reloads new resources. Run rm_test directly with F6. Confirm two owners, an authored obstacle wall, a friendly base/infantry, fog, resource counter and minimap appear. The two core INI files must be listed under Included Files.
2. Press F8 and inspect the debug output: `RTS smoke: ... passed, 0 failed`. The checks create isolated temporary players/units and restore match pause/outcome state. They check stable IDs/composition, ownership and bounds, cached navigation, blocked destinations, pause, fog memory/hidden attack rejection, production charge/refund/completion, insufficient credits, queue limit, capability removal and producer-death refunds.
3. Select your base and press T. Credits fall by 25; after 90 unpaused steps one owned infantry appears. Press C on a queued job and confirm exactly one refund. Pause midway and confirm production/movement wait while orders/cancellation still work.
4. Move a group through the wall passage. Blocked terrain/building destinations should reject and routes should avoid the wall. Units currently share positions; local separation is deferred.
5. Send infantry near the central crystal. Within 80 pixels, uncontested mobile ownership earns 5 credits per second until the finite stock is exhausted. Opposing units contest extraction.
6. Scout the enemy. Enemy units should appear only in current sight in both world and minimap; explored terrain remains dim after leaving. Attack a visible enemy and verify range, cooldown, damage and destruction. The AI may engage after 30 seconds.
7. Destroy the enemy base and confirm Victory; losing yours gives Defeat. Orders after match end reject. Press F2 repeatedly to switch scenarios/restart and watch for invalid list/map/grid handles or stale targeting references. F2 returns to a fresh match.
8. Try a Windows export and confirm packaged definitions load outside the source folder. Multiplayer, networking visibility, long matches, terrain-occluded vision and exact Godot parity are not validated by these checks.
