extends ExampleSceneRoot

@onready var _texture_rect: TextureRect = %TextureRect

func _on_button_pressed() -> void:
	_texture_rect.texture = ImageTexture.create_from_image(GASUtils.get_screen())
