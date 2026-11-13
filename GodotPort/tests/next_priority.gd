extends SceneTree
var world
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func tick(seconds: float) -> void:
	for i in range(ceili(seconds * 30)):
		world._physics_process(1.0 / 30)

func run() -> void:
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_physics_process(false)
	world.set_process(false)
	world.ai_enabled = false
	world.sandbox = true
	check(world.content.validate().is_empty(), "new transport, harvester and mobile-constructor content validates")
	var soldier = world.units.filter(func(u): return u.owner_id == 1 and u.definition_id == "core.units.infantry")[0]
	var host = world.spawn("core.units.transport", 1, soldier.position + Vector2(35, 0))
	host.stats.capacity = 1
	check(world.execute_command(1, {"type": "enter", "ids": [soldier.net_id], "target": host.net_id}).code == "accepted", "boarding command reserves a passenger slot")
	var other = world.spawn("core.units.infantry", 1, soldier.position + Vector2(0, 70))
	check(world.execute_command(1, {"type": "enter", "ids": [other.net_id], "target": host.net_id}).code == "blocked", "incoming reservation prevents overbooking")
	world.execute_command(1, {"type": "stop", "ids": [soldier.net_id]})
	check(soldier.reserved_host_id == 0, "replacement order releases boarding reservation")
	world.execute_command(1, {"type": "enter", "ids": [soldier.net_id], "target": host.net_id})
	tick(0.1)
	check(soldier.host_id == host.net_id and soldier.commands.is_empty(), "passenger boards on approach without losing identity")
	world.refresh_services()
	check(not soldier in world.targeting.query(host.position, 100) and not world.entity_disclosed(2, soldier), "contained passenger is absent from spatial and disclosure consumers")
	check(world.execute_command(1, {"type": "move", "ids": [soldier.net_id]}).code == "invalid_source", "contained unit cannot receive direct world orders")
	var saved: Dictionary = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	soldier = world.find_unit(soldier.net_id)
	host = world.find_unit(host.net_id)
	check(soldier.host_id == host.net_id, "containment survives JSON snapshot restore")
	var terrain: PackedByteArray = world.navigation.terrain.duplicate()
	world.navigation.terrain.fill(2)
	check(world.execute_command(1, {"type": "unload", "ids": [host.net_id]}).code == "blocked" and soldier.host_id == host.net_id, "blocked unload retains cargo")
	world.navigation.terrain = terrain
	check(world.execute_command(1, {"type": "unload", "ids": [host.net_id]}).code == "accepted" and soldier.host_id == 0, "clear unload restores passenger to world")
	var hq = world.units.filter(func(u): return u.owner_id == 1 and u.definition_id == "core.structures.hq")[0]
	soldier.position = hq.position + Vector2(55, 0)
	world.execute_command(1, {"type": "enter", "ids": [soldier.net_id], "target": hq.net_id})
	tick(0.1)
	check(soldier.host_id == hq.net_id, "static garrison reuses transport boarding")
	world.execute_command(1, {"type": "unload", "ids": [hq.net_id]})
	var carrier = world.spawn("core.units.transport", 1, Vector2(400, 700))
	var passenger = world.spawn("core.units.infantry", 1, Vector2(420, 700))
	world.execute_command(1, {"type": "enter", "ids": [passenger.net_id], "target": carrier.net_id})
	passenger.simulate(0)
	check(passenger.host_id == carrier.net_id, "isolated carrier accepts its passenger")
	carrier.damage(1000)
	check(passenger.host_id == 0 and world.find_unit(passenger.net_id) != null, "carrier destruction evacuates passengers to safe world positions")
	carrier = world.spawn("core.units.transport", 1, Vector2(400, 750))
	passenger.position = Vector2(420, 750)
	world.execute_command(1, {"type": "enter", "ids": [passenger.net_id], "target": carrier.net_id})
	passenger.simulate(0)
	check(world.change_owner(carrier, 2) and carrier.owner_id == 2 and passenger.host_id == 0 and passenger.owner_id == 1, "capture releases cargo without transferring passenger allegiance")
	var resource = world.units.filter(func(u): return u.has_template("resource"))[0]
	var hauler = world.spawn("core.units.hauler", 1, resource.position + Vector2(40, 0))
	var credits: int = world.players[1].credits
	world.execute_command(1, {"type": "harvest", "ids": [hauler.net_id], "target": resource.net_id})
	hauler.tick_engineer(2)
	check(hauler.cargo == 20 and world.players[1].credits == credits and hauler.commands[0].type == "deliver", "logistics harvester carries cargo without remote credit payout")
	hauler.position = hq.position + Vector2(55, 0)
	hauler.tick_engineer(0.1)
	check(hauler.cargo == 0 and world.players[1].credits == credits + 20 and hauler.commands[0].type == "harvest", "depot delivery credits once and resumes harvest")
	check(int(world.objectives.earned.get("1", 0)) == 20, "earned-income objective counts delivered income only")
	hq.stats.accepts_cargo = false
	hauler.cargo = 10
	hauler.begin_delivery(resource.net_id)
	hauler.simulate(0)
	check(hauler.cargo == 10 and hauler.commands[0].type == "deliver", "missing depot retains paid cargo and a retryable delivery intent")
	hq.stats.accepts_cargo = true
	hauler.simulate(0)
	hauler.simulate(0)
	check(hauler.cargo == 0, "restored depot resumes waiting cargo delivery")
	var mcv = world.spawn("core.units.mcv", 1, Vector2(400, 580))
	mcv.hp = 60
	mcv.experience = 3
	mcv.add_template("health_regen")
	var identity: int = mcv.net_id
	world.set_selection([mcv])
	check(world.execute_command(1, {"type": "deploy", "ids": [identity]}).code == "accepted", "mobile constructor deploys at a legal site")
	check(mcv.definition_id == "core.structures.outpost" and mcv.net_id == identity and mcv.hp == 90 and mcv.experience == 3 and mcv.has_template("health_regen") and mcv in world.selected, "transform preserves ID, health ratio, XP, manual traits and selection")
	check(not world.navigation.passable(world.navigation.cell(mcv.position)), "deployed structure blocks navigation")
	saved = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	mcv = world.find_unit(identity)
	check(mcv.has_template("health_regen") and mcv.is_structure(), "save/load retains transformed form and manually attached traits")
	check(world.execute_command(1, {"type": "deploy", "ids": [identity]}).code == "accepted" and not mcv.is_structure() and world.navigation.passable(world.navigation.cell(mcv.position)), "pack removes structure blocker and restores mobile form")
	world.navigation.terrain.fill(2)
	check(world.execute_command(1, {"type": "deploy", "ids": [identity]}).code == "blocked" and not mcv.is_structure(), "blocked transform leaves original form intact")
	world.navigation.terrain = terrain
	var heavy = world.spawn("core.units.heavy", 1, Vector2(700, 650))
	var victim = world.spawn("core.units.infantry", 2, Vector2(760, 650))
	victim.remove_template("weapon")
	var drone = world.spawn("core.units.drone", 2, Vector2(730, 680))
	check(world.execute_command(1, {"type": "attack", "ids": [heavy.net_id], "target": drone.net_id}).code == "invalid_target", "weapon domain rejects aircraft for ground-only weapon")
	world.refresh_services()
	heavy.ammo = 0
	var shots: int = world.projectiles.size()
	heavy.tick_weapon(0)
	check(world.projectiles.size() == shots, "empty ammunition prevents firing")
	heavy.ammo = 4
	heavy.cooldown = 0
	heavy.tick_weapon(0)
	check(heavy.ammo == 3 and world.projectiles.size() == shots + 1, "weapon consumes ammunition once per fired shot")
	var timer: float = world.game_time
	tick(0.2)
	check(victim.effects.has("suppressed"), "projectile applies declared temporary combat status")
	victim.apply_status("stun", 1, {"stunned": true})
	check(world.execute_command(2, {"type": "move", "ids": [victim.net_id], "x": 800, "y": 650}).code == "status_blocked", "temporary stun blocks command admission")
	world.game_time = timer + 4
	victim.simulate(0)
	check(victim.effects.is_empty(), "temporary effects expire on simulation clock")
	heavy.position = hq.position + Vector2(80, 0)
	heavy.ammo = 0
	heavy.tick_rearm(1)
	check(heavy.ammo == 2, "declared friendly support replenishes ammunition")
	heavy.apply_status("guarded", 5, {"armor_bonus": 2})
	saved = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	heavy = world.find_unit(heavy.net_id)
	check(heavy.ammo == 2 and heavy.effects.has("guarded"), "ammunition and statuses survive snapshot")
	world.objectives.reset([{"type": "earn", "amount": 20}])
	world.objectives.income(1, 19)
	check(world.objectives.evaluate(world).is_empty(), "income objective remains incomplete below threshold")
	world.objectives.income(1, 1)
	check(world.objectives.evaluate(world) == "Player 1 wins", "income objective triggers at exact threshold")
	world.objectives.reset([{"type": "survive", "seconds": 5}])
	world.game_time = 5
	check(world.objectives.evaluate(world) == "Draw", "simultaneous survival completion resolves as draw")
	world.objectives.reset()
	var enemy_hq = world.units.filter(func(u): return u.owner_id == 2 and u.definition_id == "core.structures.hq")[0]
	enemy_hq.damage(10000)
	check(world.objectives.evaluate(world) == "Player 1 wins", "default objective retains destroy-enemy-HQ victory")
	saved = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	check(int(world.objectives.losses.get("2", 0)) >= 1, "objective statistics survive snapshot")
	print("RESULT: %s passed; %s failed" % [passed, failed])
	world.free()
	quit(1 if failed > 0 else 0)
