extends RefCounted
## Declarations describe actions; the world command boundary authorizes execution.
const CORE := {
	"move": {"label": "Move", "target": "point", "mobile": true},
	"stop": {"label": "Stop", "target": "none", "key": KEY_X},
	"hold": {"label": "Hold", "target": "none", "key": KEY_H},
	"attack_move": {"label": "Attack-move", "target": "point", "template": "weapon", "mobile": true, "key": KEY_F},
	"patrol": {"label": "Patrol", "target": "point", "mobile": true, "key": KEY_P},
	"attack": {"label": "Attack", "target": "unit", "template": "weapon"},
	"harvest": {"label": "Harvest", "target": "unit", "template": "engineer"},
	"repair": {"label": "Repair", "target": "unit", "template": "engineer"}
}

static func declarations(unit) -> Dictionary:
	var result := {}
	for id in CORE:
		var declaration: Dictionary = CORE[id]
		if declaration.get("mobile", false) and (unit.is_structure() or float(unit.stats.get("speed", 0)) <= 0):
			continue
		if declaration.has("template") and not unit.has_template(declaration.template):
			continue
		if unit.has_template("resource"):
			continue
		result[id] = declaration.duplicate(true)
	# Custom aliases reuse supported executors, with declared cost and cooldown.
	for id in unit.stats.get("abilities", {}):
		var config: Dictionary = unit.stats.abilities[id]
		var executor: String = config.get("command", id)
		if not result.has(executor):
			continue
		var declaration: Dictionary = result[executor].duplicate(true)
		declaration.merge(config, true)
		result[id] = declaration
	return result

static func available(unit, id: String) -> String:
	var declared := declarations(unit)
	if not declared.has(id):
		return "unavailable"
	if unit.dead or unit.construction < 1:
		return "unavailable"
	if float(unit.ability_cooldowns.get(id, 0)) > 0:
		return "cooldown"
	if unit.world.players[unit.owner_id].credits < int(declared[id].get("cost", 0)):
		return "insufficient_funds"
	return "accepted"
