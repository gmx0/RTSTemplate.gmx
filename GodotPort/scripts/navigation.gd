extends RefCounted
## Shared reverse breadth-first flowfields, cached by goal/layer/revision.
const CELL := 32
const COLS := 80
const ROWS := 60
const DIRS := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
var blocked: Dictionary = {}
var water: Dictionary = {}
var cache: Dictionary = {}
var revision := 0

func cell(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / CELL), 0, COLS - 1), clampi(int(p.y / CELL), 0, ROWS - 1))

func center(c: Vector2i) -> Vector2:
	return Vector2(c * CELL) + Vector2.ONE * CELL * 0.5

func valid(c: Vector2i, layer: String = "land") -> bool:
	if c.x < 0 or c.y < 0 or c.x >= COLS or c.y >= ROWS:
		return false
	if layer == "air":
		return true
	if blocked.has(c):
		return false
	if layer == "sea":
		return water.has(c)
	return layer == "amphibious" or not water.has(c)

func invalidate() -> void:
	revision += 1
	cache.clear()

func nearest(c: Vector2i, layer: String = "land") -> Vector2i:
	if valid(c, layer):
		return c
	for r in range(1, 80):
		for x in range(-r, r + 1):
			for y in [-r, r]:
				if valid(c + Vector2i(x,y), layer):
					return c + Vector2i(x,y)
		for y in range(-r + 1, r):
			for x in [-r, r]:
				if valid(c + Vector2i(x,y), layer):
					return c + Vector2i(x,y)
	return Vector2i(-1,-1)

func field(goal: Vector2, layer: String = "land") -> Dictionary:
	var target := nearest(cell(goal), layer)
	var key := str(target) + layer
	if cache.has(key):
		return cache[key]
	var costs := {target: 0}
	var queue: Array[Vector2i] = [target]
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for offset in DIRS:
			var next: Vector2i = current + offset
			if valid(next, layer) and not costs.has(next):
				costs[next] = int(costs[current]) + 1
				queue.append(next)
	if cache.size() >= 128:
		cache.clear()
	cache[key] = costs
	return costs

func direction(p: Vector2, goal: Vector2, layer: String = "land") -> Vector2:
	if layer == "air":
		return p.direction_to(goal)
	var costs := field(goal, layer)
	var c := cell(p)
	if not costs.has(c):
		return Vector2.ZERO
	var best := c
	var distance: int = costs[c]
	for offset in DIRS:
		var neighbor: Vector2i = c + offset
		if costs.get(neighbor, 999999) < distance:
			best = neighbor
			distance = costs[neighbor]
	if best == c:
		return p.direction_to(center(c)) if not valid(cell(goal), layer) else p.direction_to(goal)
	return p.direction_to(center(best))
