extends Node2D
const Content = preload("res://scripts/content.gd")
const FlowField = preload("res://scripts/flow_field.gd")
const Fog = preload("res://scripts/fog.gd")
const Targeting = preload("res://scripts/targeting.gd")
const SignalBus = preload("res://scripts/signal_bus.gd")
const Unit = preload("res://scripts/unit.gd")
const Network = preload("res://scripts/network.gd")
const HUD = preload("res://scripts/hud.gd")
var content = Content.new()
var navigation = FlowField.new()
var fog = Fog.new()
var targeting = Targeting.new()
var bus = SignalBus.new()
var units: Array = []
var selected: Array = []
var players: Array = []
var next_id := 1
var local_player := 1
var game_time := 0.0
var paused := false
var show_fog := true
var show_flow := false
var show_grid := false
var ai_enabled := true
var ai_timer := 0.0
var fog_timer := 0.0
var camera: Camera2D
var network
var hud
var dragging := false
var drag_start := Vector2.ZERO
var drag_end := Vector2.ZERO
var build_mode := ""
var command_mode := ""
var groups: Dictionary = {}
var projectiles: Array[Dictionary] = []
var message := "Select infantry or an engineer to begin."
var message_time := 8.0
var outcome := ""
var sandbox := false
var command_log: Array[Dictionary] = []

func _ready() -> void:
	content.load_all()
	for issue in content.validate():
		push_error(issue)
	camera = Camera2D.new()
	camera.position = Vector2(540, 390)
	camera.zoom = Vector2.ONE
	add_child(camera)
	network = Network.new()
	network.name = "Network"
	network.world = self
	add_child(network)
	network.status_changed.connect(notify)
	hud = HUD.new()
	hud.world = self
	add_child(hud)
	start_match()
	var arguments := OS.get_cmdline_user_args()
	if "--host" in arguments:
		var error: Error = network.host()
		if error != OK:
			push_error("Host failed: " + error_string(error))
		elif "--network-test" in arguments:
			var ready_file := FileAccess.open("res://docs/network.ready", FileAccess.WRITE)
			if ready_file != null:
				ready_file.store_string("ready")
				ready_file.close()
	if "--join" in arguments:
		network.join("127.0.0.1")
	if "--network-test" in arguments:
		ai_enabled = false
		show_fog = false
		_network_probe("--join" in arguments)

func _network_probe(client: bool) -> void:
	if client:
		for attempt in range(40):
			if network.snapshots_received > 0:
				break
			await get_tree().create_timer(0.25).timeout
		if network.snapshots_received == 0:
			push_error("NETWORK TEST: no authoritative snapshot received")
			get_tree().quit(1)
			return
		var army: Array = units.filter(func(u): return u.owner_id == 2 and not u.is_structure() and not u.has_template("resource"))
		if army.is_empty():
			push_error("NETWORK TEST: no replicated player 2 units")
			get_tree().quit(1)
			return
		var probe_id: int = army[0].net_id
		var initial_position: Vector2 = army[0].position
		network.submit({"type": "move", "ids": [army[0].net_id], "x": 1500, "y": 800})
		await get_tree().create_timer(1.0).timeout
		var probe_unit = find_unit(probe_id)
		if probe_unit == null or probe_unit.position.distance_to(initial_position) < 5:
			push_error("NETWORK TEST: commanded movement was not replicated")
			get_tree().quit(1)
			return
		print("NETWORK CLIENT: authoritative movement replicated; snapshots=", network.snapshots_received)
	else:
		for attempt in range(480):
			if command_log.any(func(c): return c.player == 2 and c.command.type == "move"):
				break
			await get_tree().create_timer(0.25).timeout
		var accepted := command_log.any(func(c): return c.player == 2 and c.command.type == "move")
		print("NETWORK HOST: remote command accepted=", accepted)
		if not accepted:
			get_tree().quit(1)
			return
		await get_tree().create_timer(2.0).timeout
	get_tree().quit()

