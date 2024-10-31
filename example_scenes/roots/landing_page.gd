extends ExampleSceneRoot

@onready var _grid_container: GridContainer = %GridContainer

func _ready() -> void:
	for b: CategoryButton in _grid_container.get_children():
		b.pressed.connect(_change_scene.bind(b))
