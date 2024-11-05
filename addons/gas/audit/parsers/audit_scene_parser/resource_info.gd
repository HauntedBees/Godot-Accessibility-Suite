class_name GASAuditSceneResourceInfo extends GASAuditScenePartInfo

var used_by: Array[String] = []
var id := ""

func _init(file_path: String, path: String, external := false) -> void:
	source_path = file_path
	var parts: PackedStringArray
	if external:
		parts = _get_match(path, "\\[ext_resource type=\"([^\"]*)\" path=\"([^\"]*)\" id=\"([^\"]*)\"]")
	else:
		parts = _get_match(path, "\\[sub_resource type=\"([^\"]*)\" id=\"([^\"]*)\"]")
	if parts.size() == 0:
		return
	name = parts[2]
	type = parts[1]
	if external:
		id = parts[3]
