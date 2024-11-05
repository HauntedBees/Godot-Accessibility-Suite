class_name GASAuditThemeParser extends GASAuditFileParser

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
				notes.append(GASAuditEntry.new("theme-font-size", file_path, theme_part_name, "Theme Font Size of %d is under 28px." % font_size, GASGuidelineURL.FONT_SIZE))
			else:
				notes.append(GASAuditEntry.new("theme-font-size", file_path, theme_part_name, "Theme Font Size of %d is under 28px." % font_size, GASGuidelineURL.FONT_SIZE, GASAuditEntry.Grade.Passed))
	return notes
