extends Node2D

func _ready():
	GASConfig.input_toggle_actions.append("ui_cancel")

func _process(delta: float):
	if GASInput.is_action_just_pressed("ui_select"):
		print("Input!")
	if Input.is_action_pressed("ui_cancel"):
		print("Toggled Hold")
	if Input.is_action_pressed("ui_focus_next"):
		print("Regular Hold")

func _input(event: InputEvent):
	if !(event is InputEventKey): return
	var key: InputEventKey = event
	if !key.pressed: return
	if key.keycode == KEY_X:
		GASConfig.input_cooldown_enabled = true
		print("COOLDOWN")
	if key.keycode == KEY_C:
		GASConfig.input_cooldown_enabled = false
		print("NO COOLDOWN")
	if key.keycode == KEY_Z:
		print(InputMap.action_get_events("ui_focus_next")[0])
		var i := InputEventKey.new()
		i.pressed = true
		i.keycode = KEY_P
		GASInput.remap_action("ui_focus_next", i)
		print("REMAP")
