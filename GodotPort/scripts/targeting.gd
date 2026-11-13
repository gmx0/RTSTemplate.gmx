extends RefCounted
## Named targeting lists plus spatial buckets. Rebuilt after each simulation tick.
var categories: Dictionary = {}
var buckets: Dictionary = {}
const BUCKET := 128.0

func rebuild(units: Array) -> void:
	categories.clear()
	buckets.clear()
	for unit in units:
		if not is_instance_valid(unit) or unit.dead or unit.host_id != 0:
			continue
		var key := Vector2i(unit.position / BUCKET)
		if not buckets.has(key):
			buckets[key] = []
		buckets[key].append(unit)
		for tag in unit.categories + ["Player %s" % unit.owner_id]:
			if not categories.has(tag):
				categories[tag] = []
			categories[tag].append(unit)

func query(point: Vector2, radius: float, category: String = "") -> Array:
	var found: Array = []
	var start := Vector2i((point - Vector2.ONE * radius) / BUCKET) - Vector2i.ONE
	var finish := Vector2i((point + Vector2.ONE * radius) / BUCKET) + Vector2i.ONE
	for y in range(start.y, finish.y + 1):
		for x in range(start.x, finish.x + 1):
			for unit in buckets.get(Vector2i(x, y), []):
				if is_instance_valid(unit) and not unit.dead and unit.host_id == 0 and point.distance_to(unit.position) <= radius:
					if category.is_empty() or unit in categories.get(category, []):
						found.append(unit)
	return found
