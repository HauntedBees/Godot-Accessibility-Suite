extends Control

const SPEED := 100.0
@onready var player := $Player
var frames := [
	preload("res://example_assets/penguin.png"),
	preload("res://example_assets/parrot.png"),
	preload("res://example_assets/bluebird.png")
]
var current_frame := 0
@onready var gamepad: GASVirtualGamepad = $GASVirtualGamepad
@onready var edit_btn: CheckButton = $Buttons/CheckButton

func _on_CheckButton_pressed(): gamepad.edit_mode = edit_btn.button_pressed
func _on_SaveButton_pressed(): gamepad.save_setup()
func _on_LoadButton_pressed(): gamepad.load_setup()
func _on_DefaultButton_pressed(): gamepad.restore_defaults()

func _process(delta: float):
	if GASInput.is_action_just_pressed("ui_accept"):
		current_frame = (current_frame + 1) % 3
		player.texture = frames[current_frame]
	if Input.is_action_pressed("ui_cancel"):
		player.scale += Vector2(0.2, 0.2) * delta
	if Input.is_action_pressed("ui_end"):
		player.rotation += 2.0 * delta

	var movement := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	player.position += movement * delta * SPEED
