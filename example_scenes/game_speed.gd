extends ExampleSceneRoot

func clean_up() -> void:
	_on_time_scale_1_pressed()
	_on_group_time_scale_1_pressed()

func _on_time_scale_2_pressed() -> void:
	Engine.time_scale = 2.0

func _on_time_scale_1_pressed() -> void:
	Engine.time_scale = 1.0

func _on_time_scale_half_pressed() -> void:
	Engine.time_scale = 0.5

func _on_group_time_scale_2_pressed() -> void:
	GASTime.set_group_time_scale(2.0)

func _on_group_time_scale_1_pressed() -> void:
	GASTime.set_group_time_scale(1.0)

func _on_group_time_scale_half_pressed() -> void:
	GASTime.set_group_time_scale(0.5)

func _on_signal_time_scale_2_pressed() -> void:
	GASConfig.signal_time_scale = 2.0

func _on_signal_time_scale_1_pressed() -> void:
	GASConfig.signal_time_scale = 1.0

func _on_signal_time_scale_half_pressed() -> void:
	GASConfig.signal_time_scale = 0.5
