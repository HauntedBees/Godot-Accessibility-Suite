extends ExampleSceneRoot

func _on_hlv_pressed() -> void:
	GASInput.start_joy_vibration(0, 0.0, 1.0, 1.0)

func _on_hsv_pressed() -> void:
	GASInput.start_joy_vibration(0, 0.0, 1.0, 0.25)

func _on_wlv_pressed() -> void:
	GASInput.start_joy_vibration(0, 1.0, 0.0, 1.0)

func _on_wsv_pressed() -> void:
	GASInput.start_joy_vibration(0, 1.0, 0.0, 0.25)

func _on_stop_pressed() -> void:
	Input.stop_joy_vibration(0)

func _on_spin_box_value_changed(value: float) -> void:
	GASConfig.vibration_scale = value
