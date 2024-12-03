extends ExampleSceneRoot

@onready var _left_panel_container: PanelContainer = %LeftPanelContainer
@onready var _center_panel_container: PanelContainer = %CenterPanelContainer

func _on_left_scale_slider_value_changed(value: float) -> void:
	_left_panel_container.size_flags_stretch_ratio = value

func _on_panel_scale_slider_value_changed(value: float) -> void:
	_center_panel_container.custom_minimum_size = Vector2(value, value)
