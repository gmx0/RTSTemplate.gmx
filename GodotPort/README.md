# RTSTemplate — Godot port

A functional 2D Godot 4 port of the GameMaker Studio 1.4 RTS framework. Uses GDScript and the Compatibility renderer; no .NET SDK, addons, or conversion runtime required. Tested with the installed Godot 4.7.2 editor.

Open `project.godot` in Godot and press **F6/F5** (F5 runs the full project). The starting scene is a small skirmish with two bases, engineers, infantry, resources, terrain, fog and a simple opponent. **Menu / Help → Original rm_test** opens the source project's one-infantry sandbox.

## Controls

| Control | Action |
| --- | --- |
| Left-click / drag | Select friendly entity / group of mobile units |
| Shift + left-click | Add or toggle selection |
| Right-click | Move, attack enemy, harvest crystals, repair damaged ally; set rally point for buildings |
| Shift + right-click | Queue an order |
| WASD / arrows, middle-drag | Pan camera |
| Wheel | Zoom |
| Ctrl+1–9 / 1–9 | Store / recall control group |
| X / H | Stop / hold position |
| F / P, then click | Attack-move / patrol |
| Space | Pause simulation; host only in multiplayer |
| Escape | Cancel placement/order and clear selection |
| F5 / F9 while playing | Save / load offline game |
| Minimap left / right-click | Center camera / move selected units |

Select one engineer to show construction buttons. Choose a building and click clear, visible land within 280 pixels of that engineer. Construction then completes automatically. Select Headquarters or Barracks to queue units. Power below zero suspends production and disables powered building weapons. Engineers harvest directly into credits in batches of ten; no return-to-base requirement. Destroy the enemy HQ to win. The AI observes disclosed contacts, resumes harvesting, trains declared combat units, responds to contacts and starts scouting the opposite starting area after 50 seconds.

## Ported systems

- Runtime template attachment/removal with prerequisites and per-template step/event hooks.
- Player ownership, unit selection, contextual commands, queues, formation destinations, groups, pause and game time.
- Shared 32-pixel flowfield grids, cached integration fields, terrain movement layers, structure obstacles, local separation and flocking demo.
- Named targeting categories, spatial queries, health, armor, regeneration, shields, projectiles, cooldowns and veterancy.
- Player-specific shroud/explored/visible fog, participant-relative Reveal, powered cloak detection and an interactive minimap.
- Data-driven unit/image IDs, external image fallback, original sprite assets, and source inventory.
- Construction, production, resource harvesting, power and prerequisites, filling out several source placeholders.
- Native Godot GUI, selection details, command/build cards, notifications, checkboxes and text input.
- Frame-scoped signals with broadcast, recipient filtering and consume-once semantics.
- ENet host/client transport, server-validated commands and authoritative snapshots.
- Offline JSON saves, including orders, production, resources, fog memory and projectiles.

See [first-priority RTS systems](docs/RTS_PRIORITY_SYSTEMS.md) for command results, declared abilities/hotkeys, production refunds and pause reasons, AI policy ownership, and fog disclosure rules. Select a producer with a queue to cancel its first item for an exact-cost refund.

See [next-priority RTS systems](docs/RTS_NEXT_SYSTEMS.md) for transports/garrisons, depot cargo, deploy/pack, ammunition/status effects and objective rules. HQ can train a Transport, Cargo harvester or Mobile constructor. Right-click a friendly host to board; select the host to Unload. Mobile constructors expose Deploy outpost / Pack up. Shield troopers rearm near HQ. Menu / Help also offers an Economy race.

## Content and code

Edit `mods/core/units.json` to change unit definitions. `templates` contains stable template IDs corresponding to the original `obj_template_*` names. `image` selects a stable ID; `image_path` can reference a project asset or an external PNG. A missing image falls back to the original `spr_unit_0.png`. All 155 original sprite frames are in `assets/`. The optional external `mods/core/images/units/infantry.png` was not present in the source checkout, so the fallback is intentional.

`scripts/trait.gd` is the template behavior dispatcher. Add new behavior there and reference it from unit data. `scripts/unit.gd` owns entity state and orders; `world.gd` owns the match and validates commands; services for content, navigation, fog, targeting and signals are separate scripts. `docs/source_inventory.json` records all 90 original objects and their event code, 204 scripts, 3 rooms and sprite metadata. It is reference material, not executable GML.

See `docs/PORTING.md` for migration choices and extension-only templates. This is a functional framework port, not a claim that every placeholder in the source has become a finished game feature.

## Multiplayer

Run two project instances. On one, open **Menu / Help → Host**. On the other, enter the host's IP and choose **Join**. Loopback address `127.0.0.1` is for two instances on the same PC. The host is player 1; the single guest is player 2 and takes over the AI's army. UDP port 24680 must be reachable. The host simulates, validates ownership, checks target visibility and broadcasts snapshots at roughly 7 Hz. All clients need the same content files. This is a LAN prototype, with no matchmaking, reconnection, content negotiation, interpolation or information-hiding protocol; full world state is replicated. Fog hides enemy entities in the presentation, not in the network packets.

## Verification

```powershell
python tools/verify.py --network --godot 'C:\path\to\Godot_console.exe'
```

The runner imports assets, executes gameplay assertions in the actual scene, and optionally launches an ENet host and client. Logs are written under `docs/`. `tests/visual.gd` captures the game and menu using the actual renderer when run without `--headless`.

## Copy into the intended empty project

The port was staged here because the session denied writes to `C:\Users\HP\Documents\gm-rts-to-godot-template`. To install from a normal PowerShell window:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Install-Port.ps1
```

This backs up the destination's initial `project.godot`, refuses to merge into an existing gameplay project, and copies the port without generated `.godot` caches. The GameMaker source is unchanged.
