extends ConfirmationDialog

signal binding_changed(e: InputEvent)

func _unhandled_input(event: InputEvent) -> void:
	if !visible || event is InputEventMouseMotion:
		return
	binding_changed.emit(event)
