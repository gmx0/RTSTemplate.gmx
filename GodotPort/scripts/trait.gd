extends RefCounted
## Runtime attachable templates. Marker templates retain targeting membership.
var id: String
var entity
var timer := 0.0

func _init(template_id: String, owner_entity) -> void:
	id = template_id
	entity = owner_entity

func attach() -> void:
	if id in ["bipedal", "aerial", "amphibial", "naval", "structural", "terrestrial", "orbital", "netheral"]:
		entity.categories.append(id.capitalize())
	if id == "health":
		entity.hp_max = float(entity.stats.get("hp", 100))
		entity.hp = entity.hp_max
	if id == "shield":
		entity.shield_max = float(entity.stats.get("shield", 10))
		entity.shield = entity.shield_max

func detach() -> void:
	entity.categories.erase(id.capitalize())

func tick(delta: float) -> void:
	timer += delta
	match id:
		"health_regen":
			if entity.since_hit > 3:
				entity.hp = minf(entity.hp_max, entity.hp + float(entity.stats.get("regen", 1)) * delta)
		"shield":
			if entity.since_hit > 4:
				entity.shield = minf(entity.shield_max, entity.shield + delta * 2)
		"weapon":
			entity.tick_weapon(delta)
		"constructor":
			entity.tick_production(delta)
		"engineer":
			entity.tick_engineer(delta)
		"construction":
			if entity.construction < 1.0:
				entity.construction = minf(1.0, entity.construction + delta / float(entity.stats.get("build_time", 8)))
				entity.hp = maxf(entity.hp, entity.hp_max * entity.construction)
		"radar":
			if timer >= 0.5 and entity.world.power(entity.owner_id) >= 0:
				timer = 0
				entity.world.fog.reveal(entity.owner_id, entity.position, float(entity.stats.get("radar_range", 400)))

func event(name: String, payload: Variant = null) -> void:
	if id == "veterancy" and name == "kill":
		entity.experience += 1
		entity.world.bus.send("veterancy", {"id": entity.net_id, "xp": entity.experience})
	if id == "mindcontrol" and name == "capture" and payload is int:
		entity.owner_id = payload
