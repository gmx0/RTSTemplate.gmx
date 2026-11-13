extends Control
var world

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var point: Vector2 = (event.position / size) * world.navigation.WORLD
		if event.button_index == MOUSE_BUTTON_LEFT:
			world.camera.position = point
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			world.issue_order("move", point)
		accept_event()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("20352e"))
	var scale: Vector2 = size / world.navigation.WORLD
	for y in range(world.navigation.SIZE.y):
		for x in range(world.navigation.SIZE.x):
			var point := Vector2(x * 32, y * 32)
			var rect := Rect2(point * scale, Vector2.ONE * 32 * scale + Vector2.ONE)
			var kind: int = world.navigation.terrain[y * world.navigation.SIZE.x + x]
			if kind > 0:
				draw_rect(rect, Color("28536d") if kind == 1 else Color("657064"))
			if world.show_fog:
				var state: int = world.fog.state(world.local_player, point + Vector2.ONE * 16)
				if state < 2:
					draw_rect(rect, Color(0.01, 0.02, 0.03, 0.97 if state == 0 else 0.6))
	for unit in world.units:
		if world.can_see(world.local_player, unit):
			draw_circle(unit.position * scale, 3 if unit.is_structure() else 2, world.player_color(unit.owner_id))
	var extent: Vector2 = world.get_viewport_rect().size / world.camera.zoom * 0.5
	draw_rect(Rect2((world.camera.position - extent) * scale, extent * 2 * scale), Color("e6ebce"), false, 1)
	draw_rect(Rect2(Vector2.ZERO, size), Color("56756e"), false, 1)
