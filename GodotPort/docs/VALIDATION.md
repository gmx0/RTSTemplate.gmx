# Validation — 2026-10-21

Engine: Godot 4.7.2 .NET Windows build, running GDScript with the Compatibility renderer. No C# build required.

- Headless editor import: passed; all native scripts compiled and original sprite assets imported.
- Gameplay checks: **41 passed, zero failed**. See `gameplay.log`. Covers initialization, composition/dependencies, selection, ownership and destination validation, production costs/timing, harvesting, repair, construction/placement, power, JSON round-trip, disk saves, targeted/consumable signals, shared flowfields and invalidation, routing across the land bridge, shroud/exploration/current vision, pause, projectiles/death/veterancy, armor/shields and regeneration, and the original one-infantry sandbox.
- ENet loopback test: **passed** in two independent Godot processes. Host accepted the remote player 2 command; client observed the resulting authoritative movement and received eight snapshots. See `network_host.log` and `network_client.log`. The harness waits for the host's ready marker before starting the guest.
- Renderer review: game and menu captured from the running Compatibility renderer in `preview.png` and `menu.png`. Selection details, construction buttons, minimap, resources, fog, game modes and connection controls are visible and readable at 1280×800.
- Installer: copied successfully into a temporary empty project, retained the original project configuration backup, and refused a second install into the now-populated destination.
- Original GM source: no tracked source files modified. New port files are confined to `GodotPort/`.

The sandboxed engine emits a system root certificate store warning during startup. The verifier excludes that environment warning from failure detection; no TLS service is used by the LAN transport. Script errors and failed gameplay checks still fail verification.

Not verified: an exported Windows binary (export templates are required), remote LAN/WAN/firewall traversal, long-duration multiplayer stability, or exact visual/balance equivalence with the original. Extension-only templates are listed in `PORTING.md`.
