extends RefCounted
const Abilities = preload("res://scripts/abilities.gd")
## Stable IDs and JSON content; missing external textures fall back to source sprites.
var definitions: Dictionary = {}
var templates: Dictionary = {}
var images: Dictionary = {}
var errors: Array[String] = []

func load_all() -> void:
	definitions.clear()
	images.clear()
	var file := FileAccess.open("res://mods/core/units.json", FileAccess.READ)
	if file == null:
		errors.append("Cannot open core unit definitions")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("Invalid units.json")
		return
	definitions = parsed
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://mods/core/templates.json"))
	if not registry is Dictionary:
		errors.append("Invalid templates.json")
		return
	templates = registry
	for definition in definitions.values():
		var image: String = definition.get("image", "")
		if not image.is_empty() and not images.has(image):
			var path: String = definition.get("image_path", "")
			images[image] = load_texture(path)

func load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if FileAccess.file_exists(path):
		var image := Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	return null

func validate() -> Array[String]:
	var issues: Array[String] = errors.duplicate()
	for id in definitions:
		var definition: Dictionary = definitions[id]
		for template in definition.get("templates", []):
			if not templates.has(template):
				issues.append("%s: unknown template %s" % [id, template])
		for product in definition.get("products", []):
			if not definitions.has(product):
				issues.append("%s: unknown product %s" % [id, product])
		for ability in definition.get("abilities", {}):
			var config: Variant = definition.abilities[ability]
			if not config is Dictionary:
				issues.append("%s: invalid ability %s" % [id, ability])
				continue
			if not Abilities.CORE.has(config.get("command", ability)):
				issues.append("%s: unknown ability executor %s" % [id, ability])
			for field in ["cost", "cooldown"]:
				var value: Variant = config.get(field, 0)
				if not (value is int or value is float):
					issues.append("%s: invalid ability %s %s" % [id, ability, field])
				elif not is_finite(float(value)) or float(value) < 0:
					issues.append("%s: invalid ability %s %s" % [id, ability, field])
	for id in templates:
		for requirement in templates[id].get("requires", []):
			if not templates.has(requirement):
				issues.append("%s: unknown prerequisite %s" % [id, requirement])
	return issues
