# RTSTemplate

GameMaker Studio 1.4 RTS framework with multiple attachable templates per unit. Open `RTSTemplate.project.gmx`; run `rm_test` directly with F6 for the playable sandbox. The menu Start button also enters that room.

The GameMaker sandbox now uses packaged INI unit definitions, shared pure-data flowfields, owned production queues, basic direct-hit combat, a contested resource point, player-specific fog and a minimap. Destroy the enemy headquarters to win. These are small framework demonstrations, not finished game balance.

| Control | Action |
| --- | --- |
| Left-click / drag | Select friendly units or headquarters |
| Right-click visible enemy | Attack |
| Right-click ground / minimap | Move selected mobile units |
| T with headquarters selected | Queue infantry (25 credits, 90 simulation steps) |
| C with headquarters selected | Cancel first queued unit and refund |
| X | Stop selected units |
| Space | Pause; orders and queue changes remain available |
| F2 | Restart into the one-infantry sandbox / skirmish |
| F8 | Run isolated smoke checks; inspect debug output |

Hold the central crystal with mobile units within 80 pixels to earn 5 credits per second. Opposing units contest extraction. The deposit contains 1,000 credits. Each player starts with 100 credits. Navigation uses an authored wall with a central passage, not random blocked cells.

## Development references

- [Current GameMaker state](docs/PROJECT_STATE.md)
- [Design and long-term roadmap](docs/GAME_DESIGN.md)
- [Incorporation decisions and ownership](docs/INCORPORATION.md)
- [First-priority API](docs/GAMEMAKER_FIRST_PRIORITY.md)
- [Build and gameplay checklist](docs/GAMEMAKER_VALIDATION.md)
- [Godot port](GodotPort/README.md) — separate implementation and historical validation

Run `python tools/verify_gamemaker.py` for static resource and content checks. Compilation and runtime verification are separate; no successful GameMaker build is claimed by the static checker.
