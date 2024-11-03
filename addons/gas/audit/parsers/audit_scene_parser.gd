class_name GASAuditSceneParser extends GASAuditFileParser

func can_parse(file: Resource) -> bool:
	return file is PackedScene && file.resource_path.ends_with(".tscn")

func parse(file: Resource) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	var subresources: Dictionary[String, SubresourceInfo] = {}
	var scene := FileAccess.open(file.resource_path, FileAccess.READ)
	var current_part: ScenePartInfo = null
	while !scene.eof_reached():
		var line := scene.get_line()
		if line.begins_with("[node"):
			current_part = NodeInfo.new(line)
		elif line.begins_with("[sub_resource"):
			var sub := SubresourceInfo.new(line)
			subresources[sub.name] = sub
			current_part = sub
		elif current_part == null:
			continue
		current_part.try_add_detail(line)
	return notes

class ScenePartInfo extends RefCounted:
	var name: String
	var type: String
	var details: Dictionary[String, String] = {}

	func try_add_detail(line: String) -> void:
		if line == "" || !line.contains(" = "):
			return
		var split := line.split(" = ")
		details[split[0]] = split[1]

	func _get_match(path: String, regex_str: String) -> Array[String]:
		var r := RegEx.new()
		r.compile(regex_str)
		var rmatch := r.search(path)
		if rmatch:
			return rmatch.strings
		return []

class SubresourceInfo extends ScenePartInfo:
	func _init(path: String) -> void:
		var parts := _get_match(path, "\\[sub_resource type=\"([^\"]*)\" id=\"([^\"]*)\"]")
		if parts.size() == 0:
			return
		name = parts[2]
		type = parts[1]

class NodeInfo extends ScenePartInfo:
	var parent: String
	func _init(path: String) -> void:
		var parts := _get_match(path, "\\[node name=\"([^\"]*)\" type=\"([^\"]*)\" parent=\"([^\"]*)\"]")
		if parts.size() == 0:
			return
		name = parts[1]
		type = parts[2]
		parent = parts[3]
