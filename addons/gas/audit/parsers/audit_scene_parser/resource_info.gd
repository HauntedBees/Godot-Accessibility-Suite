class_name GASAuditSceneResourceInfo extends GASAuditScenePartInfo

var used_by: Array[String] = []

func _init(file_path: String, path: String) -> void:
	source_path = file_path
	var parts := _get_match(path, "\\[sub_resource type=\"([^\"]*)\" id=\"([^\"]*)\"]")
	if parts.size() == 0:
		return
	name = parts[2]
	type = parts[1]
