extends CanvasLayer
const Minimap = preload("res://scripts/minimap.gd")
var world
var root: Control
var status: Label
var selection_label: Label
var notification: Label
var objective_label: Label
var actions: HFlowContainer
var menu_panel: PanelContainer
var address: LineEdit
var mini
var signature := ""
var menu_open := false

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 15
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("14252b")
	panel_style.border_color = Color("34525b")
	panel_style.set_border_width_all(1)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("29454d")
	button_style.set_corner_radius_all(4)
	button_style.content_margin_left = 12
	button_style.content_margin_right = 12
	button_style.content_margin_top = 8
	button_style.content_margin_bottom = 8
	theme.set_stylebox("normal", "Button", button_style)
	var hover := button_style.duplicate()
	hover.bg_color = Color("3c666c")
	theme.set_stylebox("hover", "Button", hover)
	root.theme = theme
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 55
	root.add_child(top)
	var top_row := HBoxContainer.new()
	top.add_child(top_row)
	var title := Label.new()
	title.text = "RTS TEMPLATE  /  GODOT"
	title.add_theme_color_override("font_color", Color("89dfc5"))
	top_row.add_child(title)
	status = Label.new()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_row.add_child(status)
	button(top_row, "Pause [Space]", func(): world.network.submit({"type": "pause"}))
	button(top_row, "Menu / Help", toggle_menu)
	var bottom := PanelContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -170
	root.add_child(bottom)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	bottom.add_child(row)
	mini = Minimap.new()
	mini.world = world
	mini.custom_minimum_size = Vector2(225, 140)
	row.add_child(mini)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(details)
	selection_label = Label.new()
	details.add_child(selection_label)
	objective_label = Label.new()
	details.add_child(objective_label)
	actions = HFlowContainer.new()
	details.add_child(actions)
	notification = Label.new()
	notification.add_theme_color_override("font_color", Color("efd69d"))
	notification.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notification.custom_minimum_size.x = 600
	details.add_child(notification)
	create_menu()

func button(parent: Node, text: String, action: Callable) -> Button:
	var widget := Button.new()
	widget.text = text
	widget.pressed.connect(action)
	parent.add_child(widget)
	return widget

