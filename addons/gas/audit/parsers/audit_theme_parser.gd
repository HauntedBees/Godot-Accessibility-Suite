class_name GASAuditThemeParser extends GASAuditFileParser

var THEME_ICON := EditorInterface.get_editor_theme().get_icon("Theme", "EditorIcons")

func get_supported_filters() -> String:
	return "*.tres"

func get_supported_types() -> String:
	return ".tres Theme files"

func can_parse(file: Resource) -> bool:
	return file is Theme

func parse(file: Resource) -> Array[GASAuditEntry]:
	var notes: Array[GASAuditEntry] = []
	var file_path := file.resource_path
	var script := FileAccess.open(file_path, FileAccess.READ)
	var current_method := ""
	while !script.eof_reached():
		var line := script.get_line()
		if line.contains("/font_sizes/"):
			var split = line.split(" = ")
			if split.size() != 2:
				continue
			var font_size := int(split[1])
			var theme_part_name = split[0]
			if font_size < 28:
				notes.append(GASAuditEntry.new("theme-font-size", file_path, theme_part_name, "Theme Font Size of %d is under 28px." % font_size, GASGuidelineURL.FONT_SIZE, THEME_ICON))
			else:
				notes.append(GASAuditEntry.new("theme-font-size", file_path, theme_part_name, "Theme Font Size of %d is under 28px." % font_size, GASGuidelineURL.FONT_SIZE, THEME_ICON, GASAuditEntry.Grade.Passed))
	return notes
