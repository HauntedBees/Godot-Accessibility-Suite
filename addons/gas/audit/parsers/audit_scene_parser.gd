class_name GASAuditSceneParser extends GASAuditFileParser

func can_parse(file: Resource) -> bool:
	return file is PackedScene && file.resource_path.ends_with(".tscn")

func parse(file: Resource) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	var subresources: Dictionary[String, SubresourceInfo] = {}
	var file_path := file.resource_path
	var scene := FileAccess.open(file_path, FileAccess.READ)
	var current_part: ScenePartInfo = null
	while !scene.eof_reached():
		var line := scene.get_line()
		if line.begins_with("[node"):
			if current_part != null && current_part is NodeInfo:
				notes.append_array((current_part as NodeInfo).close_and_get_entries(subresources))
			current_part = NodeInfo.new(file_path, line)
		elif line.begins_with("[sub_resource"):
			var sub := SubresourceInfo.new(file_path, line)
			subresources[sub.name] = sub
			current_part = sub
		elif current_part == null:
			continue
		current_part.try_add_detail(line)
	return notes

class ScenePartInfo extends RefCounted:
	var name: String
	var type: String
	var source_path: String
	var details: Dictionary[String, String] = {}
	func try_add_detail(line: String) -> void:
		if line == "" || !line.contains(" = "):
			return
		var split := line.split(" = ")
		details[split[0]] = split[1]
	func _get_match(path: String, regex_str: String) -> PackedStringArray:
		var r := RegEx.new()
		r.compile(regex_str)
		var rmatch := r.search(path)
		if rmatch:
			return rmatch.strings
		return []

class SubresourceInfo extends ScenePartInfo:
	var used_by: Array[String] = []
	func _init(file_path: String, path: String) -> void:
		source_path = file_path
		var parts := _get_match(path, "\\[sub_resource type=\"([^\"]*)\" id=\"([^\"]*)\"]")
		if parts.size() == 0:
			return
		name = parts[2]
		type = parts[1]

class NodeInfo extends ScenePartInfo:
	var parent: String
	var path: String
	func _init(file_path: String, scene_path: String) -> void:
		source_path = file_path
		var parts := _get_match(scene_path, "\\[node name=\"([^\"]*)\" type=\"([^\"]*)\" parent=\"([^\"]*)\"]")
		if parts.size() == 0:
			var parts_root := _get_match(scene_path, "\\[node name=\"([^\"]*)\" type=\"([^\"]*)\"]")
			if parts_root.size() > 0:
				name = parts_root[1]
				type = parts_root[2]
				parent = ""
			return
		name = parts[1]
		type = parts[2]
		parent = parts[3]
		path = name if parent == "" else "%s/%s" % [parent, name]
	func close_and_get_entries(subresources: Dictionary[String, SubresourceInfo]) -> Array[GASAuditEntry]:
		var notes: Array[GASAuditEntry] = []
		if ["Label", "AccessibleLabel", "RichTextLabel", "AccessibleRichTextLabel"].has(type):
			if type == "Label":
				notes.append(GASAuditEntry.new("use-al", source_path, path, "You can use [code]AccessibleLabel[/code] to get built-in font scaling.", GASAuditEntry.Grade.Warning))
			if type == "RichTextLabel":
				notes.append(GASAuditEntry.new("use-artl", source_path, path, "You can use [code]AccessibleRichTextLabel[/code] to get built-in font scaling.", GASAuditEntry.Grade.Warning))
			if details.has("label_settings"): # LabelSettings takes priority for font size
				_try_check_resource_font_size("lsfs", notes, subresources, "label_settings", "font_size", "[code]LabelSettings[/code] Font Size of %d is under 28px.", "[code]LabelSettings[/code] Font Size of %d is over 28px.")
			elif details.has("theme_override_font_sizes/font_size"): # Theme Override takes second priority
				var size := int(details["theme_override_font_sizes/font_size"])
				if size < 28:
					notes.append(GASAuditEntry.new("to-fs", source_path, path, "Theme Override Font Size of %d is under 28px." % size))
				else:
					notes.append(GASAuditEntry.new("to-fs", source_path, path, "Theme Override Font Size of %d is over 28px." % size, GASAuditEntry.Grade.Passed))
			elif details.has("theme"): # Theme takes third priority
				_try_check_resource_font_size("l-fs-fs", notes, subresources, "theme", "Label/font_sizes/font_size", "Theme [code]Label[/code] Font Size of %d is under 28px.", "Theme [code]Label[/code] Font Size of %d is over 28px.")
				_try_check_resource_font_size("rtl-fs-bfs", notes, subresources, "theme", "RichTextLabel/font_sizes/bold_font_size", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is over 28px.")
				_try_check_resource_font_size("rtl-fs-bifs", notes, subresources, "theme", "RichTextLabel/font_sizes/bold_italics_font_size", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is over 28px.")
				_try_check_resource_font_size("rtl-fs-ifs", notes, subresources, "theme", "RichTextLabel/font_sizes/italics_font_size", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is over 28px.")
				_try_check_resource_font_size("rtl-fs-mfs", notes, subresources, "theme", "RichTextLabel/font_sizes/mono_font_size", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is over 28px.")
				_try_check_resource_font_size("rtl-fs-nfs", notes, subresources, "theme", "RichTextLabel/font_sizes/normal_font_size", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is over 28px.")
		return notes
	func _try_check_resource_font_size(
		id: String,
		notes: Array[GASAuditEntry],
		subresources: Dictionary[String, SubresourceInfo],
		resource_key: String,
		resource_value_key: String,
		message: String,
		success_message: String
	) -> void:
		var value := details[resource_key]
		if value.begins_with("ExtResource"):
			pass # TODO: external resource checker
		elif value.begins_with("SubResource"):
			var resource_id := value.split("\"")[1]
			if subresources.has(resource_id):
				var resource := subresources[resource_id]
				if resource.details.has(resource_value_key):
					var size := int(resource.details[resource_value_key])
					if size < 28:
						notes.append(GASAuditEntry.new(id, source_path, path, message % size))
					else:
						notes.append(GASAuditEntry.new(id, source_path, path, success_message % size, GASAuditEntry.Grade.Passed))
