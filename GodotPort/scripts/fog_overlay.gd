extends Node2D
var world

func _draw() -> void:
	if not world.running or not world.fog_enabled:
		return
	for x in range(80):
		for y in range(60):
			var tile := Vector2i(x,y)
			if not world.fog.visible_cells.has(tile):
				var color := Color(0.015,0.025,0.04,0.55) if world.fog.explored.has(tile) else Color("0a141e")
				draw_rect(Rect2(Vector2(tile*32),Vector2(32,32)),color)
