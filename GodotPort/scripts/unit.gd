extends Node2D
const Trait = preload("res://scripts/trait.gd")
const Steering = preload("res://scripts/steering.gd")
var world
var net_id := 0
var owner_id := 1
var definition_id := ""
var stats: Dictionary = {}
var templates: Dictionary = {}
var categories: Array = []
var hp := 10.0
var hp_max := 10.0
var shield := 0.0
var shield_max := 0.0
var experience := 0
var selected := false
var dead := false
var velocity := Vector2.ZERO
var radius := 10.0
var commands: Array[Dictionary] = []
var state := "idle"
var cooldown := 0.0
var since_hit := 100.0
var target_id := 0
var cargo := 0.0
var stock := 0.0
var production: Array[Dictionary] = []
var rally := Vector2.ZERO
var construction := 1.0
var patrol_origin := Vector2.ZERO
var sprite: Texture2D

func setup(game, id: String, player: int, point: Vector2, network_id: int) -> void:
	world = game
	net_id = network_id
	definition_id = id
	owner_id = player
	position = point
	rally = point + Vector2(90, 60)
	stats = world.content.definitions[id].duplicate(true)
	radius = float(stats.get("radius", 10))
	stock = float(stats.get("stock", 0))
	for template_id in stats.get("templates", []):
		add_template(template_id)
	sprite = world.content.images.get(stats.get("image", ""))
	if sprite == null:
		sprite = load("res://assets/spr_unit_0.png")

func add_template(id: String) -> bool:
	if templates.has(id) or not world.content.templates.has(id):
		return false
	for requirement in world.content.templates[id].requires:
		add_template(requirement)
	var template := Trait.new(id, self)
	templates[id] = template
	template.attach()
	return true

func remove_template(id: String) -> bool:
	if not templates.has(id):
		return false
	for other in templates:
		if id in world.content.templates[other].requires:
			return false
	templates[id].detach()
	templates.erase(id)
	return true

func has_template(id: String) -> bool:
	return templates.has(id)

func is_structure() -> bool:
	return has_template("structural")

func movement_layer() -> String:
	if has_template("aerial") or has_template("orbital"):
		return "air"
	if has_template("amphibial"):
		return "amphibious"
	return "water" if has_template("naval") else "land"

func order(command: Dictionary, queued: bool = false) -> void:
	if not queued:
		commands.clear()
		target_id = 0
	if command.type in ["stop", "hold"]:
		state = command.type
		velocity = Vector2.ZERO
		return
	state = "ordered"
	if command.type == "patrol":
		command["origin"] = [position.x, position.y]
	commands.append(command.duplicate(true))

func simulate(delta: float) -> void:
	if dead:
		return
	since_hit += delta
	cooldown = maxf(0, cooldown - delta)
	for template in templates.values():
		if construction >= 1.0 or template.id in ["health", "construction"]:
			template.tick(delta)
	if construction < 1.0:
		return
	if is_structure() or float(stats.get("speed", 0)) <= 0:
		return
	velocity = Vector2.ZERO
	if commands.is_empty():
		if state != "hold":
			state = "idle"
		if stats.get("flock", false):
			var neighbors: Array = world.targeting.query(position, 100)
			var direction: Vector2 = Steering.wander(net_id * 0.7, world.game_time) + Steering.cohesion(self, neighbors) * 0.4 + Steering.separation(self, neighbors) * 2
			move_direction(direction.normalized(), delta)
	else:
		var command: Dictionary = commands[0]
		state = command.type
		var destination := Vector2(float(command.get("x", position.x)), float(command.get("y", position.y)))
		if command.type in ["attack", "repair", "harvest"]:
			var target = world.find_unit(int(command.get("target", 0)))
			if target == null or target.dead:
				commands.pop_front()
				return
			destination = target.position
			if command.type == "attack":
				if not world.can_see(owner_id, target):
					commands.pop_front()
					target_id = 0
					return
				target_id = target.net_id
				if position.distance_to(destination) <= float(stats.get("range", 100)):
					return
			else:
				if position.distance_to(destination) <= radius + target.radius + 22:
					return
		var goal: Vector2i = world.navigation.nearest_open(destination, movement_layer())
		if goal.x < 0:
			commands.pop_front()
			return
		var resolved: Vector2 = world.navigation.center(goal)
		if position.distance_to(resolved) < 15:
			if command.type == "patrol":
				var old := [command.x, command.y]
				command.x = command.origin[0]
				command.y = command.origin[1]
				command.origin = old
			else:
				commands.pop_front()
		else:
			var direction: Vector2 = world.navigation.direction(position, resolved, movement_layer())
			move_direction(direction, delta)