func start_match(single_unit: bool = false) -> void:
	for unit in units:
		unit.free()
	units.clear()
	selected.clear()
	groups.clear()
	projectiles.clear()
	command_log.clear()
	navigation = FlowField.new()
	fog = Fog.new()
	next_id = 1
	game_time = 0
	ai_timer = 0
	outcome = ""
	paused = false
	sandbox = single_unit
	players = [{"id": 0, "name": "Neutral", "credits": 0}, {"id": 1, "name": "Player 1", "credits": 350}, {"id": 2, "name": "Player 2", "credits": 350}]
	if single_unit:
		spawn("core.units.infantry", 1, Vector2(512, 384))
		camera.position = Vector2(512, 384)
	else:
		for side in [1, 2]:
			var base := Vector2(256, 288) if side == 1 else Vector2(1792, 992)
			spawn("core.structures.hq", side, base)
			for i in range(2):
				spawn("core.units.engineer", side, base + Vector2(96, 64 + i * 32) * (1 if side == 1 else -1))
			for i in range(5):
				spawn("core.units.infantry", side, base + Vector2(128 + (i % 3) * 32, -64 + (i / 3) * 32) * (1 if side == 1 else -1))
			spawn("core.resources.crystal", 0, base + Vector2(32, 160) * (1 if side == 1 else -1))
		spawn("core.resources.crystal", 0, Vector2(960, 640))
		spawn("core.resources.crystal", 0, Vector2(1184, 640))
		camera.position = Vector2(540, 390) if local_player == 1 else Vector2(1530, 950)
	refresh_services()
	notify("Skirmish ready. Right-click crystals with engineers to harvest." if not single_unit else "Original rm_test sandbox: one infantry, 10 HP.")

func spawn(id: String, player: int, point: Vector2, assigned_id: int = 0):
	if not content.definitions.has(id) or player < 0 or player >= players.size():
		return null
	var unit = Unit.new()
	unit.setup(self, id, player, point, next_id if assigned_id == 0 else assigned_id)
	next_id = maxi(next_id, unit.net_id + 1)
	units.append(unit)
	add_child(unit)
	if unit.is_structure():
		navigation.block_rect(Rect2(unit.position - Vector2.ONE * unit.radius, Vector2.ONE * unit.radius * 2), true)
	bus.send("unit_spawned", unit.net_id)
	return unit

func remove_unit(unit) -> void:
	if unit.is_structure():
		navigation.block_rect(Rect2(unit.position - Vector2.ONE * unit.radius, Vector2.ONE * unit.radius * 2), false)
	selected.erase(unit)
	units.erase(unit)
	bus.send("unit_destroyed", unit.net_id)
	unit.queue_free()
	if not sandbox and unit.definition_id == "core.structures.hq":
		outcome = "Player %s wins" % (2 if unit.owner_id == 1 else 1)
		notify(outcome + " · Restart from the menu to play again.")

func find_unit(id: int):
	for unit in units:
		if unit.net_id == id and not unit.dead:
			return unit
	return null

func player_color(id: int) -> Color:
	return [Color("62cce4"), Color("75debc"), Color("ef8f81")][clampi(id, 0, 2)]

func can_see(player: int, unit) -> bool:
	if unit.owner_id == player or not show_fog:
		return true
	if fog.state(player, unit.position) != 2:
		return false
	if unit.stats.get("cloaked", false):
		for detector in targeting.query(unit.position, 250):
			if detector.owner_id == player and detector.has_template("detector_cloak"):
				return true
		return false
	return true

func power(player: int) -> int:
	var total := 0
	for unit in units:
		if unit.owner_id == player and unit.construction >= 1:
			total += int(unit.stats.get("power", 0))
	return total

func meets_requirements(player: int, definition: Dictionary) -> bool:
	for requirement in definition.get("requires", []):
		if not units.any(func(u): return u.owner_id == player and u.definition_id == requirement and u.construction >= 1):
			return false
	return true

