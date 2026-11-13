extends RefCounted
## Small match-owned objective declarations and accumulated match facts.
var rules: Array = []
var losses: Dictionary = {}
var earned: Dictionary = {}

func reset(config: Array = []) -> void:
	rules = config.duplicate(true)
	if rules.is_empty():
		rules = [{"type": "destroy", "definition": "core.structures.hq"}]
	losses.clear()
	earned.clear()

func destroyed(unit) -> void:
	var key := str(unit.owner_id)
	losses[key] = int(losses.get(key, 0)) + 1

func income(player: int, amount: int) -> void:
	var key := str(player)
	earned[key] = int(earned.get(key, 0)) + amount

func evaluate(world) -> String:
	var winners: Array = []
	for player in [1, 2]:
		var complete := true
		for rule in rules:
			match str(rule.type):
				"destroy":
					if world.units.any(func(u): return not u.dead and u.owner_id == 3 - player and u.definition_id == rule.definition):
						complete = false
				"earn":
					if int(earned.get(str(player), 0)) < int(rule.amount):
						complete = false
				"survive":
					if world.game_time < float(rule.seconds) or not world.units.any(func(u): return not u.dead and u.owner_id == player and u.has_template("health")):
						complete = false
				_:
					complete = false
		if complete:
			winners.append(player)
	if winners.size() == 2:
		return "Draw"
	return "Player %s wins" % winners[0] if winners.size() == 1 else ""

func summary() -> String:
	var parts: Array[String] = []
	for rule in rules:
		match str(rule.type):
			"destroy": parts.append("Destroy opposing " + str(rule.definition).get_slice(".", 2))
			"earn": parts.append("Earn %s credits (P1 %s / P2 %s)" % [rule.amount, earned.get("1", 0), earned.get("2", 0)])
			"survive": parts.append("Survive %ss" % rule.seconds)
	return "; ".join(parts)

func snapshot() -> Dictionary:
	return {"rules": rules.duplicate(true), "losses": losses.duplicate(true), "earned": earned.duplicate(true)}

func restore(data: Dictionary) -> void:
	reset(data.get("rules", []))
	losses = data.get("losses", {}).duplicate(true)
	earned = data.get("earned", {}).duplicate(true)
