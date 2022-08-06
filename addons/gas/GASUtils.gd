extends Node

# https://gameaccessibilityguidelines.com/provide-gameplay-thumbnails-with-game-saves/
func save_screen(name: String):
	var img := get_screen()
	img.save_png("user://save_%s.png" % name)
func get_screen() -> Image:
	var img := get_viewport().get_texture().get_data()
	img.flip_y()
	img.shrink_x2()
	return img
func load_screen_as_image(name: String) -> Image:
	var file := File.new()
	var opened := file.open("user://save_%s.png" % name, File.READ)
	if opened != OK: return null
	var content := file.get_buffer(file.get_len())
	file.close()
	var img := Image.new()
	img.load_png_from_buffer(content)
	return img
func load_screen_as_texture(name: String, width := 0.0, height := 0.0, keep_aspect_ratio := true) -> ImageTexture:
	var img := load_screen_as_image(name)
	if img == null: return null
	var texture := ImageTexture.new()
	texture.create_from_image(img)
	if width > 0 || height > 0:
		var curr_width := texture.get_width()
		var curr_height := texture.get_height()
		if keep_aspect_ratio:
			var max_width := float(curr_width if width == 0 else width)
			var max_height := float(curr_height if height == 0 else height)
			var ratio := min(max_width / curr_width, max_height / curr_height)
			texture.set_size_override(Vector2(curr_width * ratio, curr_height * ratio))
		else:
			texture.set_size_override(Vector2(width if width > 0 else curr_width, height if height > 0 else curr_height))
	return texture
func load_screen_as_texture_rect(name: String, width := 0.0, height := 0.0, keep_aspect_ratio := true) -> TextureRect:
	var texture := load_screen_as_texture(name, width, height, keep_aspect_ratio)
	if texture == null: return null
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	return texture_rect
