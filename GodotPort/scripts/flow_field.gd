extends RefCounted
## Shared integration fields, replacing obj_node instances and GM ds_grid.
const CELL := 32
const SIZE := Vector2i(64, 40)
const WORLD := Vector2(2048, 1280)
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
var terrain := PackedByteArray()
var blockers: Dictionary = {}
var cache: Dictionary = {}

func _init() -> void:
	terrain.resize(SIZE.x * SIZE.y)
	for y in range(8, 32):
		for x in range(29, 34):
			if y < 18 or y > 22:
				terrain[y * SIZE.x + x] = 1 # water; central land bridge
	for y in range(7, 13):
		for x in range(16, 20):
			terrain[y * SIZE.x + x] = 2 # impassable rock

func cell(point: Vector2) -> Vector2i:
	return Vector2i(clampi(int(point.x / CELL), 0, SIZE.x - 1), clampi(int(point.y / CELL), 0, SIZE.y - 1))

func center(tile: Vector2i) -> Vector2:
	return Vector2(tile * CELL) + Vector2.ONE * CELL * 0.5

func inside(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < SIZE.x and tile.y < SIZE.y

func passable(tile: Vector2i, layer: String = "land") -> bool:
	if not inside(tile):
		return false
	if layer == "air":
		return true
	if blockers.has(tile):
		return false
	var kind := terrain[tile.y * SIZE.x + tile.x]
	return kind != 2 and (layer == "amphibious" or (kind == 1 if layer == "water" else kind == 0))

func block_rect(rect: Rect2, blocked: bool) -> void:
	var start := cell(rect.position)
	var finish := cell(rect.end - Vector2.ONE)
	for y in range(start.y, finish.y + 1):
		for x in range(start.x, finish.x + 1):
			var tile := Vector2i(x, y)
			if blocked:
				blockers[tile] = int(blockers.get(tile, 0)) + 1
			elif blockers.has(tile):
				blockers[tile] -= 1
				if blockers[tile] <= 0:
					blockers.erase(tile)
	cache.clear()

func nearest_open(point: Vector2, layer: String = "land") -> Vector2i:
	var origin := cell(point)
	if passable(origin, layer):
		return origin
	for radius in range(1, maxi(SIZE.x, SIZE.y)):
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				if abs(x) != radius and abs(y) != radius:
					continue
				var tile := origin + Vector2i(x, y)
				if passable(tile, layer):
					return tile
	return Vector2i(-1, -1)

func request(point: Vector2, layer: String = "land") -> Dictionary:
	var target := nearest_open(point, layer)
	var key := "%s:%s" % [target, layer]
	if cache.has(key):
		return cache[key]
	var costs := PackedInt32Array()
	costs.resize(SIZE.x * SIZE.y)
	costs.fill(-1)
	if target.x < 0:
		return {"target": target, "costs": costs}
	var queue: Array[Vector2i] = [target]
	costs[target.y * SIZE.x + target.x] = 0
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for offset in DIRECTIONS:
			var next: Vector2i = current + offset
			if not passable(next, layer):
				continue
			var index := next.y * SIZE.x + next.x
			if costs[index] >= 0:
				continue
			costs[index] = costs[current.y * SIZE.x + current.x] + 1
			queue.append(next)
	var field := {"target": target, "costs": costs}
	if cache.size() >= 96:
		cache.clear()
	cache[key] = field
	return field

func direction(point: Vector2, destination: Vector2, layer: String) -> Vector2:
	if layer == "air":
		return point.direction_to(destination)
	var field := request(destination, layer)
	var tile := cell(point)
	var costs: PackedInt32Array = field.costs
	var best := tile
	var cost := costs[tile.y * SIZE.x + tile.x]
	if cost < 0:
		return Vector2.ZERO
	if cost == 0:
		return point.direction_to(center(field.target))
	for offset in DIRECTIONS:
		var next: Vector2i = tile + offset
		if inside(next):
			var value := costs[next.y * SIZE.x + next.x]
			if value >= 0 and value < cost:
				best = next
				cost = value
	return point.direction_to(center(best))
