class_name GASAuditSceneNodeInfo extends GASAuditScenePartInfo

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

func close_and_get_entries(subresources: Dictionary[String, GASAuditSceneResourceInfo]) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	if ["Label", "AccessibleLabel", "RichTextLabel", "AccessibleRichTextLabel"].has(type):
		var p := GASAuditLabelParser.new(self, notes, subresources)
		p.process()
	return notes