func move_direction(direction: Vector2, delta: float) -> void:
	var separation: Vector2 = Steering.separation(self, world.targeting.query(position, 65))
	var speed := float(stats.get("speed", 70))
	velocity = (direction + separation * 1.5).limit_length() * speed
	var next := position + velocity * delta
	if world.navigation.passable(world.navigation.cell(next), movement_layer()):
		position = next.clamp(Vector2.ONE * radius, world.navigation.WORLD - Vector2.ONE * radius)
	else:
		# Slide along obstacles instead of moving through blocked cells.
		for slide in [Vector2(next.x, position.y), Vector2(position.x, next.y)]:
			if world.navigation.passable(world.navigation.cell(slide), movement_layer()):
				position = slide
	if velocity.length_squared() > 1:
		rotation = velocity.angle()

func tick_weapon(_delta: float) -> void:
	if not commands.is_empty() and commands[0].type not in ["attack", "attack_move", "patrol"]:
		return
	var target = world.find_unit(target_id)
	var attack_range := float(stats.get("range", 140))
	if target == null or target.dead or target.owner_id == owner_id or not world.can_see(owner_id, target) or position.distance_to(target.position) > attack_range:
		target = null
		for candidate in world.targeting.query(position, attack_range):
			if candidate.owner_id > 0 and candidate.owner_id != owner_id and world.can_see(owner_id, candidate):
				if target == null or position.distance_squared_to(candidate.position) < position.distance_squared_to(target.position):
					target = candidate
	if target == null:
		return
	target_id = target.net_id
	if cooldown <= 0:
		cooldown = float(stats.get("cooldown", 0.8))
		world.fire(self, target, float(stats.get("damage", 2)) * (1 + mini(experience, 10) * 0.05))

func damage(amount: float, attacker = null) -> void:
	if dead or not has_template("health"):
		return
	since_hit = 0
	amount = maxf(0.1, amount - float(stats.get("armor", 0)))
	var absorbed := minf(shield, amount)
	shield -= absorbed
	hp -= amount - absorbed
	world.bus.send("unit_damaged", {"id": net_id, "hp": hp})
	if hp <= 0:
		dead = true
		if attacker != null and is_instance_valid(attacker):
			for template in attacker.templates.values():
				template.event("kill", self)
		world.remove_unit(self)

func tick_engineer(delta: float) -> void:
	if commands.is_empty():
		return
	var command: Dictionary = commands[0]
	var target = world.find_unit(int(command.get("target", 0)))
	if target == null or target.dead:
		return
	if position.distance_to(target.position) > radius + target.radius + 22:
		return
	if command.type == "repair" and target.owner_id == owner_id:
		target.hp = minf(target.hp_max, target.hp + delta * 6)
		if target.hp >= target.hp_max:
			commands.pop_front()
	if command.type == "harvest" and target.has_template("resource"):
		var amount := minf(target.stock, delta * 6)
		cargo += amount
		target.stock -= amount
		if cargo >= 10 or target.stock <= 0:
			world.players[owner_id].credits += int(cargo)
			cargo = 0
			world.bus.send("resources_changed", owner_id)
		if target.stock <= 0:
			commands.pop_front()

