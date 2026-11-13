# RTSTemplate Game Design Document

This document describes the intended design direction for the RTS template. It is forward-looking: it should guide future implementation while respecting the current template-based GameMaker architecture.

## Implementation status

The Markdown incorporation pass adds a small GameMaker slice of data-defined units, cached land flowfields, command admission, production, basic combat/economy, fog and a minimap. This document remains the long-term design, not a claim that every feature below exists. See PROJECT_STATE.md for current behavior, INCORPORATION.md for adopted/deferred items, and GAMEMAKER_VALIDATION.md for the test boundary. GameMaker runtime verification remains pending.

## Vision

Build a moddable real-time strategy framework where units, structures, factions, visuals, weapons, costs, and upgrades are defined by data and assembled from reusable gameplay templates.

The game should support classic RTS interactions:

- select units
- command movement
- command attacks
- build structures
- train units
- gather and spend resources
- scout through fog of war
- use unit roles, counters, and upgrades
- eventually play over a network using server authority

The template system should remain the core technical identity of the project. GameMaker objects provide behavior modules, while mod data chooses which modules a unit or structure uses.

## Design Pillars

### Moddability First

Content should be addressed by stable string IDs:

- unit IDs
- image IDs
- weapon IDs
- faction IDs
- resource IDs
- upgrade IDs

Runtime handles such as GameMaker instance IDs, sprite indexes, image grids, sockets, and object references should be resolved from data instead of being the data.

### Composition Over Deep Inheritance

Units and structures should be assembled from templates:

- visual
- health
- armor
- movement
- weapon
- resource
- constructor
- storage
- radar
- stealth/detection
- veterancy

This allows mods to combine behavior without requiring a new GameMaker object for every unit type.

### Server-Authoritative Multiplayer

Networking should treat clients as command senders and the server as the source of truth.

Clients send intent:

- select group
- command move
- command attack
- build request
- train request

Server validates and broadcasts results:

- unit spawned
- command accepted
- unit snapshot
- unit damaged
- unit destroyed
- resource changed

### Data-Driven Presentation

Visuals, icons, animations, UI cards, and sounds should come from mod data. Built-in GameMaker sprites should be fallbacks and editor conveniences, not the final content pipeline.

## Target Player Experience

The player starts with a small force or base, scouts the map, gathers resources, builds production, creates an army, and defeats opponents through positioning, production, scouting, and counters.

Core loop:

1. Scout terrain and enemy location.
2. Gather or secure resources.
3. Build infrastructure and production.
4. Train units.
5. Issue movement and attack commands.
6. Expand, tech, or pressure.
7. Win by destroying key enemy assets or meeting scenario objectives.

## World And Match Structure

The game world is a 2D top-down map.

Maps should eventually define:

- dimensions
- terrain layers
- walkability
- resource locations
- starting positions
- neutral entities
- fog/shroud start state
- scenario rules

The current test room is a sandbox. Future content should move toward map data and scenario setup scripts.

## Factions

Factions should be data-defined.

A faction can provide:

- display name
- player color defaults
- available unit definitions
- available structure definitions
- tech tree
- starting units
- starting resources
- UI theme/icon set

Early implementation can start with one core faction. Multiple factions should be possible once unit definitions and tech requirements are data-driven.

## Units And Structures

All controllable world entities should share a common entity/unit foundation.

Important common fields:

- `unit_def_id`
- `unit_image_id`
- owner/player
- health/max health
- position and command target
- state
- template list
- targeting categories
- network ID

Units are mobile tactical actors.

Structures are mostly stationary actors that may:

- produce units
- generate power
- store resources
- provide radar
- unlock tech
- defend an area

Structures can use the same template model as units, but may use different movement and placement rules.

## Template Categories

### Visual

Draws an externally loaded mod image, supports animation, and falls back gracefully.

Future visual data:

- image ID
- frame count
- animation names
- frame speed
- origin
- scale
- selection radius
- icon ID

### Health And Defense

Provides hit points, damage handling, death behavior, armor, shields, and regeneration.

Future rules:

- damage types
- armor classes
- shield delay and recharge
- wreck/death templates

### Movement

Provides command movement using flowfields plus local avoidance.

Movement type examples:

- bipedal
- wheeled/tracked
- aerial
- naval
- amphibious
- immobile

Movement should separate macro navigation from local steering:

- flowfields provide direction to a destination
- local avoidance prevents stacking and handles nearby obstacles

### Weapon

Provides attack behavior.

Weapon data should include:

- range
- cooldown
- damage
- projectile or instant hit
- target filters
- firing arc
- splash/warhead
- ammo or energy cost

### Economy

Provides costs, resource storage, harvesting, construction, production queues, and power usage/generation.

### Sensor And Targeting

Provides vision, radar, stealth, cloak detection, disguise detection, and target category membership.

## Commands

Initial commands:

- select
- move
- attack
- stop
- hold position
- patrol
- build
- train

Commands should be represented as data on units and as network packets in multiplayer.

Example move command fields:

