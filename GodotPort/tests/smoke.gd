extends SceneTree
var world
var failed := 0
var passed := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)

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
	check(world.units.size() == 20, "skirmish scene initializes both armies and deposits")
	check(world.content.validate().is_empty(), "all content IDs and template references resolve")
	check(world.content.templates.size() >= 50, "source template registry retained")
	check(world.power(1) == 20, "HQ supplies power")
	var infantry = world.units.filter(func(u): return u.definition_id == "core.units.infantry" and u.owner_id == 1)[0]
	check(infantry.hp == 10 and infantry.has_template("bipedal"), "source infantry HP and template composition")
	check(infantry.add_template("health_regen"), "templates can be attached at runtime")
	check(not infantry.add_template("health_regen"), "duplicate templates rejected")
	check(not infantry.remove_template("health"), "template dependency protects health")
	infantry.hp = 5
	tick(2)
	check(infantry.hp > 6, "health regeneration template executes")
	check(infantry.remove_template("health_regen"), "template detach works")
	world.select_region(infantry.position, infantry.position)
	check(infantry in world.selected, "click selection resolves friendly entity")
	world.select_region(Vector2(300, 180), Vector2(520, 320))
	check(world.selected.size() >= 3, "box selection collects army")
	var enemy = world.units.filter(func(u): return u.owner_id == 2 and not u.is_structure())[0]
	check(not world.apply_command(1, {"type": "move", "ids": [enemy.net_id], "x": 100, "y": 100}), "server rejects orders for enemy units")
	check(not world.apply_command(1, {"type": "move", "ids": [infantry.net_id], "x": INF, "y": 100}), "server rejects non-finite destinations")
	check(not world.apply_command(1, {"type": "attack", "ids": [infantry.net_id], "target": enemy.net_id}), "server rejects attack into shroud")
	var hq = world.units.filter(func(u): return u.owner_id == 1 and u.definition_id == "core.structures.hq")[0]
	var credits: int = world.players[1].credits
	check(hq.enqueue_product("core.units.infantry"), "production accepts supported product")
	check(world.players[1].credits == credits - 40, "production charges credits once")
	var count: int = world.units.size()
	tick(3.5)
	check(world.units.size() == count + 1, "production spawns a unit after build time")
	var engineer = world.units.filter(func(u): return u.owner_id == 1 and u.has_template("engineer"))[0]
	var deposit = world.units.filter(func(u): return u.has_template("resource"))[0]
	engineer.position = deposit.position + Vector2(40, 0)
	credits = world.players[1].credits
	check(world.apply_command(1, {"type": "harvest", "ids": [engineer.net_id], "target": deposit.net_id}), "engineer accepts harvest order")
	tick(3)
	check(world.players[1].credits > credits and deposit.stock < 1000, "harvesting transfers finite deposit stock to credits")
	infantry.hp = 2
	engineer.position = infantry.position + Vector2(25, 0)
	world.apply_command(1, {"type": "repair", "ids": [engineer.net_id], "target": infantry.net_id})
	tick(2)
	check(infantry.hp == infantry.hp_max, "engineer repairs friendly health")
	engineer.position = Vector2(400, 500)
	world.refresh_services()
	check(world.build_structure(1, [engineer], "core.structures.barracks", Vector2(480, 512)), "construction validates and places barracks")
	check(not world.can_place("core.structures.barracks", Vector2(480, 512)), "occupied placement rejected")
	var barracks = world.units.filter(func(u): return u.definition_id == "core.structures.barracks")[0]
	check(barracks.construction == 0, "new structure begins under construction")
	tick(8)
	check(barracks.construction == 1 and world.power(1) == 15, "construction finishes and power consumption activates")
	check(barracks.enqueue_product("core.units.heavy"), "completed building satisfies production prerequisite")
	var saved: Dictionary = world.serialize()
	var before: int = world.units.size()
	var saved_position: Vector2 = infantry.position
	infantry.position = Vector2(100, 100)
	world.players[1].credits = 0
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	infantry = world.find_unit(infantry.net_id)
	check(world.units.size() == before and infantry.position.distance_to(saved_position) < 0.1, "JSON snapshot restores units and positions")
	check(world.players[1].credits == saved.players[1].credits, "JSON snapshot restores economy")
	check(world.save_game() and world.load_game(), "save file writes and reloads")
	world.bus.send("test", 42, infantry.net_id)
	check(world.bus.receive("test", infantry.net_id, true) and not world.bus.receive("test", infantry.net_id), "targeted signals support consume-once")
	world.bus.send("test")
	world.bus.reset()
	check(not world.bus.receive("test"), "frame signals clear")
	world.start_match(true)
	world.ai_enabled = false
	infantry = world.units[0]
	infantry.position = Vector2(800, 400)
	world.refresh_services()
	world.apply_command(1, {"type": "move", "ids": [infantry.net_id], "x": 1400, "y": 400})
	var crossed_water := false
	for i in range(600):
		world._physics_process(1.0 / 30)
		if not world.navigation.passable(world.navigation.cell(infantry.position)):
			crossed_water = true
	check(infantry.position.distance_to(Vector2(1392, 400)) < 35 and not crossed_water, "flowfield routes across land bridge without entering water")
	var cache_count: int = world.navigation.cache.size()
	world.navigation.request(Vector2(1400, 400))
	check(world.navigation.cache.size() == cache_count, "shared flowfields reused")
	world.navigation.block_rect(Rect2(Vector2(1300, 600), Vector2(32, 32)), true)
	check(world.navigation.cache.is_empty(), "terrain changes invalidate shared fields")
	check(world.fog.state(1, infantry.position) == 2 and world.fog.state(1, Vector2(10, 1200)) == 0, "fog distinguishes current vision and unexplored shroud")
	check(world.fog.state(1, Vector2(800, 400)) == 1, "previously visited terrain remains explored")
	world.paused = true
	var time: float = world.game_time
	tick(1)
	check(world.game_time == time, "pause freezes simulation time")
	world.paused = false
	world.show_fog = false
	var victim = world.spawn("core.units.infantry", 2, infantry.position + Vector2(80, 0))
	victim.remove_template("weapon")
	var victim_id: int = victim.net_id
	world.refresh_services()
	world.apply_command(1, {"type": "attack", "ids": [infantry.net_id], "target": victim_id})
	tick(7)
	check(world.find_unit(victim_id) == null and infantry.experience == 1, "projectile combat kills target and awards veterancy")
	var heavy = world.spawn("core.units.heavy", 1, Vector2(200, 200))
	var health: float = heavy.hp
	heavy.damage(5)
	check(heavy.hp == health and heavy.shield < heavy.shield_max, "shields absorb damage before health")
	tick(8)
	check(heavy.shield == heavy.shield_max, "shield recharge waits after damage")
	world.start_match(true)
	check(world.units.size() == 1 and world.units[0].hp == 10, "original rm_test sandbox remains available")
	print("RESULT: %s passed; %s failed" % [passed, failed])
	world.free()
	quit(1 if failed > 0 else 0)
