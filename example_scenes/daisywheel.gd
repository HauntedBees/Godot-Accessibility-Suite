extends ExampleSceneRoot

@onready var _text_edit: TextEdit = %TextEdit

func _ready() -> void:
	_text_edit.grab_focus()
