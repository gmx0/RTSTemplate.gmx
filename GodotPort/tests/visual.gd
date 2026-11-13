extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	world.ai_enabled = false
	await process_frame
	var engineer = world.units.filter(func(u): return u.owner_id == 1 and u.has_template("engineer"))[0]
	world.set_selection([engineer])
	for i in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/preview.png")
	world.hud.toggle_menu()
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/menu.png")
	print("Visual captures saved")
	quit()
