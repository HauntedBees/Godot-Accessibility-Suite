extends ExampleSceneRoot

@onready var _virtual_gamepad: GASVirtualGamepad = %GASVirtualGamepad

func _on_edit_mode_toggle_toggled(toggled_on: bool) -> void:
	_virtual_gamepad.edit_mode = toggled_on
