@tool
class_name GASVirtualKeyboardBase extends MarginContainer

signal keyboard_signal_emitted(value: String)

@export var layouts: Array[GASVirtualKeyboardLayout] = []

@export var current_layout_index := 0:
	set(value):
		if value >= layouts.size():
			current_layout_index = 0
		elif value < 0:
			current_layout_index = layouts.size() - 1
		else:
			current_layout_index = value
		redraw_keyboard()

@export var custom_key_scene: PackedScene
@export var minimum_key_size := Vector2(30.0, 30.0)

@export var show_empty_buttons := true:
	set(value):
		show_empty_buttons = value
		redraw_keyboard()

@export var expand_buttons := true:
	set(value):
		expand_buttons = value
		redraw_keyboard()

@export var horizontal_alignment := BoxContainer.AlignmentMode.ALIGNMENT_BEGIN:
	set(value):
		horizontal_alignment = value
		redraw_keyboard()

@export var columns_per_section := 5:
	set(value):
		columns_per_section = value
		redraw_keyboard()

@export var layouts_to_show := 1:
	set(value):
		layouts_to_show = value
		redraw_keyboard()

func _ready() -> void:
	redraw_keyboard()

func redraw_keyboard() -> void:
	if !is_inside_tree():
		return
	_wipe_current_keyboard()
	if layouts.size() == 0:
		return
	var hbox := HBoxContainer.new()
	add_child(hbox)
	for i in layouts_to_show:
		if i > 0:
			hbox.add_child(VSeparator.new())
		var next := (current_layout_index + i) % layouts.size()
		hbox.add_child(_get_layout_vbox(layouts[next]))

func _on_virtual_keyboard_key_pressed(keycode: Key) -> void:
	var e := InputEventKey.new()
	e.keycode = keycode
	e.pressed = true
	e.unicode = keycode
	Input.parse_input_event(e)

func _on_virtual_keyboard_custom_pressed(value: String) -> void:
	if value == "shift_layout":
		current_layout_index += 1
	elif value.begins_with("action:"):
		var action_name := value.split(":")[1]
		var input_actions := InputMap.action_get_events(action_name)
		for a in input_actions:
			var ak := a as InputEventKey
			if ak:
				_on_virtual_keyboard_key_pressed(ak.keycode)
				return
		Input.parse_input_event(input_actions[0])
	else:
		keyboard_signal_emitted.emit(value)

func _wipe_current_keyboard() -> void:
	for i in get_children():
		remove_child(i)
		i.queue_free()

func _get_layout_vbox(layout: GASVirtualKeyboardLayout) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	container.size_flags_vertical = Container.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(100.0, 100.0)
	if !layout || layout.keys.size() == 0:
		return container
	var num_rows := 0
	var current_row: HBoxContainer = null
	var items_in_row := 0
	for i in layout.keys.size():
		var key := layout.keys[i]
		var is_empty := key == null || key.display_text == ""
		if i == 0 || items_in_row >= columns_per_section || (is_empty && !show_empty_buttons):
			if current_row != null:
				_try_pad_row(current_row)
				container.add_child(current_row)
			current_row = _get_hbox()
			items_in_row = 0
			num_rows += 1
		items_in_row += 1
		if !is_empty || show_empty_buttons:
			current_row.add_child(_get_button(key))
	if show_empty_buttons && (layout.keys.size() % columns_per_section) != 0:
		var remaining_keys := columns_per_section - (layout.keys.size() % columns_per_section)
		for i in remaining_keys:
			current_row.add_child(_get_button())
	_try_pad_row(current_row)
	container.add_child(current_row)
	return container

func _get_hbox() -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.alignment = horizontal_alignment
	hb.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	hb.size_flags_vertical = Container.SIZE_EXPAND_FILL
	return hb

func _get_button(key: GASVirtualKeyboardKey = null) -> GASVirtualKeyboardButtonBase:
	var b: GASVirtualKeyboardButtonBase
	if custom_key_scene:
		b = custom_key_scene.instantiate()
	else:
		b = GASVirtualKeyboardButton.new(minimum_key_size)
	b.key_info = key
	b.virtual_keyboard_key_pressed.connect(_on_virtual_keyboard_key_pressed)
	b.virtual_keyboard_custom_action_pressed.connect(_on_virtual_keyboard_custom_pressed)
	return b

func _try_pad_row(row: HBoxContainer) -> void:
	if expand_buttons:
		return
	if horizontal_alignment != BoxContainer.AlignmentMode.ALIGNMENT_END:
		row.add_child(_get_spacer())
	if horizontal_alignment != BoxContainer.AlignmentMode.ALIGNMENT_BEGIN:
		var open := _get_spacer()
		row.add_child(open)
		row.move_child(open, 0)

func _get_spacer(theme_type_variation := "ButtonPadding") -> VSeparator:
	var v := VSeparator.new()
	v.theme_type_variation = theme_type_variation
	v.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	return v
