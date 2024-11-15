extends ExampleSceneRoot

var _inputs: Array[StringName] = []
var _history: Array[String] = []

@onready var _input_history: AccessibleLabel = %InputHistory

func _ready() -> void:
	_inputs = InputMap.get_actions()

func _input(event: InputEvent) -> void:
	for i in _inputs:
		if !event.is_action(i):
			continue
		_history.append("Pressed %s" % i)
		if _history.size() > 10:
			_history.remove_at(0)
		_input_history.text = "\n".join(_history)
		return
