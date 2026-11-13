extends RefCounted
## Stable definition IDs and optional external PNGs. Later folders override earlier IDs.
var definitions: Dictionary = {}
var textures: Dictionary = {}
var errors: Array[String] = []

func load_all() -> void:
	definitions.clear()
	textures.clear()
	errors.clear()
	load_folder("res://mods")
	load_folder("user://mods")

func load_folder(root: String) -> void:
	if not DirAccess.dir_exists_absolute(root):
		return
	var folders := DirAccess.get_directories_at(root)
	folders.sort()
	for folder in folders:
		var path := root.path_join(folder).path_join("units.json")
		if not FileAccess.file_exists(path):
			continue
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not parsed is Array:
			errors.append("Invalid definition file: " + path)
			continue
		for item in parsed:
			if not item is Dictionary or not item.has("id") or not item.get("traits", []) is Array or float(item.get("hp", 0)) <= 0:
				errors.append("Invalid unit in " + path)
				continue
			definitions[str(item.id)] = item
			var image_path: String = item.get("image", "")
			if not image_path.is_empty():
				if not image_path.begins_with("res://") and not image_path.begins_with("user://"):
					image_path = root.path_join(folder).path_join(image_path)
				if image_path.begins_with("res://") and ResourceLoader.exists(image_path):
					textures[str(item.id)] = load(image_path)
				else:
					var img := Image.new()
					if FileAccess.file_exists(image_path) and img.load(image_path) == OK:
						textures[str(item.id)] = ImageTexture.create_from_image(img)

func get_def(id: String) -> Dictionary:
	return definitions.get(id, {})
