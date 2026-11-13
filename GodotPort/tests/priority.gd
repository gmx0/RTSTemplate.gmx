extends SceneTree
var world
var passed := 0
var failed := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)

func run() -> void:
	world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	await process_frame
	world.set_physics_process(false)
	world.set_process(false)
	world.ai_enabled = false
	var soldier = world.units.filter(func(u): return u.owner_id == 1 and u.has_template("weapon") and not u.is_structure())[0]
	var enemy = world.units.filter(func(u): return u.owner_id == 2 and not u.is_structure())[0]
	var hq = world.units.filter(func(u): return u.owner_id == 1 and u.has_template("constructor"))[0]
	var credits: int = world.players[1].credits
	check(world.execute_command(1, {"type": "move", "ids": [soldier.net_id, enemy.net_id]}).code == "invalid_source" and soldier.commands.is_empty(), "mixed foreign source command rejects before any mutation")
	check(world.execute_command(1, {"type": "harvest", "ids": [soldier.net_id]}).code == "unavailable", "unsupported action does not report success")
	world.paused = true
	check(world.execute_command(1, {"type": "stop", "ids": [soldier.net_id]}).code == "locked", "paused command has stable rejection code")
	world.paused = false
	soldier.stats.abilities = {"advance": {"command": "move", "label": "Advance", "cost": 7, "cooldown": 3, "key": KEY_G}}
	world.set_selection([soldier])
	world.hud.refresh()
	check(world.hud.actions.get_children().any(func(w): return w.get_meta("ability", "") == "advance"), "custom declared ability generates a button")
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_G
	world._unhandled_input(key)
	check(world.command_mode == "advance", "custom declared hotkey arms its targeting mode")
	world.command_mode = ""
	check(world.execute_command(1, {"type": "advance", "ids": [soldier.net_id], "x": 500, "y": 300}).code == "accepted" and soldier.commands[0].type == "move", "declared alias uses the shared movement executor")
	check(world.players[1].credits == credits - 7, "ability charges declared cost once")
	check(world.execute_command(1, {"type": "advance", "ids": [soldier.net_id]}).code == "cooldown" and world.players[1].credits == credits - 7, "cooldown rejection does not charge again")
	var saved: Dictionary = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	soldier = world.find_unit(soldier.net_id)
	check(float(soldier.ability_cooldowns.advance) == 3, "ability cooldown survives JSON save/network snapshot")
	soldier.simulate(1)
	check(float(soldier.ability_cooldowns.advance) == 2, "ability cooldown uses simulation delta")
	world.players[1].credits = 1000
	var before: int = world.players[1].credits
	hq.production.clear()
	check(world.execute_command(1, {"type": "train", "ids": [hq.net_id], "def": "core.units.infantry"}).code == "accepted", "production enters through shared admission")
	check(world.execute_command(1, {"type": "cancel_production", "ids": [hq.net_id]}).code == "accepted" and world.players[1].credits == before, "cancellation refunds the exact paid cost")
	check(world.execute_command(1, {"type": "cancel_production", "ids": [hq.net_id]}).code == "unavailable" and world.players[1].credits == before, "repeated cancellation cannot refund twice")
	hq.stats.queue_limit = 1
	hq.enqueue_product("core.units.infantry")
	check(world.execute_command(1, {"type": "train", "ids": [hq.net_id], "def": "core.units.infantry"}).code == "queue_full", "full queue has an explicit rejection result")
	hq.stats.queue_limit = 8
	hq.stats.power = -100
	var remaining: float = hq.production[0].remaining
	hq.tick_production(2)
	check(hq.production_status == "no_power" and hq.production[0].remaining == remaining, "power deficit pauses without losing progress")
	hq.stats.power = 20
	world.content.definitions["core.units.infantry"].requires = ["core.structures.radar"]
	hq.tick_production(2)
	check(hq.production_status == "prerequisite" and hq.production[0].remaining == remaining, "lost prerequisite pauses paid work")
	world.content.definitions["core.units.infantry"].erase("requires")
	var terrain: PackedByteArray = world.navigation.terrain.duplicate()
	world.navigation.terrain.fill(2)
	hq.tick_production(10)
	check(hq.production_status == "exit_blocked" and hq.production.size() == 1 and hq.production[0].remaining == 0, "blocked local exits retain completed product without teleporting")
	saved = world.serialize()
	world.restore(JSON.parse_string(JSON.stringify(saved)))
	hq = world.find_unit(hq.net_id)
	check(hq.production[0].remaining == 0 and hq.production_status == "exit_blocked", "blocked production state survives snapshot")
	world.navigation.terrain = terrain
	var count: int = world.units.size()
	hq.tick_production(0)
	check(hq.production.is_empty() and world.units.size() == count + 1, "clearing an exit spawns exactly one completed product")
	world.show_fog = false
	check(not world.entity_disclosed(1, enemy), "debug fog rendering grants no gameplay disclosure")
	check(world.execute_command(1, {"type": "attack", "ids": [soldier.net_id], "target": enemy.net_id}).code == "invalid_target", "debug fog toggle cannot authorize hidden attacks")
	enemy.position = soldier.position + Vector2(60, 0)
	enemy.stats.cloaked = true
	check(world.point_visible(1, enemy.position) and not world.entity_disclosed(1, enemy), "current sight does not bypass cloak")
	var detector = world.spawn("core.structures.radar", 1, soldier.position + Vector2(0, 100))
	check(world.entity_disclosed(1, enemy), "compatible powered detector discloses cloak in current sight")
	detector.stats.power = -100
	check(not world.entity_disclosed(1, enemy), "unpowered detector cannot disclose cloak")
	soldier.stats.cloaked = true
	enemy.revealed_until["1"] = world.game_time + 2
	check(world.entity_disclosed(1, enemy) and not world.entity_disclosed(2, soldier), "Reveal is participant-relative")
	enemy.revealed_until["1"] = world.game_time
	check(not world.entity_disclosed(1, enemy), "Reveal expiry restores cloak admission")
	world.start_match()
	world.ai_enabled = false
	var observation: Dictionary = world.ai_policy.observe(world, 2)
	check(observation.contacts.is_empty(), "AI observation excludes undisclosed opponents")
	var prior: Dictionary = world.serialize()
	var candidates: Array = world.ai_policy.evaluate(world, 2, observation)
	check(JSON.stringify(prior) == JSON.stringify(world.serialize()), "AI evaluation is read-only")
	world.ai_policy.execute(world, 2, candidates)
	check(world.command_log.any(func(c): return c.player == 2 and c.command.type == "harvest") and world.command_log.any(func(c): return c.player == 2 and c.command.type == "train"), "AI economy and production use logged shared commands")
	check(world.ai_policy.results.all(func(r): return r.has("code")), "AI records canonical command results")
	print("RESULT: %s passed; %s failed" % [passed, failed])
	world.free()
	quit(1 if failed > 0 else 0)