func create_menu() -> void:
	menu_panel = PanelContainer.new()
	menu_panel.position = Vector2(200, 80)
	menu_panel.custom_minimum_size = Vector2(720, 0)
	root.add_child(menu_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	menu_panel.add_child(box)
	var heading := Label.new()
	heading.text = "RTSTemplate · Native Godot conversion"
	heading.add_theme_font_size_override("font_size", 22)
	box.add_child(heading)
	var help := Label.new()
	help.text = "Left-click / drag: select friendly units · Shift: add / queue orders\nRight-click: move, attack, harvest, repair or set a production rally point\nWASD / arrows: camera · Middle-drag: pan · Wheel: zoom\nCtrl+1–9: store group · 1–9: recall · Space: pause · Esc: cancel\nSelect an engineer, choose a building, then click nearby visible land.\nSelect HQ or Barracks to train. Engineers harvest crystals automatically.\nDestroy the enemy HQ to win. Enemy raids begin after 50 seconds.\nF5: save · F9: load · Minimap: left-click camera / right-click move"
	box.add_child(help)
	var modes := HBoxContainer.new()
	box.add_child(modes)
	button(modes, "New skirmish", func(): if world.network.authority(): world.start_match(); toggle_menu())
	button(modes, "Economy race", func(): if world.network.authority(): world.start_match(false, [{"type": "earn", "amount": 250}]); toggle_menu())
	button(modes, "Original rm_test", func(): if not world.network.active(): world.start_match(true); toggle_menu())
	button(modes, "Steering demo", func():
		if world.network.authority():
			for i in range(12):
				world.spawn("core.units.flock", world.local_player, world.camera.position + Vector2((i % 4) * 26, (i / 4) * 26))
			toggle_menu())
	var debug := HBoxContainer.new()
	box.add_child(debug)
	check(debug, "Fog of war", true, func(value): world.show_fog = value)
	check(debug, "Flowfield overlay", false, func(value): world.show_flow = value)
	check(debug, "Grid", false, func(value): world.show_grid = value)
	check(debug, "Enemy AI", true, func(value): world.ai_enabled = value)
	var files := HBoxContainer.new()
	box.add_child(files)
	button(files, "Save [F5]", func(): world.save_game())
	button(files, "Load [F9]", func(): world.load_game())
	var network_label := Label.new()
	network_label.text = "LAN multiplayer · UDP 24680 · host controls player 1, guest player 2"
	box.add_child(network_label)
	var net_row := HBoxContainer.new()
	box.add_child(net_row)
	address = LineEdit.new()
	address.text = "127.0.0.1"
	address.custom_minimum_size.x = 170
	net_row.add_child(address)
	button(net_row, "Host", func():
		var error: Error = world.network.host()
		if error != OK:
			world.notify("Host failed: " + error_string(error)))
	button(net_row, "Join", func():
		var error: Error = world.network.join(address.text.strip_edges())
		if error != OK:
			world.notify("Join failed: " + error_string(error)))
	button(net_row, "Disconnect", func(): world.network.close(); world.notify("Offline mode"))
	button(box, "Close", toggle_menu)
	menu_panel.hide()

func check(parent: Node, text: String, value: bool, action: Callable) -> void:
	var widget := CheckBox.new()
	widget.text = text
	widget.button_pressed = value
	widget.toggled.connect(action)
	parent.add_child(widget)

func toggle_menu() -> void:
	menu_open = not menu_open
	menu_panel.visible = menu_open

func editing_text() -> bool:
	return address != null and address.has_focus()

func refresh() -> void:
	if status == null or world.players.is_empty():
		return
	var credits := int(world.players[world.local_player].credits)
	status.text = "P%s  ·  %s credits  ·  Power %+d  ·  %02d:%02d%s" % [world.local_player, credits, world.power(world.local_player), int(world.game_time) / 60, int(world.game_time) % 60, "  PAUSED" if world.paused else ""]
	var list: Array = world.selected.filter(func(u): return is_instance_valid(u) and not u.dead)
	var next_signature := str(list.map(func(u): return [u.net_id, u.templates.keys(), u.stats.get("abilities", {}), u.stats.get("products", []), u.stats.get("builds", []), u.owner_id, u.definition_id, u.construction >= 1, not u.production.is_empty()]))
	if next_signature != signature:
		signature = next_signature
		for child in actions.get_children():
			actions.remove_child(child)
			child.queue_free()
		var displayed := {}
		for unit in list:
			for id in world.Abilities.declarations(unit):
				if displayed.has(id):
					continue
				displayed[id] = true
				var declaration: Dictionary = world.Abilities.declarations(unit)[id]
				var label: String = declaration.get("label", id)
				if declaration.has("key"):
					label += " [" + OS.get_keycode_string(int(declaration.key)) + "]"
				var action_button := button(actions, label, func(): world.activate_ability(id))
				action_button.set_meta("ability", id)
		if list.size() == 1:
			var unit = list[0]
			for id in unit.stats.get("products", []):
				var definition: Dictionary = world.content.definitions[id]
				button(actions, "%s (%d)" % [definition.name, int(definition.cost)], func(): world.network.submit({"type": "train", "ids": [unit.net_id], "def": id}))
			for id in unit.stats.get("builds", []):
				var definition: Dictionary = world.content.definitions[id]
				button(actions, "%s (%d)" % [definition.name, int(definition.cost)], func(): world.build_mode = id)
			if not unit.production.is_empty():
				button(actions, "Cancel first (refund)", func(): world.network.submit({"type": "cancel_production", "ids": [unit.net_id], "slot": 0}))
	for widget in actions.get_children():
		if widget.has_meta("ability"):
			var id: String = widget.get_meta("ability")
			var ready := false
			var reason := "unavailable"
			for unit in list:
				reason = world.Abilities.available(unit, id)
				if reason == "accepted":
					ready = true
					break
			widget.disabled = not ready or world.paused or not world.outcome.is_empty()
			widget.tooltip_text = str(widget.text) if ready else reason.replace("_", " ").capitalize()
	objective_label.text = "Sandbox" if world.sandbox else world.objectives.summary()
	if list.is_empty():
		selection_label.text = "No selection · Drag over your units. Select an HQ to train."
	elif list.size() == 1:
		var unit = list[0]
		var queue := ""
		if not unit.production.is_empty():
			queue = " · Queue: %s (%0.1fs), %s total" % [world.content.definitions[unit.production[0].id].name, unit.production[0].remaining, unit.production.size()] + " - " + unit.production_status.replace("_", " ")
		selection_label.text = "%s · HP %0.0f/%0.0f · %s%s%s" % [unit.stats.name, unit.hp, unit.hp_max, unit.state, " · Building %d%%" % (unit.construction * 100) if unit.construction < 1 else "", queue]
		if unit.ammo >= 0:
			selection_label.text += " | Ammo %d/%d" % [int(unit.ammo), int(unit.stats.get("ammo_capacity", 0))]
		if unit.has_template("storage_transport"):
			selection_label.text += " | Cargo %d/%d" % [world.Containment.occupied(unit), int(unit.stats.get("capacity", 0))]
	else:
		selection_label.text = "%s units selected · Right-click to issue a group order" % list.size()
	notification.text = world.outcome if not world.outcome.is_empty() else ("Place %s · right-click cancels" % world.content.definitions[world.build_mode].name if not world.build_mode.is_empty() else ("Click a destination for " + world.command_mode if not world.command_mode.is_empty() else (world.message if world.message_time > 0 else "")))
	mini.queue_redraw()
