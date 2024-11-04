class_name GASAuditScenePartInfo extends RefCounted

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