func refresh_services() -> void:
	targeting.rebuild(units)
	fog.update(units, players)

func _physics_process(delta: float) -> void:
	if not network.authority() or paused or not outcome.is_empty():
		return
	bus.reset()
	game_time += delta
	targeting.rebuild(units)
	for unit in units.duplicate():
		if is_instance_valid(unit) and not unit.dead:
			unit.simulate(delta)
	for i in range(projectiles.size() - 1, -1, -1):
		var shot: Dictionary = projectiles[i]
		var target = find_unit(int(shot.target))
		if target == null:
			projectiles.remove_at(i)
			continue
		var point := Vector2(shot.x, shot.y)
		point = point.move_toward(target.position, delta * 420)
		shot.x = point.x
		shot.y = point.y
		if point.distance_to(target.position) < target.radius + 4:
			var attacker = find_unit(int(shot.attacker))
			target.damage(float(shot.damage), attacker)
			projectiles.remove_at(i)
	fog_timer += delta
	if fog_timer >= 0.15:
		fog_timer = 0
		fog.update(units, players)
	if ai_enabled and not sandbox and (not network.active() or network.peers.is_empty()):
		tick_ai(delta)

func fire(attacker, target, amount: float) -> void:
	if power(attacker.owner_id) < 0 and attacker.is_structure():
		return
	projectiles.append({"x": attacker.position.x, "y": attacker.position.y, "target": target.net_id, "attacker": attacker.net_id, "damage": amount, "owner": attacker.owner_id})
	bus.send("weapon_fired", attacker.net_id)

func tick_ai(delta: float) -> void:
	ai_timer += delta
	if ai_timer < 4:
		return
	ai_timer = 0
	for unit in units:
		if unit.owner_id != 2:
			continue
		if unit.has_template("engineer") and unit.commands.is_empty():
			var deposits: Array = units.filter(func(u): return u.has_template("resource") and u.stock > 0)
			deposits.sort_custom(func(a, b): return unit.position.distance_squared_to(a.position) < unit.position.distance_squared_to(b.position))
			if not deposits.is_empty():
				unit.order({"type": "harvest", "target": deposits[0].net_id})
		if unit.has_template("constructor") and unit.production.size() < 2:
			unit.enqueue_product("core.units.infantry")
		if unit.has_template("weapon") and not unit.is_structure() and game_time > 50 and unit.commands.is_empty():
			unit.order({"type": "attack_move", "x": 256, "y": 288})

func _process(delta: float) -> void:
	message_time = maxf(0, message_time - delta)
	var direction := Vector2.ZERO
	if not hud.editing_text():
		direction = Vector2(float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)), float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
	camera.position += direction.normalized() * delta * 650 / camera.zoom.x
	camera.position = camera.position.clamp(Vector2.ZERO, navigation.WORLD)
	if dragging:
		drag_end = get_global_mouse_position()
	for unit in units:
		unit.queue_redraw()
	queue_redraw()
	hud.refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			camera.zoom = Vector2.ONE * clampf(camera.zoom.x * (1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.89), 0.45, 2.5)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not build_mode.is_empty():
					var point := navigation.center(navigation.cell(get_global_mouse_position()))
					network.submit({"type": "build", "ids": selected_ids(), "def": build_mode, "x": point.x, "y": point.y})
					build_mode = ""
				elif not command_mode.is_empty():
					issue_order(command_mode, get_global_mouse_position())
					command_mode = ""
				else:
					dragging = true
					drag_start = get_global_mouse_position()
					drag_end = drag_start
			elif dragging:
				dragging = false
				select_region(drag_start, get_global_mouse_position(), event.shift_pressed)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not build_mode.is_empty() or not command_mode.is_empty():
				build_mode = ""
				command_mode = ""
			else:
				issue_context(get_global_mouse_position(), event.shift_pressed)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		camera.position -= event.relative / camera.zoom
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var number: int = event.keycode - KEY_0
			if event.ctrl_pressed:
				groups[number] = selected_ids()
			else:
				set_selection(units.filter(func(u): return u.net_id in groups.get(number, []) and u.owner_id == local_player))
		match event.keycode:
			KEY_SPACE:
				network.submit({"type": "pause"})
			KEY_ESCAPE:
				build_mode = ""
				command_mode = ""
				set_selection([])
			KEY_X:
				issue_order("stop", Vector2.ZERO)
			KEY_H:
				issue_order("hold", Vector2.ZERO)
			KEY_P:
				command_mode = "patrol"
			KEY_F:
				command_mode = "attack_move"
			KEY_F5:
				save_game()
			KEY_F9:
				load_game()

