tool
extends Control

const control_atlas: AtlasTexture = preload("res://addons/gas/ControlConfig/IconAtlas.tres")

export(int, 1, 3) var number_of_columns := 1 setget _set_column_count
func _set_column_count(i: int) -> void:
	number_of_columns = i
	_generate_controls_display()
export(Dictionary) var action_names := {} setget _set_action_names
func _set_action_names(d: Dictionary) -> void:
	action_names = d
	_generate_controls_display()
export(Array) var sort_order := [] setget _set_sort_order
func _set_sort_order(a: Array) -> void:
	sort_order = a
	_generate_controls_display()
export(bool) var hide_default_ui_actions := false setget _set_hide_default
func _set_hide_default(b: bool) -> void:
	hide_default_ui_actions = b
	_generate_controls_display()

onready var _left_column: VBoxContainer = $Container/Left
onready var _middle_column: VBoxContainer = $Container/Middle
onready var _right_column: VBoxContainer = $Container/Right
onready var _popup: ConfirmationDialog = $ConfirmationDialog
onready var _new_button: TextureRect = $ConfirmationDialog/VBoxContainer/CenterContainer/NewButton

var _using_gamepad := false
var _target_button: Button = null
var _target_action := ""
var _target_event: InputEvent = null
var _in_popup := false

func _ready() -> void:
	_using_gamepad = Input.get_connected_joypads().size() > 0
	_configure_display_settings()
	_generate_controls_display()

func _unhandled_input(event: InputEvent) -> void:
	if !_in_popup || event is InputEventMouseMotion:
		return
	_target_event = event
	_new_button.texture = _get_icon_from_input(event)

func _input(event: InputEvent) -> void:
	if !_in_popup || event is InputEventMouseMotion:
		return
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		if _using_gamepad:
			return
		_using_gamepad = true
	elif event is InputEventMouseButton || event is InputEventKey:
		if !_using_gamepad:
			return
		_using_gamepad = false
	_generate_controls_display()

func _generate_controls_display() -> void:
	if !is_inside_tree() || _left_column == null || _middle_column == null || _right_column == null:
		return
	for c in _left_column.get_children():
		c.queue_free()
	for c in _middle_column.get_children():
		c.queue_free()
	for c in _right_column.get_children():
		c.queue_free()
	var columns := []
	match number_of_columns:
		1:
			columns = [_middle_column]
			_left_column.visible = false
			_middle_column.visible = true
			_right_column.visible = false
		2:
			columns = [_left_column, _right_column]
			_left_column.visible = true
			_middle_column.visible = false
			_right_column.visible = true
		3:
			columns = [_left_column, _middle_column, _right_column]
			_left_column.visible = true
			_middle_column.visible = true
			_right_column.visible = true
	if action_names.size() == 0:
		_configure_display_settings(false)
	for i in sort_order.size():
		if hide_default_ui_actions && sort_order[i].find("ui_") == 0:
			continue
		var column: VBoxContainer = columns[i % number_of_columns]
		column.add_child(_get_control(sort_order[i]))

func _get_control(action_key: String) -> HBoxContainer:
	var display_name: String = action_names[action_key]
	var c := HBoxContainer.new()
	var l := Label.new()
	l.rect_min_size = Vector2(100.0, 60.0)
	l.valign = Label.VALIGN_CENTER
	l.align = Label.ALIGN_RIGHT
	l.text = display_name
	c.add_child(l)
	var b := Button.new()
	b.rect_min_size = Vector2(120.0, 60.0)
	b.icon = _get_icon(action_key)
	b.expand_icon = true
	b.flat = true
	b.connect("pressed", self, "_change_control", [b, display_name, action_key])
	c.add_child(b)
	return c
func _get_icon(action_key: String) -> AtlasTexture:
	var action: InputEvent = _get_first_action(action_key, _using_gamepad)
	return _get_icon_from_input(action)
func _get_icon_from_input(action: InputEvent) -> AtlasTexture:
	var c: AtlasTexture = control_atlas.duplicate()
	var idx := 0
	if action == null:
		idx = 208
	elif action is InputEventMouseButton:
		var am := action as InputEventMouseButton
		if am.button_index > 8:
			idx = 10
		else:
			idx = 2 + am.button_index
	elif action is InputEventKey:
		var ak := action as InputEventKey
		if ak.scancode >= 16777217:
			idx = 69 + ak.scancode - 16777217
		else:
			idx = ak.scancode - 32
	elif action is InputEventJoypadButton:
		var ab := action as InputEventJoypadButton
		if ab.button_index > 15:
			idx = 31
		else:
			idx = 128 + ab.button_index
			var name := Input.get_joy_name(0).to_lower()
			if name.begins_with("ps4") || name.begins_with("ps5") || name.find("sony") >= 0 || name.find("dualshock") >= 0:
				idx += 16
			elif name.find("nintendo") >= 0 || name.find("pro controller") >= 0:
				idx += 32
			elif name.find("joycon") >= 0:
				idx += 48
	elif action is InputEventJoypadMotion:
		var am := action as InputEventJoypadMotion
		if am.axis > 3:
			idx = 31
		else:
			idx = 192 + am.axis
	c.region.position = Vector2(128 * (idx % 16), 128 * floor(idx / 16.0))
	return c
func _get_first_action(action_key: String, prefer_gamepad: bool) -> InputEvent:
	var actions := InputMap.get_action_list(action_key)
	for a in actions:
		var is_gamepad := a is InputEventJoypadMotion || a is InputEventJoypadButton
		if (is_gamepad && prefer_gamepad) || (!is_gamepad && !prefer_gamepad):
			return a
	return null

func _change_control(button: Button, display_name: String, action: String) -> void:
	_target_button = button
	_target_action = action
	_popup.popup_centered()
	_popup.window_title = "Edit '%s'" % display_name
	_new_button.texture = _get_icon(action)
	_in_popup = true

func _on_ConfirmationDialog_popup_hide() -> void:
	_in_popup = false

func _on_ConfirmationDialog_confirmed() -> void:
	GASInput.remap_action(_target_action, _target_event)
	_target_button.icon = _new_button.texture
	_target_button = null
	_target_event = null
	_target_action = ""

# TODO: remove old ones, too?
func _configure_display_settings(editor_only := true) -> void:
	if editor_only && !Engine.editor_hint:
		return
	var actions := InputMap.get_actions()
	for a in actions:
		if !action_names.has(a):
			action_names[a] = a
		if !sort_order.has(a):
			sort_order.append(a)
