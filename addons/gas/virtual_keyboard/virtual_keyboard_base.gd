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
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export_category("Key Button Styles")
@export var custom_key_scene: PackedScene:
	set(value):
		custom_key_scene = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var minimum_key_size := Vector2(30.0, 30.0):
	set(value):
		minimum_key_size = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var custom_cursor_scene: PackedScene:
	set(value):
		custom_cursor_scene = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var show_empty_buttons := true:
	set(value):
		show_empty_buttons = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var expand_buttons := true:
	set(value):
		expand_buttons = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export_category("Keyboard Styles")
@export var horizontal_alignment := BoxContainer.AlignmentMode.ALIGNMENT_BEGIN:
	set(value):
		horizontal_alignment = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var columns_per_section := 5:
	set(value):
		columns_per_section = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

@export var layouts_to_show := 1:
	set(value):
		layouts_to_show = value
		if !Engine.is_editor_hint() && !is_inside_tree():
			return
		redraw_keyboard()

var _cursor: Control
var _position := Vector2i.ZERO
var _keys: Dictionary[Vector2i, GASVirtualKeyboardButtonBase] = {}

func _ready() -> void:
	redraw_keyboard()
	_draw_cursor()

func _input(event: InputEvent) -> void:
	var delta := GASInput.get_vector2i(event)
	if delta == Vector2i.ZERO:
		return
	var new_pos := _position + delta
	if _keys.has(new_pos):
		_position = new_pos
	#elif delta.y != 0 && _row_widths.has(new_pos.y):
		#_position = Vector2i(_row_widths[new_pos.y], new_pos.y)
	else:
		return
	_draw_cursor()

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
		hbox.add_child(_get_layout_vbox(layouts[next], i * columns_per_section))
	if visible:
		print(_keys.keys())

func _on_virtual_keyboard_key_pressed(keycode: Key) -> void:
	GASInput.simulate_keycode_press(keycode)

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

func _draw_cursor() -> void:
	if !_cursor:
		if custom_cursor_scene:
			_cursor = custom_cursor_scene.instantiate()
		else:
			_cursor = ColorRect.new()
			_cursor.mouse_filter = MOUSE_FILTER_IGNORE
			_cursor.color = Color(Color.YELLOW, 0.5)
			_cursor.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _cursor.is_inside_tree():
		_cursor.get_parent().remove_child(_cursor)
	if _keys.has(_position):
		_keys[_position].add_child(_cursor)
	else:
		print("Position %s not found!" % _position)

func _wipe_current_keyboard() -> void:
	_keys.clear()
	for i in get_children():
		remove_child(i)
		i.queue_free()

func _get_layout_vbox(layout: GASVirtualKeyboardLayout, x_offset := 0) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	container.size_flags_vertical = Container.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(100.0, 100.0)
	if !layout || layout.keys.size() == 0:
		return container
	var num_rows := 0
	var current_row: HBoxContainer = null
	var items_in_row := 0
	var active_items_in_row := 0
	for i in layout.keys.size():
		var key := layout.keys[i]
		var is_empty := key == null || key.display_text == ""
		if i == 0 || items_in_row >= columns_per_section || (is_empty && !show_empty_buttons):
			if current_row != null:
				_try_pad_row(current_row)
				container.add_child(current_row)
			current_row = _get_hbox()
			items_in_row = 0
			active_items_in_row = 0
			num_rows += 1
		items_in_row += 1
		if !is_empty || show_empty_buttons:
			var key_btn := _get_button(key)
			if !is_empty:
				key_btn.key_position = Vector2i(active_items_in_row + x_offset, num_rows - 1)
				_keys[key_btn.key_position] = key_btn
				active_items_in_row += 1
			current_row.add_child(key_btn)
	if show_empty_buttons && (layout.keys.size() % columns_per_section) != 0:
		items_in_row = current_row.get_child_count()
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
	b.virtual_keyboard_key_hovered.connect(_on_button_hovered)
	b.virtual_keyboard_key_pressed.connect(_on_virtual_keyboard_key_pressed)
	b.virtual_keyboard_custom_action_pressed.connect(_on_virtual_keyboard_custom_pressed)
	return b

func _on_button_hovered(btn: GASVirtualKeyboardButtonBase) -> void:
	_position = btn.key_position
	_draw_cursor()

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
