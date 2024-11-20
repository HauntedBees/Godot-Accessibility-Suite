extends ExampleSceneRoot

@onready var _qwerty: GASVirtualKeyboardQwerty = %Qwerty
@onready var _three: GASVirtualKeyboardThreeColumn = %Three
@onready var _custom: GASVirtualKeyboardBase = %Custom
@onready var _keybs: Array[GASVirtualKeyboardBase] = [_qwerty, _three, _custom]
@onready var _update_info: AccessibleLabel = %UpdateInfo
@onready var _text_edit: TextEdit = %TextEdit

func _ready() -> void:
	_text_edit.grab_focus()

func _on_qwerty_button_pressed() -> void:
	_toggle_vis(_qwerty)

func _on_three_button_pressed() -> void:
	_toggle_vis(_three)

func _on_custom_button_pressed() -> void:
	_toggle_vis(_custom)

func _toggle_vis(showing: GASVirtualKeyboardBase) -> void:
	for kb in _keybs:
		kb.visible = kb == showing

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_update_info.text = "ui_left pressed."
	elif event.is_action_pressed("ui_right"):
		_update_info.text = "ui_right pressed."
	elif event.is_action_pressed("ui_up"):
		_update_info.text = "ui_up pressed."
	elif event.is_action_pressed("ui_down"):
		_update_info.text = "ui_down pressed."
	elif event is InputEventKey && event.is_pressed():
		_update_info.text = "Key \"%s\" pressed." % (event as InputEventKey).as_text_keycode()

func _on_custom_keyboard_signal_emitted(value: String) -> void:
	_update_info.text = "Signal \"%s\" triggered." % value
