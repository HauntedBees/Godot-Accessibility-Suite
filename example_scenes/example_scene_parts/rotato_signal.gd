extends TextureRect

func _ready() -> void:
	GASTime.process.connect(_gas_process)

func _gas_process(delta: float) -> void:
	rotation += delta * 2.0
