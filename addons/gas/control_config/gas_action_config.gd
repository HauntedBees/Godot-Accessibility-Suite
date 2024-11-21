@tool
class_name GASActionConfig extends Control

const _UI_DIRECTIONS: Array[String] = ["ui_left", "ui_right", "ui_up", "ui_down"]
const _UI_SPECIAL: Array[String] = ["ui_accept", "ui_select", "ui_cancel"]
const _DEFAULT_INPUT_MAP_SCENE := preload("res://addons/gas/control_config/gas_input_map_display.tscn")

enum DisplayType {
	# Show icons for whatever input method the player is currently using
	CurrentInput,
	# Show icons for keyboard, even if a joypad is plugged in
	ForceKeyboard,
	# Show icons for joypad, even if none are plugged in
	ForceJoypad
}

@export var input_prompt_scene: PackedScene = _DEFAULT_INPUT_MAP_SCENE:
	set(v):
		input_prompt_scene = v
		_redraw_inputs()

@export var input_type := DisplayType.CurrentInput:
	set(v):
		input_type = v
		_redraw_inputs()

@export var action_display_names: Array[String] = []:
	set(v):
		action_display_names = v
		_redraw_inputs()
@export var action_input_maps: Array[String] = []:
	set(v):
		action_input_maps = v
		_redraw_inputs()

@export_range(1, 3) var number_of_columns := 1:
	set(v):
		number_of_columns = v
		_redraw_inputs()

@export_category("Auto-populate Actions")

## Whether or not to generate mappings for Godot's default actions like "ui_undo" and "ui_graph_delete"
@export var include_default_ui_actions := false
## Whether or not to generate mappings for Godot's default direction actions like "ui_left" and "ui_right"
@export var include_ui_directions := true
## Whether or not to generate mappings for Godot's default "ui_select", "ui_cancel", and "ui_accept" actions
@export var include_ui_select_cancel := true
## Populate the Actions dictionary with your current Input Map-defined actions
@export_tool_button("Populate Actions", "InputEventAction") var _p := _prepopulate_actions

@onready var _column_container: HBoxContainer = %Container

@onready var _popup: ConfirmationDialog = $ConfirmationDialog
@onready var _new_button: TextureRect = $ConfirmationDialog/VBoxContainer/CenterContainer/NewButton

var _selected_input: GASInputMapDisplayBase
var _last_event_pressed: InputEvent = null
var _in_popup := false

func _ready() -> void:
	_redraw_inputs()

func _redraw_inputs() -> void:
	if !is_inside_tree():
		return
	for c in _column_container.get_children():
		_column_container.remove_child(c)
		c.queue_free()
	var cols: Array[VBoxContainer] = []
	for i in number_of_columns:
		var c := VBoxContainer.new()
		c.size_flags_horizontal = Control.SIZE_EXPAND
		_column_container.add_child(c)
		cols.append(c)
	for i in action_display_names.size():
		var col := cols[i % number_of_columns]
		var input: GASInputMapDisplayBase = input_prompt_scene.instantiate()
		col.add_child(input)
		input.display_name = action_display_names[i]
		input.input_action = action_input_maps[i]
		input.selected.connect(_on_select_input)

func _on_select_input(s: GASInputMapDisplayBase) -> void:
	_selected_input = s
	_popup.popup_centered()
	_popup.title = "Edit '%s'" % s.display_name
	_new_button.texture = s.get_texture()
	_in_popup = true

func _on_confirmation_dialog_binding_changed(event: InputEvent) -> void:
	if !event || !_selected_input:
		return
	_last_event_pressed = event
	(_new_button.texture as AtlasTexture).region.position  = _selected_input.get_offset_from_input(event)

func _on_confirmation_dialog_canceled() -> void:
	_in_popup = false
	_selected_input = null
	_last_event_pressed = null

func _on_ConfirmationDialog_confirmed() -> void:
	GASInput.remap_action(_selected_input.input_action, _last_event_pressed)
	_selected_input.refresh_icon(GASInput.get_last_input_method())
	_on_confirmation_dialog_canceled()

func _prepopulate_actions() -> void:
	action_display_names = []
	action_input_maps = []
	for i in InputMap.get_actions():
		if i.begins_with("spatial_editor"):
			continue
		elif _UI_DIRECTIONS.has(i):
			if !include_ui_directions:
				continue
		elif _UI_SPECIAL.has(i):
			if !include_ui_select_cancel:
				continue
		elif i.begins_with("ui_") && !include_default_ui_actions:
			continue
		action_display_names.append(i.capitalize())
		action_input_maps.append(i)