func selected_ids() -> Array:
	return selected.filter(func(u): return is_instance_valid(u) and not u.dead).map(func(u): return u.net_id)

func set_selection(list: Array) -> void:
	for unit in units:
		unit.selected = unit in list
	selected = list

func select_region(start: Vector2, finish: Vector2, additive: bool = false) -> void:
	var result: Array = selected.duplicate() if additive else []
	if start.distance_to(finish) < 8:
		var unit = pick(finish, true)
		if unit != null:
			if additive and unit in result:
				result.erase(unit)
			else:
				result.append(unit)
	else:
		var rect := Rect2(start, finish - start).abs()
		for unit in units:
			if unit.owner_id == local_player and not unit.is_structure() and rect.has_point(unit.position) and not unit in result:
				result.append(unit)
	set_selection(result)

func pick(point: Vector2, friendly_only: bool = false):
	var nearest = null
	var distance := INF
	for unit in units:
		if unit.dead or not can_see(local_player, unit) or (friendly_only and unit.owner_id != local_player):
			continue
		var current: float = point.distance_to(unit.position)
		if current < unit.radius + 10 and current < distance:
			nearest = unit
			distance = current
	return nearest

func issue_context(point: Vector2, queued: bool) -> void:
	var target = pick(point)
	var type := "move"
	if target != null:
		if target.owner_id > 0 and target.owner_id != local_player:
			type = "attack"
		elif target.has_template("resource"):
			type = "harvest"
		elif target.owner_id == local_player and target.hp < target.hp_max:
			type = "repair"
	issue_order(type, point, target.net_id if target != null else 0, queued)

func issue_order(type: String, point: Vector2, target: int = 0, queued: bool = false) -> void:
	network.submit({"type": type, "ids": selected_ids(), "x": point.x, "y": point.y, "target": target, "queued": queued})

func apply_command(player: int, command: Dictionary) -> bool:
	if player < 1 or player >= players.size() or not command.get("type") is String:
		return false
	var type: String = command.type
	if type == "pause":
		if player != 1:
			return false
		paused = not paused
		return true
	if paused or not outcome.is_empty():
		return false
	var ids: Variant = command.get("ids", [])
	if not ids is Array or ids.size() > 512:
		return false
	var owned: Array = units.filter(func(u): return u.owner_id == player and u.net_id in ids and not u.dead)
	if owned.is_empty():
		return false
	var x: Variant = command.get("x", 0)
	var y: Variant = command.get("y", 0)
	if not (x is float or x is int) or not (y is float or y is int):
		return false
	var point := Vector2(float(x), float(y))
	if not point.is_finite() or point.x < 0 or point.y < 0 or point.x > navigation.WORLD.x or point.y > navigation.WORLD.y:
		return false
	if type == "train":
		var id: Variant = command.get("def", "")
		if not id is String:
			return false
		return owned[0].enqueue_product(id)
	if type == "build":
		return build_structure(player, owned, str(command.get("def", "")), point)
	if not type in ["move", "attack", "attack_move", "stop", "hold", "patrol", "harvest", "repair"]:
		return false
	var target = find_unit(int(command.get("target", 0)))
	if type in ["attack", "harvest", "repair"]:
		if target == null or not can_see(player, target):
			return false
		if type == "attack" and (target.owner_id == player or target.owner_id == 0):
			return false
		if type == "harvest" and not target.has_template("resource"):
			return false
		if type == "repair" and target.owner_id != player:
			return false
	var index := 0
	for unit in owned:
		if type in ["repair", "harvest"] and not unit.has_template("engineer"):
			continue
		if type == "attack" and not unit.has_template("weapon"):
			continue
		if unit.is_structure():
			if type == "move":
				unit.rally = point
			continue
		var order := command.duplicate(true)
		if type in ["move", "attack_move", "patrol"]:
			var offset := Vector2((index % 5) * 24, (index / 5) * 24)
			var destination := (point + offset).clamp(Vector2.ZERO, navigation.WORLD - Vector2.ONE)
			order.x = destination.x
			order.y = destination.y
			index += 1
		unit.order(order, bool(command.get("queued", false)))
	command_log.append({"time": game_time, "player": player, "command": command.duplicate(true)})
	return true