func enqueue_product(id: String) -> bool:
	if not has_template("constructor") or construction < 1 or not id in stats.get("products", []) or production.size() >= 8:
		return false
	var definition: Dictionary = world.content.definitions.get(id, {})
	if definition.is_empty() or not world.meets_requirements(owner_id, definition):
		return false
	var cost := int(definition.get("cost", 0))
	if world.players[owner_id].credits < cost:
		return false
	world.players[owner_id].credits -= cost
	production.append({"id": id, "remaining": float(definition.get("build_time", 3)), "cost": cost})
	return true

func tick_production(delta: float) -> void:
	if production.is_empty() or world.power(owner_id) < 0:
		return
	production[0].remaining -= delta
	if production[0].remaining <= 0:
		var definition: String = production[0].id
		var point: Vector2 = position + Vector2(radius + 40, 0)
		var layer := "air" if "aerial" in world.content.definitions[definition].templates else "land"
		var tile: Vector2i = world.navigation.nearest_open(point, layer)
		if tile.x < 0:
			return
		var unit = world.spawn(definition, owner_id, world.navigation.center(tile))
		production.pop_front()
		unit.order({"type": "move", "x": rally.x, "y": rally.y})

func snapshot() -> Dictionary:
	return {"id": net_id, "def": definition_id, "owner": owner_id, "x": position.x, "y": position.y, "hp": hp, "shield": shield, "xp": experience, "construction": construction, "stock": stock, "commands": commands, "state": state, "production": production, "rally": [rally.x, rally.y], "rotation": rotation, "cargo": cargo, "cooldown": cooldown}

func restore(data: Dictionary) -> void:
	position = Vector2(data.x, data.y)
	hp = float(data.hp)
	shield = float(data.get("shield", 0))
	experience = int(data.get("xp", 0))
	construction = float(data.get("construction", 1))
	stock = float(data.get("stock", 0))
	commands.assign(data.get("commands", []))
	production.assign(data.get("production", []))
	state = data.get("state", "idle")
	rally = Vector2(data.get("rally", [position.x, position.y])[0], data.get("rally", [position.x, position.y])[1])
	rotation = float(data.get("rotation", 0))
	cargo = float(data.get("cargo", 0))
	cooldown = float(data.get("cooldown", 0))

func _draw() -> void:
	if dead or world == null or not world.can_see(world.local_player, self):
		return
	var color: Color = world.player_color(owner_id)
	if selected:
		draw_arc(Vector2.ZERO, radius + 5, 0, TAU, 32, Color("83f7be"), 2)
	if has_template("resource"):
		draw_colored_polygon(PackedVector2Array([Vector2(-14, 4), Vector2(-7, -15), Vector2(5, -7), Vector2(13, -16), Vector2(18, 12)]), Color("62cce4"))
	elif is_structure():
		draw_rect(Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2), color.darkened(0.5))
		draw_rect(Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2), color, false, 2)
		draw_circle(Vector2.ZERO, radius * 0.45, color.lightened(0.2))
	else:
		draw_circle(Vector2(1, 3), radius, Color(0, 0, 0, 0.35))
		if sprite != null:
			draw_texture_rect(sprite, Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2), false, color)
		else:
			draw_circle(Vector2.ZERO, radius, color)
		draw_line(Vector2.ZERO, Vector2(radius + 5, 0), color, 2)
	if has_template("health") and (hp < hp_max or selected or construction < 1):
		var bar := Rect2(Vector2(-radius, -radius - 10), Vector2(radius * 2, 3))
		draw_set_transform(Vector2.ZERO, -rotation)
		draw_rect(bar, Color("222b35"))
		bar.size.x *= clampf(hp / hp_max, 0, 1)
		draw_rect(bar, Color("79dfa2"))
		if shield_max > 0:
			draw_line(Vector2(-radius, -radius - 13), Vector2(-radius + radius * 2 * shield / shield_max, -radius - 13), Color("8cacff"), 2)
