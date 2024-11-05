class_name GASAuditLabelParser extends AuditSceneNodeParser

func process() -> void:
	var script := _node.get_potential_script()
	if script != "":
		var script_path: String = _resources[script].name if _resources.has(script) else ""
		if _node.type == "Label" && !script_path.ends_with("gas_label.gd"):
			_add_audit_entry("use-al", "You can use [code]AccessibleLabel[/code] to get built-in font scaling.", GASGuidelineURL.RESIZE_FONT, GASAuditEntry.Grade.Warning)
		elif _node.type == "RichTextLabel" && !script_path.ends_with("gas_richtextlabel.gd"):
			_add_audit_entry("use-artl", "You can use [code]AccessibleRichTextLabel[/code] to get built-in font scaling.", GASGuidelineURL.RESIZE_FONT, GASAuditEntry.Grade.Warning)
	if _node.details.has("label_settings"): # LabelSettings takes priority for font size
		_try_check_resource_font_size("lsfs", "label_settings", "font_size", "[code]LabelSettings[/code] Font Size of %d is under 28px.", "[code]LabelSettings[/code] Font Size of %d is over 28px.")
	elif _node.details.has("theme_override_font_sizes/font_size"): # Theme Override takes second priority
		var size := int(_node.details["theme_override_font_sizes/font_size"])
		if size < 28:
			_add_audit_entry("to-fs", "Theme Override Font Size of %d is under 28px." % size, GASGuidelineURL.FONT_SIZE)
		else:
			_add_audit_entry("to-fs", "Theme Override Font Size of %d is over 28px." % size, GASGuidelineURL.FONT_SIZE, GASAuditEntry.Grade.Passed)
	elif _node.details.has("theme"): # Theme takes third priority
		_try_check_resource_font_size("l-fs-fs", "theme", "Label/font_sizes/font_size", "Theme [code]Label[/code] Font Size of %d is under 28px.", "Theme [code]Label[/code] Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-bfs", "theme", "RichTextLabel/font_sizes/bold_font_size", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-bifs", "theme", "RichTextLabel/font_sizes/bold_italics_font_size", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-ifs", "theme", "RichTextLabel/font_sizes/italics_font_size", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-mfs", "theme", "RichTextLabel/font_sizes/mono_font_size", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-nfs", "theme", "RichTextLabel/font_sizes/normal_font_size", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is over 28px.")
	else: # Check for custom theme
		var theme := ThemeDB.get_project_theme()
		var theme_text := "a custom"
		if theme == null:
			theme = ThemeDB.get_default_theme()
			theme_text = "Godot's default"
		var theme_type := _node.details["theme_type_variation"] if _node.details.has("theme_type_variation") else _node.type
		if theme_type == "AccessibleLabel":
			theme_type = "Label"
		elif theme_type == "AccessibleRichTextLabel":
			theme_type = "RichTextLabel"
		var found_font_size := false
		if _node.type == "Label" || _node.type == "AccessibleLabel":
			found_font_size = _check_theme_font_size(theme, "font_size", theme_type, "This node uses %s theme's [code]Label[/code] font size" % theme_text)
		elif _node.type == "RichTextLabel" || _node.type == "AccessibleRichTextLabel":
			found_font_size = found_font_size || _check_theme_font_size(theme, "normal_font_size", theme_type, "This node uses %s theme's [code]RichTextLabel[/code] normal font size" % theme_text)
			found_font_size = found_font_size || _check_theme_font_size(theme, "bold_font_size", theme_type, "This node uses %s theme's [code]RichTextLabel[/code] bold font size" % theme_text)
			found_font_size = found_font_size || _check_theme_font_size(theme, "bold_italics_font_size", theme_type, "This node uses %s theme's [code]RichTextLabel[/code] bold italics font size" % theme_text)
			found_font_size = found_font_size || _check_theme_font_size(theme, "italics_font_size", theme_type, "This node uses %s theme's [code]RichTextLabel[/code] italics font size" % theme_text)
			found_font_size = found_font_size || _check_theme_font_size(theme, "mono_font_size", theme_type, "This node uses %s theme's [code]RichTextLabel[/code] monospace font size" % theme_text)
		if !found_font_size:
			var font_size = ThemeDB.fallback_font_size
			if font_size < 28:
				_add_audit_entry("theme-font-size", "This node has no custom styles, so it is using Godot's default font size, %d, which is below 28px." % font_size, GASGuidelineURL.FONT_SIZE)
			else:
				_add_audit_entry("theme-font-size", "This node has no custom styles, so it is using Godot's default font size, %d, which is over 28px." % font_size, GASGuidelineURL.FONT_SIZE, GASAuditEntry.Grade.Passed)

func _check_theme_font_size(theme: Theme, name: String, theme_type: String, prefix_string: String) -> bool:
	if !theme.has_font_size(name, theme_type):
		return false
	var font_size := theme.get_font_size(name, theme_type)
	if font_size < 28:
		_add_audit_entry("theme-font-size", "%s, %d, which is below 28px." % [prefix_string, font_size], GASGuidelineURL.FONT_SIZE)
	else:
		_add_audit_entry("theme-font-size", "%s, %d, which is over 28px." % [prefix_string, font_size], GASGuidelineURL.FONT_SIZE, GASAuditEntry.Grade.Passed)
	return true

func _try_check_resource_font_size(id: String, resource_key: String, resource_value_key: String, message: String, success_message: String) -> void:
	var value := _node.details[resource_key]
	if value.begins_with("ExtResource"):
		pass # TODO: external resource checker
	elif value.begins_with("SubResource"):
		var resource_id := value.split("\"")[1]
		if _resources.has(resource_id):
			var resource := _resources[resource_id]
			if resource.details.has(resource_value_key):
				var size := int(resource.details[resource_value_key])
				if size < 28:
					_add_audit_entry(id, message % size, GASGuidelineURL.FONT_SIZE)
				else:
					_add_audit_entry(id, success_message % size, GASGuidelineURL.FONT_SIZE, GASAuditEntry.Grade.Passed)