func can_place(id: String, point: Vector2) -> bool:
	if not content.definitions.has(id):
		return false
	var radius := float(content.definitions[id].get("radius", 24))
	if point.x < radius or point.y < radius or point.x > navigation.WORLD.x - radius or point.y > navigation.WORLD.y - radius:
		return false
	var start: Vector2i = navigation.cell(point - Vector2.ONE * radius)
	var finish: Vector2i = navigation.cell(point + Vector2.ONE * (radius - 1))
	for y in range(start.y, finish.y + 1):
		for x in range(start.x, finish.x + 1):
			if not navigation.passable(Vector2i(x, y)):
				return false
	for unit in units:
		if point.distance_to(unit.position) < radius + unit.radius + 6:
			return false
	return true

func build_structure(player: int, builders: Array, id: String, point: Vector2) -> bool:
	if not content.definitions.has(id) or not "structural" in content.definitions[id].templates:
		return false
	var eligible: Array = builders.filter(func(u): return u.has_template("engineer") and id in u.stats.get("builds", []) and u.position.distance_to(point) < 280)
	var definition: Dictionary = content.definitions[id]
	if eligible.is_empty() or not can_place(id, point) or fog.state(player, point) != 2 or not meets_requirements(player, definition):
		notify("Placement needs clear visible land within 280px of an engineer.")
		return false
	var cost := int(definition.get("cost", 0))
	if players[player].credits < cost:
		notify("Insufficient credits.")
		return false
	players[player].credits -= cost
	var structure = spawn(id, player, point)
	structure.construction = 0
	structure.hp = 1
	notify("Constructing " + str(definition.name))
	return true

func save_game() -> bool:
	if not network.authority() or network.active():
		notify("Save/load is available in offline games.")
		return false
	var file := FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file == null:
		notify("Unable to save.")
		return false
	file.store_string(JSON.stringify(serialize()))
	notify("Game saved · F9 to load")
	return true

func load_game() -> bool:
	if network.active() or not FileAccess.file_exists("user://savegame.json"):
		notify("No offline save available.")
		return false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://savegame.json"))
	if not data is Dictionary or int(data.get("version", 0)) != 1:
		notify("Invalid save file.")
		return false
	restore(data)
	notify("Game loaded")
	return true

func serialize() -> Dictionary:
	var explored := {}
	for player in fog.explored:
		explored[str(player)] = fog.explored[player].keys().map(func(v): return [v.x, v.y])
	return {"version": 1, "time": game_time, "players": players.duplicate(true), "units": units.map(func(u): return u.snapshot()), "next_id": next_id, "paused": paused, "sandbox": sandbox, "outcome": outcome, "explored": explored, "ai_enabled": ai_enabled, "ai_timer": ai_timer, "projectiles": projectiles.duplicate(true)}

