extends ExampleSceneRoot

@onready var _qwerty: GASVirtualKeyboardQwerty = %Qwerty
@onready var _three: GASVirtualKeyboardThreeColumn = %Three
@onready var _custom: GASVirtualKeyboardBase = %Custom
@onready var _keybs: Array[GASVirtualKeyboardBase] = [_qwerty, _three, _custom]

func _on_qwerty_button_pressed() -> void:
	_toggle_vis(_qwerty)

func _on_three_button_pressed() -> void:
	_toggle_vis(_three)

func _on_custom_button_pressed() -> void:
	_toggle_vis(_custom)

func _toggle_vis(showing: GASVirtualKeyboardBase) -> void:
	for kb in _keybs:
		kb.visible = kb == showing
