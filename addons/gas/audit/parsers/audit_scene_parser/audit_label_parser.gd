class_name GASAuditLabelParser extends AuditSceneNodeParser

func process() -> void:
	if _node.type == "Label":
		_add_audit_entry("use-al", "You can use [code]AccessibleLabel[/code] to get built-in font scaling.", GASAuditEntry.Grade.Warning)
	if _node.type == "RichTextLabel":
		_add_audit_entry("use-artl", "You can use [code]AccessibleRichTextLabel[/code] to get built-in font scaling.", GASAuditEntry.Grade.Warning)
	if _node.details.has("label_settings"): # LabelSettings takes priority for font size
		_try_check_resource_font_size("lsfs", "label_settings", "font_size", "[code]LabelSettings[/code] Font Size of %d is under 28px.", "[code]LabelSettings[/code] Font Size of %d is over 28px.")
	elif _node.details.has("theme_override_font_sizes/font_size"): # Theme Override takes second priority
		var size := int(_node.details["theme_override_font_sizes/font_size"])
		if size < 28:
			_add_audit_entry("to-fs", "Theme Override Font Size of %d is under 28px." % size)
		else:
			_add_audit_entry("to-fs", "Theme Override Font Size of %d is over 28px." % size, GASAuditEntry.Grade.Passed)
	elif _node.details.has("theme"): # Theme takes third priority
		_try_check_resource_font_size("l-fs-fs", "theme", "Label/font_sizes/font_size", "Theme [code]Label[/code] Font Size of %d is under 28px.", "Theme [code]Label[/code] Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-bfs", "theme", "RichTextLabel/font_sizes/bold_font_size", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-bifs", "theme", "RichTextLabel/font_sizes/bold_italics_font_size", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Bold Italics Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-ifs", "theme", "RichTextLabel/font_sizes/italics_font_size", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Italics Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-mfs", "theme", "RichTextLabel/font_sizes/mono_font_size", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Monospace Font Size of %d is over 28px.")
		_try_check_resource_font_size("rtl-fs-nfs", "theme", "RichTextLabel/font_sizes/normal_font_size", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is under 28px.", "Theme [code]RichTextLabel[/code] Normal Font Size of %d is over 28px.")

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
					_add_audit_entry(id, message % size)
				else:
					_add_audit_entry(id, success_message % size, GASAuditEntry.Grade.Passed)
