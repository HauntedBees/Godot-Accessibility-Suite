extends ExampleSceneRoot

func _on_accessible_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_font_reg_pressed() -> void:
	GASText.override_font_scale = 1.0

func _on_font_big_pressed() -> void:
	GASText.override_font_scale = 1.1

func _on_font_bigger_pressed() -> void:
	GASText.override_font_scale = 1.25
