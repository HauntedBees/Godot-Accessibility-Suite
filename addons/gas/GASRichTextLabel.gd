extends RichTextLabel

# Font.get_wordwrap_string_size doesn't seem to be accurate when using rect_size as the
# bounds, and this padding seems to fix that. not sure if these numbers will always work.
export(Vector2) var text_padding := Vector2(8.0, 4.0)
func _real_width() -> float: return rect_size.x - text_padding.x * (font_size / 16.0)
func _real_height() -> float: return rect_size.y - text_padding.y * (font_size / 16.0)

var wrap_text:String setget set_text
func set_text(t:String):
	wrap_text = t
	if bbcode_enabled: bbcode_text = t
	else: text = t
	_reset_text()
var translation_key:String setget set_translation_key
func set_translation_key(t:String):
	translation_key = t
	set_text(tr(t)) 

onready var color_regex := RegEx.new()
var current_font:DynamicFont
var font_size:int setget set_font_size
func set_font_size(i:int, reset := true):
	if i == font_size: return
	current_font = (current_font.duplicate() as DynamicFont)
	current_font.size = i
	font_size = i
	add_font_override("normal_font", current_font)
	if reset: _reset_text()

var text_parts := []
var text_part_idx := 0

func advance() -> bool:
	text_part_idx += 1
	if text_part_idx >= text_parts.size(): return false
	_display_text(text_parts[text_part_idx])
	return true

func _ready():
	scroll_active = false
	color_regex.compile("\\[color=([#A-Za-z]+)\\](.*)\\[/color\\]")
	var font := get_font("normal_font")
	assert(font is DynamicFont, "GASRichTextLabel can only be used with DynamicFonts")
	current_font = (font as DynamicFont)
	font_size = current_font.size
	if font_size < GASConfig.vision_minimum_font_size: set_font_size(GASConfig.vision_minimum_font_size, false)
	if font_size < 28: print("You should use a minimum of 28px for your font sizes. See: https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/")
	connect("resized", self, "_reset_text")
	wrap_text = bbcode_text if bbcode_enabled else text
	_reset_text()

func _reset_text(): # TODO: handle bbcode
	text_parts = []
	text_part_idx = 0
	var words := wrap_text.split(" ")
	var processing_text := ""
	for w in words:
		var new_text:String = w if processing_text == "" else ("%s %s" % [processing_text, w])
		if current_font.get_wordwrap_string_size(new_text, _real_width()).y <= _real_height():
			processing_text = new_text
		else:
			text_parts.append(processing_text)
			processing_text = w
	if processing_text != "": text_parts.append(processing_text)
	_display_text(text_parts[0])

func _display_text(t:String):
	if bbcode_enabled: bbcode_text = t
	else: text = t
