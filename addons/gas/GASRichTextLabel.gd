extends RichTextLabel

# Font.get_wordwrap_string_size doesn't seem to be accurate when using size as the
# bounds, and this padding seems to fix that. not sure if these numbers will always work.
@export var text_padding := Vector2(8.0, 4.0)
func _real_width() -> float: return size.x - text_padding.x * (font_size / 16.0)
func _real_height() -> float: return size.y - text_padding.y * (font_size / 16.0)

var wrap_text: String:
	set(t):
		wrap_text = t
		if bbcode_enabled:
			text = t
		else:
			text = t
		_reset_text()
var translation_key:String:
	set(t):
		translation_key = t
		set_text(tr(t)) 

@onready var bbcode_open := RegEx.new()
@onready var bbcode_close := RegEx.new()
var font_size: int:
	get:
		return font_size # TODOConverter40 Non existent get function 
	set(i):
		font_size = i

var text_parts := []
var text_part_idx := 0
var open_tags := []

func advance() -> bool:
	text_part_idx += 1
	if text_part_idx >= text_parts.size(): return false
	_display_text(text_parts[text_part_idx])
	return true

func _ready():
	scroll_active = false
	bbcode_open.compile("\\[([a-z]+)(\\=[\\w\\d\\.\\,\\\\/\\\"\\'\\#\\,\\-]*)?\\]")
	bbcode_close.compile("\\[/([a-z]+)\\]")
	font_size = get_theme_default_font_size()
	if font_size < GASConfig.vision_minimum_font_size:
		font_size = GASConfig.vision_minimum_font_size
	if font_size < 28: print("You should use a minimum of 28px for your font sizes. See: https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/")
	resized.connect(_reset_text)
	wrap_text = text if bbcode_enabled else text
	_reset_text()

func _reset_text():
	text_parts = []
	text_part_idx = 0
	var words := wrap_text.split(" ")
	var raw_current_text := ""
	var current_text := ""
	for raw_word in words:
		var parse_info_array := _try_parse_bbcode(raw_word)
		var last_parse_info:Dictionary = parse_info_array[parse_info_array.size() - 1]
		var word:String = last_parse_info["clean_word"]
		
		var raw_next:String = raw_word if raw_current_text == "" else ("%s %s" % [raw_current_text, raw_word])
		var next:String = word if current_text == "" else ("%s %s" % [current_text, word])
		
		var current_font := get_theme_default_font()
		if current_font.get_multiline_string_size(next, _real_width()).y <= _real_height():
			raw_current_text = raw_next
			current_text = next
		else:
			raw_current_text = "%s%s" % [raw_current_text, _close_open_tags()]
			text_parts.append(raw_current_text)
			raw_current_text = "%s%s" % [_get_open_tags(), raw_word]
			current_text = word
		for parse_info in parse_info_array:
			if parse_info["match"] == "open":
				open_tags.append(parse_info)
			elif parse_info["match"] == "close":
				open_tags.remove_at(parse_info["tag_index"])
	if raw_current_text != "": text_parts.append(raw_current_text)
	_display_text(text_parts[0])

func _try_parse_bbcode(w: String) -> Array:
	if !bbcode_enabled: return [{ "match": "", "clean_word": w }]
	var potential_open := bbcode_open.search(w)
	var potential_close := bbcode_close.search(w)
	if potential_open && potential_close:
		var clean_word := w.replace(potential_open.get_string(), "").replace(potential_close.get_string(), "")
		return [{ "match": "", "clean_word": _try_parse_bbcode(clean_word)[0]["clean_word"] }]
	if potential_open:
		var tag_name:String = potential_open.get_string(1)
		var full_tag:String = potential_open.get_string()
		var clean_word := w.replace(full_tag, "")
		var return_val := [{
			"match": "open",
			"clean_word": clean_word,
			"tag": tag_name,
			"full_tag": full_tag
		}]
		var potential_val := _try_parse_bbcode(clean_word)
		if potential_val[0]["match"] != "":
			return_val.append_array(potential_val)
		return return_val
	if potential_close:
		var tag_name:String = potential_close.get_string(1)
		for i in range(open_tags.size() - 1, -1, -1):
			if open_tags[i].tag != tag_name: continue
			var clean_word := w.replace(potential_close.get_string(), "")
			var return_val := [{
				"match": "close",
				"clean_word": clean_word,
				"tag": tag_name,
				"tag_index": i
			}]
			var potential_val := _try_parse_bbcode(clean_word)
			if potential_val[0]["match"] != "":
				return_val.append_array(potential_val)
			return return_val
	return [{ "match": "", "clean_word": w }]

func _close_open_tags() -> String:
	if !bbcode_enabled || open_tags.size() == 0: return ""
	var closing_tags := ""
	for i in range(open_tags.size() - 1, -1, -1):
		closing_tags += "[/%s]" % open_tags[i]["tag"]
	return closing_tags
func _get_open_tags() -> String:
	if !bbcode_enabled || open_tags.size() == 0: return ""
	var opening_tags := ""
	for i in range(0, open_tags.size(), 1):
		opening_tags += open_tags[i]["full_tag"]
	return opening_tags

func _display_text(t:String):
	if bbcode_enabled: text = t
	else: text = t
