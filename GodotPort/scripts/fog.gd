extends RefCounted
const CELL := 32
const SIZE := Vector2i(64, 40)
var explored: Dictionary = {}
var visible: Dictionary = {}

func update(units: Array, players: Array) -> void:
	for player in players:
		var id: int = player.id
		if not explored.has(id):
			explored[id] = {}
		visible[id] = {}
	for unit in units:
		if not is_instance_valid(unit) or unit.dead or unit.construction < 1:
			continue
		reveal(unit.owner_id, unit.position, float(unit.stats.get("vision", 190)))

func reveal(player: int, point: Vector2, radius: float) -> void:
	if not explored.has(player):
		explored[player] = {}
		visible[player] = {}
	var origin := Vector2i(point / CELL)
	var cells := ceili(radius / CELL)
	for y in range(maxi(0, origin.y - cells), mini(SIZE.y, origin.y + cells + 1)):
		for x in range(maxi(0, origin.x - cells), mini(SIZE.x, origin.x + cells + 1)):
			var tile := Vector2i(x, y)
			if (Vector2(tile * CELL) + Vector2.ONE * CELL * 0.5).distance_to(point) <= radius:
				visible[player][tile] = true
				explored[player][tile] = true

func state(player: int, point: Vector2) -> int:
	var tile := Vector2i(point / CELL)
	if visible.get(player, {}).has(tile):
		return 2
	return 1 if explored.get(player, {}).has(tile) else 0
