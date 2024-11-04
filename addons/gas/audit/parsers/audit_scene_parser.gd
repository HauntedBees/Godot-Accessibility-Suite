class_name GASAuditSceneParser extends GASAuditFileParser

func can_parse(file: Resource) -> bool:
	return file is PackedScene && file.resource_path.ends_with(".tscn")

func parse(file: Resource) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	var subresources: Dictionary[String, GASAuditSceneResourceInfo] = {}
	var file_path := file.resource_path
	var scene := FileAccess.open(file_path, FileAccess.READ)
	var current_part: GASAuditScenePartInfo = null
	while !scene.eof_reached():
		var line := scene.get_line()
		if line.begins_with("[node"):
			if current_part != null && current_part is GASAuditSceneNodeInfo:
				notes.append_array((current_part as GASAuditSceneNodeInfo).close_and_get_entries(subresources))
			current_part = GASAuditSceneNodeInfo.new(file_path, line)
		elif line.begins_with("[sub_resource"):
			var sub := GASAuditSceneResourceInfo.new(file_path, line)
			subresources[sub.name] = sub
			current_part = sub
		elif current_part == null:
			continue
		current_part.try_add_detail(line)
	if current_part != null && current_part is GASAuditSceneNodeInfo:
		notes.append_array((current_part as GASAuditSceneNodeInfo).close_and_get_entries(subresources))
	return notes