func restore(data: Dictionary, replicated: bool = false) -> void:
	if not replicated:
		set_selection([])
		groups.clear()
	var keep: Array = []
	players.assign(data.players)
	for item in data.units:
		if not content.definitions.has(item.def):
			continue
		var unit = find_unit(int(item.id))
		if unit != null and (unit.definition_id != item.def or unit.owner_id != int(item.owner)):
			remove_unit(unit)
			unit = null
		if unit == null:
			unit = spawn(item.def, int(item.owner), Vector2(item.x, item.y), int(item.id))
		unit.restore(item)
		keep.append(unit)
	for unit in units.duplicate():
		if not unit in keep:
			remove_unit(unit)
	navigation.blockers.clear()
	navigation.cache.clear()
	for unit in units:
		if unit.is_structure():
			navigation.block_rect(Rect2(unit.position - Vector2.ONE * unit.radius, Vector2.ONE * unit.radius * 2), true)
	game_time = float(data.time)
	next_id = int(data.next_id)
	paused = bool(data.paused)
	sandbox = bool(data.sandbox)
	outcome = str(data.outcome)
	ai_enabled = bool(data.get("ai_enabled", true))
	ai_timer = float(data.get("ai_timer", 0))
	projectiles.assign(data.get("projectiles", []))
	fog.explored.clear()
	for player in data.get("explored", {}):
		var id := int(player)
		fog.explored[id] = {}
		for tile in data.explored[player]:
			fog.explored[id][Vector2i(int(tile[0]), int(tile[1]))] = true
	refresh_services()

func notify(text: String) -> void:
	message = text
	message_time = 7

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, navigation.WORLD), Color("233a34"))
	for y in range(navigation.SIZE.y):
		for x in range(navigation.SIZE.x):
			var tile := Vector2i(x, y)
			var rect := Rect2(Vector2(tile * 32), Vector2.ONE * 32)
			var kind: int = navigation.terrain[y * navigation.SIZE.x + x]
			if kind == 1:
				draw_rect(rect, Color("264d66"))
			elif kind == 2:
				draw_rect(rect.grow(-2), Color("626b63"))
			elif (x * 13 + y * 7) % 11 < 3:
				draw_rect(rect, Color("273f36"))
			if show_grid:
				draw_rect(rect, Color(0.5, 0.7, 0.6, 0.12), false)
			if show_fog:
				var state: int = fog.state(local_player, rect.get_center())
				if state < 2:
					draw_rect(rect, Color(0.015, 0.025, 0.035, 0.97 if state == 0 else 0.65))
	if show_flow:
		var destination := get_global_mouse_position()
		var field: Dictionary = navigation.request(destination)
		for y in range(navigation.SIZE.y):
			for x in range(navigation.SIZE.x):
				var point: Vector2 = navigation.center(Vector2i(x, y))
				var direction: Vector2 = navigation.direction(point, navigation.center(field.target), "land")
				if direction != Vector2.ZERO:
					draw_line(point, point + direction * 11, Color(0.5, 0.9, 0.7, 0.4), 1)
	for shot in projectiles:
		var point := Vector2(shot.x, shot.y)
		if not show_fog or fog.state(local_player, point) == 2:
			draw_circle(point, 3, Color("ffe6a2"))
	if dragging:
		var rect := Rect2(drag_start, drag_end - drag_start).abs()
		draw_rect(rect, Color(0.5, 1, 0.75, 0.08))
		draw_rect(rect, Color("83f7be"), false, 1 / camera.zoom.x)
	if not build_mode.is_empty():
		var point: Vector2 = navigation.center(navigation.cell(get_global_mouse_position()))
		var radius := float(content.definitions[build_mode].get("radius", 24))
		draw_rect(Rect2(point - Vector2.ONE * radius, Vector2.ONE * radius * 2), Color(0.4, 1, 0.7, 0.5) if can_place(build_mode, point) else Color(1, 0.3, 0.3, 0.5))
