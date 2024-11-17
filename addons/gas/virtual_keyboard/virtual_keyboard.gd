@tool
class_name GASVirtualKeyboard extends MarginContainer

signal key_pressed(s)
signal new_value(s: String)
signal confirm(s)
signal backspace

@export var cursor_scene: PackedScene# = preload("res://addons/keyboard_daisy/DefaultCursor.tscn"): set = set_cursor_scene
@export var backspace_action := "ui_cancel"
@export var sections: Array[String] = [ # (Array,String)
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	"abcdefghijklmnopqrstuvwxyz",
	"1234567890?!-~.,/*"
]
@export var columns_per_section := 5:
	set(value):
		columns_per_section = value
		reset_sections()

@export var split_into_sections := 0:
	set(value):
		split_into_sections = value
		reset_sections()

@export var min_rows := 6:
	set(value):
		min_rows = value
		reset_sections()

@export var fill_in_last_row := true:
	set(value):
		fill_in_last_row = value
		reset_sections()

@export var min_key_size := Vector2(30.0, 30.0):
	set(value):
		min_key_size = value
		reset_sections()

@export var special_options: Array[int] = [1, 2, 0]: # TODO: make these enums
	set(value):
		special_options = value
		reset_sections()

@export var separate_special_options := false:
	set(value):
		separate_special_options = value
		reset_sections()

@export var confirm_name := "OK":
	set(value):
		confirm_name = value
		reset_sections()

@export var space_name := "SPACE":
	set(value):
		space_name = value
		reset_sections()

@export var delete_name := "BACK":
	set(value):
		delete_name = value
		reset_sections()

@export var switch_names := ["ABC", "abc"]:
	set(value):
		switch_names = value
		reset_sections()

var value := ""
var cursor: CanvasItem
var cursor_position := Vector2i.ZERO
var main_section: Container
var inner_sections: Array[VBoxContainer] = []
var current_division := 0
var num_divisions := 0

func _ready():
	size_flags_horizontal = Container.SIZE_EXPAND_FILL
	size_flags_vertical = Container.SIZE_EXPAND_FILL
	reset_sections()
	cursor = cursor_scene.instantiate()
	move_cursor(cursor_position, true)

func set_cursor_scene(c: PackedScene):
	cursor_scene = c
	if cursor != null:
		remove_child(cursor)
		cursor.queue_free()
		cursor = cursor_scene.instantiate()
		move_cursor(cursor_position, true)

func _input(event: InputEvent):
	var delta := Vector2i.ZERO
	if event.is_action_pressed("ui_left"):
		delta.x = -1
	elif event.is_action_pressed("ui_right"):
		delta.x = 1
	if event.is_action_pressed("ui_up"):
		delta.y = -1
	elif event.is_action_pressed("ui_down"):
		delta.y = 1
	if delta.length() > 0:
		var new_position := cursor_position + delta
		var max_x := columns_per_section * inner_sections.size() - 1
		if new_position.x < 0: new_position.x = max_x
		elif new_position.x > max_x: new_position.x = 0
		if move_cursor(new_position):
			cursor_position = new_position
			if cursor.get_parent().disabled:
				var found_new_spot := false
				var forward := new_position
				var steps := max_x
				while steps > 0:
					steps -= 1
					forward += delta
					if forward.x < 0:
						forward.x = max_x
					elif forward.x > max_x:
						forward.x = 0
					var b := peek_cursor(forward)
					if b == null:
						break
					if !b.disabled:
						found_new_spot = true
						break
				if found_new_spot:
					move_cursor(forward)
					cursor_position = forward
	if event.is_action_pressed("ui_accept"):
		_on_key_press(cursor.get_parent())
	elif backspace_action != "" && event.is_action_pressed(backspace_action):
		_backspace()

func move_cursor(new_position: Vector2i, is_new := false) -> bool:
	var b := peek_cursor(new_position)
	if b == null:
		return false
	if !is_new:
		cursor.get_parent().remove_child(cursor)
	b.add_child(cursor)
	cursor.set_deferred("size", b.size)
	return true

func peek_cursor(new_position: Vector2i) -> Button:
	if new_position.x < 0 || new_position.y < 0:
		return null
	var appropriate_section := floori(new_position.x / columns_per_section)
	if appropriate_section >= inner_sections.size():
		return null
	var actual_x := new_position.x % columns_per_section
	var section := inner_sections[appropriate_section]
	if new_position.y >= section.get_child_count():
		return null
	var row:HBoxContainer = section.get_child(new_position.y)
	if actual_x >= row.get_child_count():
		return null
	return row.get_child(actual_x) as Button

