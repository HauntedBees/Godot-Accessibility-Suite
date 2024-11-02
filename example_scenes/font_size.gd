extends ExampleSceneRoot

func _on_scale_2_pressed() -> void:
	GASText.override_font_scale = 1.25

func _on_scale_15_pressed() -> void:
	GASText.override_font_scale = 1.1

func _on_scale_1_pressed() -> void:
	GASText.override_font_scale = 1.0
