class_name GASAuditGDScriptParser extends GASAuditFileParser

func get_supported_filters() -> String:
	return "*.gd"

func get_supported_types() -> String:
	return ".gd Script files"

func can_parse(file: Resource) -> bool:
	return file is GDScript

func parse(file: Resource) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	var file_path := file.resource_path
	var script := FileAccess.open(file_path, FileAccess.READ)
	var current_method := ""
	while !script.eof_reached():
		var line := script.get_line()
		if line.begins_with("func "):
			current_method = line.split(" (")[0].split(" ")[1]
		match _contains_str(line, "Input.start_joy_vibration"):
			2: notes.append(GASAuditEntry.new("i-sjv", file_path, current_method, "Use [code]GASInput.start_joy_vibration[/code] instead of [code]Input.start_joy_vibration[/code] to ensure haptics can be adjusted or disabled.", GASGuidelineURL.HAPTICS))
			1: notes.append(GASAuditEntry.new("i-sjv", file_path, current_method, "Using [code]GASInput.start_joy_vibration[/code] to ensure haptics can be adjusted or disabled.", GASGuidelineURL.HAPTICS, GASAuditEntry.Grade.Passed))
		match _contains_str(line, "Input.vibrate_handheld"):
			2: notes.append(GASAuditEntry.new("i-vh", file_path, current_method, "Use [code]GASInput.vibrate_handheld[/code] instead of [code]Input.vibrate_handheld[/code] to ensure haptics can be adjusted or disabled.", GASGuidelineURL.HAPTICS))
			1: notes.append(GASAuditEntry.new("i-vh", file_path, current_method, "Using [code]GASInput.vibrate_handheld[/code] to ensure haptics can be adjusted or disabled.", GASGuidelineURL.HAPTICS, GASAuditEntry.Grade.Passed))
		if line.contains("KEY_") || line.contains("JOY_BUTTON_") || line.contains("JOY_AXIS_"):
			notes.append(GASAuditEntry.new("i-hc", file_path, current_method, "Avoid hard-coding KEY_*, JOY_BUTTON_*, or JOY_AXIS_* values in your code; create Actions in Godot's built-in Input Map so the values can be remapped.", GASGuidelineURL.CONFIG_CONTROLS, GASAuditEntry.Grade.Warning))
		match _contains_str(line, "Input.is_action_just_pressed"):
			2: notes.append(GASAuditEntry.new("i-iajp", file_path, current_method, "Use [code]GASInput.is_action_just_pressed[/code] instead of [code]Input.is_action_just_pressed[/code] to support configurable cool-down periods.", GASGuidelineURL.COOLDOWN))
			1: notes.append(GASAuditEntry.new("i-iajp", file_path, current_method, "Using [code]GASInput.is_action_just_pressed[/code] to support configurable cool-down periods.", GASGuidelineURL.COOLDOWN, GASAuditEntry.Grade.Passed))
	return notes

func _contains_str(line: String, string: String) -> int:
	if !line.contains(string):
		return 0
	return 1 if line.count(string) == line.count("GAS%s" % string) else 2
