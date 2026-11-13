extends RefCounted
## Observe -> rank -> submit. Never mutates units or bypasses command admission.
var results: Array = []

func observe(world, player: int) -> Dictionary:
	return {
		"owned": world.units.filter(func(u): return not u.dead and u.host_id == 0 and u.owner_id == player),
		"contacts": world.units.filter(func(u): return u.owner_id > 0 and u.owner_id != player and world.entity_disclosed(player, u)),
		"resources": world.units.filter(func(u): return u.has_template("resource") and u.stock > 0 and world.entity_disclosed(player, u))
	}

func evaluate(world, player: int, observation: Dictionary) -> Array:
	var candidates: Array = []
	for unit in observation.owned:
		if unit.construction < 1:
			continue
		if unit.has_template("engineer") and unit.commands.is_empty():
			var deposits: Array = observation.resources.duplicate()
			deposits.sort_custom(func(a, b): return unit.position.distance_squared_to(a.position) < unit.position.distance_squared_to(b.position))
			if not deposits.is_empty():
				candidates.append({"score": 100, "lane": "economy", "command": {"type": "harvest", "ids": [unit.net_id], "target": deposits[0].net_id}})
		if unit.has_template("constructor") and unit.production.size() < 2:
			for product in unit.stats.get("products", []):
				if not world.content.definitions[product].templates.has("weapon"):
					continue
				candidates.append({"score": 60, "lane": "production", "command": {"type": "train", "ids": [unit.net_id], "def": product}})
		if not unit.has_template("weapon") or unit.is_structure() or not unit.commands.is_empty():
			continue
		var contacts: Array = observation.contacts.duplicate()
		contacts.sort_custom(func(a, b): return unit.position.distance_squared_to(a.position) < unit.position.distance_squared_to(b.position))
		if not contacts.is_empty():
			candidates.append({"score": 90, "lane": "combat:%s" % unit.net_id, "command": {"type": "attack", "ids": [unit.net_id], "target": contacts[0].net_id}})
		elif world.game_time >= 50:
			# Fixed map scouting destinations carry no hidden enemy identity/position.
			var point := Vector2(256, 288) if player == 2 else Vector2(1792, 992)
			candidates.append({"score": 20, "lane": "combat:%s" % unit.net_id, "command": {"type": "attack_move", "ids": [unit.net_id], "x": point.x, "y": point.y}})
	candidates.sort_custom(func(a, b): return a.score > b.score)
	return candidates

func execute(world, player: int, candidates: Array) -> void:
	results.clear()
	var completed := {}
	for candidate in candidates:
		if completed.has(candidate.lane):
			continue
		var result: Dictionary = world.execute_command(player, candidate.command)
		results.append({"lane": candidate.lane, "code": result.code})
		if result.code == "accepted":
			completed[candidate.lane] = true

func think(world, player: int) -> void:
	execute(world, player, evaluate(world, player, observe(world, player)))