- command type: move
- target x/y
- optional formation index
- optional queue flag
- command issuer/player

## Movement Design

The intended movement system is flowfield-driven.

`obj_flowfield` should become a pathing service:

- terrain walkability grid
- cost grid
- cached flowfields by target tile and movement layer
- helper scripts to request fields and read directions

Units should not calculate full paths every step. They should request or reuse a flowfield for a command destination.

Planned scripts:

- `flowfield_request(target_x, target_y, movement_layer)`
- `flowfield_get_direction(flow_id, unit_x, unit_y)`
- `flowfield_release(flow_id)`
- `flowfield_rebuild_for_terrain_change()`

Local avoidance should be layered on top of flowfields using existing steering behavior scripts.

## Targeting Design

The current targeting map is a named-list registry. The intended version should support efficient queries.

Future targeting should answer:

- what enemy units are in range?
- what air units are nearby?
- what structures are visible?
- what repairable allies are nearby?
- what objects are detectable by this sensor?

Implementation can evolve from named lists to spatial buckets or grids.

Targeting categories should still come from templates and mod data.

## Fog Of War Design

Fog should be player-specific.

States:

- unexplored shroud
- explored but not currently visible
- currently visible

Vision should come from templates:

- normal sight
- radar
- detector
- stealth/cloak interactions

Fog should affect:

- rendering
- targeting
- command validation
- minimap visibility
- networking visibility, if relevant

## Economy Design

The economy should be modular so mods can define one or more resources.

Possible resources:

- credits
- power
- supply
- ammo
- special tech resource

Core systems:

- resource harvesting
- storage limits
- construction cost
- training cost
- upkeep or power drain
- production queues

## Construction And Production

Construction should be template-driven.

Possible construction flows:

- instant spawn for tests
- builder unit places structure
- structure trains units from queue
- production blocked by missing prerequisites or resources

Production data should define:

- produced unit ID
- cost
- build time
- required templates/buildings/upgrades
- spawn point behavior

## UI Design

The UI should support standard RTS workflows:

- selection panel
- command card
- build/train queues
- minimap
- resource display
- notifications
- tooltips

GUI elements should eventually use mod-defined images and icons through the same image ID system as units.

UI should read gameplay data instead of owning gameplay rules.

## Mod Design

Future mod folder structure:

```text
mods/
  core/
    mod.ini
    images/
    units/
    structures/
    weapons/
    factions/
    maps/
```

Example content IDs:

- `core.units.infantry`
- `core.units.engineer`
- `core.structures.barracks`
- `core.weapons.rifle`
- `core.images.units.infantry`
- `core.factions.default`

The first supported mod feature is external images. The next major step is loading unit definitions.

## Networking Design

Networking should be server-authoritative.

Each networked entity should have a server-assigned `net_id`.

Do not send local GameMaker instance IDs over the network.

Initial packet set:

- `JoinGame`
- `AssignPlayer`
- `SpawnUnit`
- `CommandMove`
- `CommandAttack`
- `UnitSnapshot`
- `DestroyUnit`
- `ResourceSnapshot`

Clients may predict simple movement later, but the server remains authoritative.

## Save And Replay Design

Long-term, the same stable IDs used for modding and networking should support saves and replays.

Save data should record:

- map ID
- mod list and versions
- players
- unit definition IDs
- positions
- health/resources
- command queues

Replay data should record:

- initial state
- player commands over time
- random seed

## Implementation Roadmap

### Phase 1: Stabilize Current Sandbox

- keep `rm_test` as the main test room
- keep built-in test infantry working
- add small, focused systems behind scripts
- document ownership of global data structures

### Phase 2: Data-Driven Units

- add unit definition registry
- load a core infantry definition from mod data
- build units by `unit_def_id`
- move hp, visual ID, and template list out of `obj_template_test_infantry`

### Phase 3: Flowfield Movement

- add flowfield request/get-direction scripts
- integrate movement into a unit movement template
- use command targets from player right-clicks
- add local separation

### Phase 4: Combat

- implement weapon template
- implement target acquisition
- implement damage/death
- connect health and targeting cleanup

### Phase 5: Economy And Structures

- add resources
- add costs
- add construction
- add production queues
- add basic tech prerequisites

### Phase 6: Fog And Minimap

- connect unit vision to fog
- draw player-specific fog
- integrate minimap visibility

### Phase 7: Multiplayer

- initialize RTS packet identifiers
- add server-authoritative spawn and command flow
- add unit snapshots
- add client-side rendering and correction

## Open Design Questions

- Should mod data use INI files first, or should a JSON/parser extension be introduced?
- Should flowfields be cached per target tile, per command group, or per movement layer plus target?
- Should structures inherit from `obj_unit`, or should they share `obj_entity` and use structure-specific templates?
- How much animation state should live in `obj_template_visual_image` versus a separate animation template?
- Should targeting move to a grid immediately, or only after combat makes list scans too expensive?
- What is the first playable objective: elimination, survival, capture point, or sandbox skirmish?
