extends Control

const SPEED := 100.0
onready var player := $Player
var frames := [
	preload("res://example_assets/penguin.png"),
	preload("res://example_assets/parrot.png"),
	preload("res://example_assets/bluebird.png")
]
var current_frame := 0

func _on_CheckButton_pressed(): $GASVirtualGamepad.edit_mode = $Buttons/CheckButton.pressed
func _on_SaveButton_pressed(): $GASVirtualGamepad.save_setup()
func _on_LoadButton_pressed(): $GASVirtualGamepad.load_setup()
func _on_DefaultButton_pressed(): $GASVirtualGamepad.restore_defaults()

func _process(delta:float):
	if Input.is_action_just_pressed("ui_accept"):
		current_frame = (current_frame + 1) % 3
		player.texture = frames[current_frame]
	if Input.is_action_pressed("ui_cancel"):
		player.scale += Vector2(0.2, 0.2) * delta
	if Input.is_action_pressed("ui_end"):
		player.rotation += 2.0 * delta
	
	if Input.is_action_pressed("ui_left"):
		player.position.x -= delta * SPEED * Input.get_action_strength("ui_left")
	elif Input.is_action_pressed("ui_right"):
		player.position.x += delta * SPEED * Input.get_action_strength("ui_right")
	if Input.is_action_pressed("ui_up"):
		player.position.y -= delta * SPEED * Input.get_action_strength("ui_up")
	elif Input.is_action_pressed("ui_down"):
		player.position.y += delta * SPEED * Input.get_action_strength("ui_down")
