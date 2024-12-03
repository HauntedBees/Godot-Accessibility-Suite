extends ExampleSceneRoot

const _BUTTON_POSITIONS: Array[Vector2i] = [
	Vector2i(Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_BEGIN),
	Vector2i(Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_BEGIN),
	Vector2i(Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_BEGIN),
	Vector2i(Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_CENTER),
	Vector2i(Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_CENTER),
	Vector2i(Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_CENTER),
	Vector2i(Control.SIZE_SHRINK_BEGIN, Control.SIZE_SHRINK_END),
	Vector2i(Control.SIZE_SHRINK_CENTER, Control.SIZE_SHRINK_END),
	Vector2i(Control.SIZE_SHRINK_END, Control.SIZE_SHRINK_END)
]

@onready var _buttons: GridContainer = %Buttons
@onready var _hud: VBoxContainer = %HUD

func _ready() -> void:
	var i := 0
	for b: Button in _buttons.get_children():
		b.pressed.connect(_on_change_hud.bind(_BUTTON_POSITIONS[i]))
		i += 1

func _on_change_hud(new_pos: Vector2i) -> void:
	_hud.size_flags_horizontal = new_pos.x
	_hud.size_flags_vertical = new_pos.y
