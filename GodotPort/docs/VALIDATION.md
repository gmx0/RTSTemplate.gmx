# Validation - 2026-11-14

Engine: installed Godot 4.7.2 .NET Windows build, running GDScript with the Compatibility renderer. No C# build required.

- Headless editor import: passed.
- Existing gameplay suite: **41 passed, zero failed**, including multiple-template runtime attach/remove, flowfields, combat, economy, construction, snapshots and offline saves. See `gameplay.log`.
- First-priority suite: **30 passed, zero failed**; see `priority.log` for command rejection side effects, generated abilities/hotkeys, paid cooldowns and snapshot persistence, production cancellation/refunds, pause reasons, blocked exits, fog/debug/Reveal/detection, and AI ownership checks.
- Next-priority suite: **38 passed, zero failed**; see `next_priority.log` for containment reservations/death/capture, depot delivery/recovery, deploy/pack and trait persistence, ammunition/status/target domains, objective thresholds and lifecycle snapshots.
- ENet loopback: actual host/client processes validate movement replication and authoritative accepted/rejected command result feedback. See `network_host.log` and `network_client.log`.
- Rendered engineer HUD and menu: captured with the real Compatibility renderer and inspected at 1280x800; updated action controls fit and remain readable. See `preview.png` and `menu.png`.

Run `python tools/verify.py --network` to repeat import, all three gameplay suites and ENet tests. See [first-priority implementation contracts](RTS_PRIORITY_SYSTEMS.md).

The sandboxed engine emits a system root certificate store warning during startup. The verifier excludes that environment warning; script errors and failed gameplay checks still fail verification. No TLS service is used by ENet.

The original GameMaker project was not modified. This directory is the standalone Godot workspace, not the older staged `GodotPort/` directory.

Not qualified: exported Windows build, WAN/firewall traversal, long-duration multiplayer stability, hidden-information network security, balance or exhaustive viewport/controller testing. Full snapshots still include hidden entities. Extension-only templates are listed in `PORTING.md`.
