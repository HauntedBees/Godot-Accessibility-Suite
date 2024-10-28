@icon("icons/gas_scroll_container.svg")
class_name AccessibleScrollContainer extends ScrollContainer

signal scrolled(amount: int)

@export var scroll_speed := 1000.0
@export var action_scroll_enabled := true
@export var scroll_level := 0.0:
	set(value):
		scroll_level = value
		scroll_vertical = roundi(scroll_level)
		scrolled.emit(scroll_vertical)

func _process(delta: float) -> void:
	if !action_scroll_enabled:
		return
	if Input.is_action_pressed("gas_scroll_down"):
		scroll_level += delta * scroll_speed
	elif Input.is_action_pressed("gas_scroll_up"):
		scroll_level -= delta * scroll_speed
