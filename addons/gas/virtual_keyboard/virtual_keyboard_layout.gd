@tool
class_name GASVirtualKeyboardLayout extends Resource

## The keys that will be used on this keyboard layout.
@export var keys: Array[GASVirtualKeyboardKey] = []

@export_category("Quick Generation")

## If you wish to quickly generate a standard keyboard, simply type each key in the layout here,
## then click the "Generate Keyboard" button to create the appropriate GASVirtualKeyboardKey
## values for the "Keys" array. If you wish to have more elaborate keyboard keys, you'll need to
## configure those manually in the Keys array. "\n" will be treated as an empty key.
@export var keys_string: String

## Populate the Keys array with keys based on the Keys String value. This will replace any
## currently defined Keys in that array.
@export_tool_button("Generate Keyboard", "InputEventKey") var _k := _generate_keys

func _generate_keys() -> void:
	if !keys_string || keys_string.strip_edges() == "":
		return
	keys = []
	var is_escape_character := false
	for k in keys_string:
		var current_key := k
		if k == "\\" && !is_escape_character:
			is_escape_character = true
			continue
		elif is_escape_character:
			match k:
				_: current_key = ("\\%s" % k).c_unescape()
			is_escape_character = false
		var vkk := GASVirtualKeyboardKey.new()
		vkk.display_text = current_key
		keys.append(vkk)
