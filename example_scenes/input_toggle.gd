extends ExampleSceneRoot

@onready var _up: TextureRect = %ArUp
@onready var _left: TextureRect = %ArLeft
@onready var _right: TextureRect = %ArRight
@onready var _down: TextureRect = %ArDown

func clean_up() -> void:
	GASInput.set_toggle_action("ui_down", false)
	GASInput.set_toggle_action("ui_left", false)
	GASInput.set_toggle_action("ui_right", false)
	GASInput.set_toggle_action("ui_up", false)

func _process(_delta: float) -> void:
	_up.modulate = Color.RED if Input.is_action_pressed("ui_up") else Color.WHITE
	_left.modulate = Color.RED if Input.is_action_pressed("ui_left") else Color.WHITE
	_down.modulate = Color.RED if Input.is_action_pressed("ui_down") else Color.WHITE
	_right.modulate = Color.RED if Input.is_action_pressed("ui_right") else Color.WHITE

func _on_down_toggled(toggled_on: bool) -> void:
	GASInput.set_toggle_action("ui_down", toggled_on)

func _on_left_toggled(toggled_on: bool) -> void:
	GASInput.set_toggle_action("ui_left", toggled_on)

func _on_right_toggled(toggled_on: bool) -> void:
	GASInput.set_toggle_action("ui_right", toggled_on)

func _on_up_toggled(toggled_on: bool) -> void:
	GASInput.set_toggle_action("ui_up", toggled_on)