func reset_sections():
	if !is_inside_tree():
		return
	for i in get_children():
		remove_child(i)
		i.queue_free()
	inner_sections = []
	var num_sections := sections.size()
	if num_sections == 0:
		return
	if num_sections == 1:
		main_section = get_section(sections[0], true)
		add_child(main_section)
		inner_sections.append(main_section)
	else:
		main_section = _get_hbox()
		add_child(main_section)
		var relevant_sections: Array[String] = []
		if split_into_sections == 0:
			relevant_sections = sections
		else:
			num_divisions = ceili(float(num_sections) / split_into_sections)
			for i in split_into_sections:
				relevant_sections.append(sections[current_division * split_into_sections + i])
		var last_section := relevant_sections.size() - 1
		for i in relevant_sections.size():
			if i > 0: main_section.add_child(VSeparator.new())
			var inner_section := get_section(relevant_sections[i], i == last_section)
			main_section.add_child(inner_section)
			inner_sections.append(inner_section)

func get_section(keys: String, last_section: bool) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	container.size_flags_vertical = Container.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(100.0, 100.0)
	if keys == "":
		return container
	var num_rows := 0
	var current_row: HBoxContainer = null
	for i in keys.length():
		if i % columns_per_section == 0:
			if current_row != null:
				container.add_child(current_row)
			current_row = _get_hbox()
			num_rows += 1
		current_row.add_child(_get_button(keys[i]))
	if fill_in_last_row && (keys.length() % columns_per_section) != 0:
		var remaining_keys := columns_per_section - (keys.length() % columns_per_section)
		for i in remaining_keys:
			current_row.add_child(_get_button())
	container.add_child(current_row)
	var last_row_is_all_blank := false
	if num_rows < min_rows:
		for i in range(min_rows - num_rows):
			current_row = _get_hbox()
			for j in columns_per_section:
				current_row.add_child(_get_button())
			container.add_child(current_row)
			last_row_is_all_blank = true
	if last_section && special_options.size() > 0:
		var last_row_count := current_row.get_child_count()
		var special_start := last_row_count - special_options.size()
		var last_relevant_button: Button = current_row.get_child(special_start)
		if !last_row_is_all_blank && (separate_special_options || !last_relevant_button.disabled): # need to make a new row
			current_row = _get_hbox()
			for i in columns_per_section:
				if i >= special_start:
					current_row.add_child(_get_special_button(special_options[i - special_start]))
				else: current_row.add_child(_get_button())
			container.add_child(current_row)
		else: # can add to existing row
			for i in special_options.size():
				var node_to_remove := current_row.get_child(current_row.get_child_count() - 1)
				current_row.remove_child(node_to_remove)
				node_to_remove.queue_free()
			for s in special_options:
				current_row.add_child(_get_special_button(s))
	return container

func _get_hbox() -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	hb.size_flags_vertical = Container.SIZE_EXPAND_FILL
	return hb

func _get_special_button(type: int) -> Button:
	var custom_text := ""
	match type:
		0: custom_text = confirm_name
		1: custom_text = space_name
		2: custom_text = delete_name
		3: custom_text = switch_names[current_division]
	return _get_button(custom_text)

func _get_button(t := "") -> Button:
	var b := Button.new()
	b.text = t
	if t == "":
		b.disabled = true
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.size = min_key_size
	b.custom_minimum_size = min_key_size
	b.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	b.size_flags_vertical = Container.SIZE_EXPAND_FILL
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(_on_key_press.bind(b))
	b.mouse_entered.connect(_on_hover.bind(b))
	return b

func _on_hover(b: Button):
	if cursor == null:
		return
	cursor.get_parent().remove_child(cursor)
	b.add_child(cursor)
	cursor.size = b.size

func _on_key_press(b: Button):
	for sn in switch_names:
		if b.text == sn:
			current_division = (current_division + 1) % num_divisions
			cursor.get_parent().remove_child(cursor)
			reset_sections()
			var potential_cursor_pos := _find_switch_key()
			cursor_position = potential_cursor_pos if potential_cursor_pos.x >= 0 else Vector2i.ZERO
			move_cursor(cursor_position, true)
			return
	match b.text:
		confirm_name:
			emit_signal("confirm", value)
		space_name:
			value += " "
			emit_signal("key_pressed", b.text)
			emit_signal("new_value", value)
		delete_name:
			_backspace()
		_:
			value += b.text
			emit_signal("key_pressed", b.text)
			emit_signal("new_value", value)

func _find_switch_key() -> Vector2i:
	var last_section := inner_sections[inner_sections.size() - 1]
	var num_rows := last_section.get_child_count() - 1
	var last_row := last_section.get_child(num_rows)
	var last_buttons := last_row.get_children()
	for i in last_buttons.size():
		var b: Button = last_buttons[i]
		if b.disabled:
			continue
		if last_buttons[i].text == switch_names[current_division]:
			return Vector2i(columns_per_section * (split_into_sections - 1) + i, num_rows)
	return Vector2i(-1, -1)

func _backspace() -> void:
	value = value.substr(0, value.length() - 1)
	backspace.emit()
	new_value.emit(value)
