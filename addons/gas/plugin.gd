@tool
extends EditorPlugin

const _AUDIT_SCENE := preload("res://addons/gas/audit/audit_screen.tscn")

var _main_panel: GASAuditScreen

func _enter_tree():
	_main_panel = _AUDIT_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_main_panel)
	_make_visible(false)
	add_autoload_singleton("GASConfig", "res://addons/gas/gas_config.gd")
	add_autoload_singleton("GASInput", "res://addons/gas/gas_input.gd")
	add_autoload_singleton("GASText", "res://addons/gas/gas_text.gd")
	add_autoload_singleton("GASTime", "res://addons/gas/gas_time.gd")
	add_autoload_singleton("GASUtils", "res://addons/gas/gas_utils.gd")
	ProjectSettings.set(GASConstant.AUTOSAVE_SETTINGS, true)
	ProjectSettings.set(GASConstant.AUDIT_IGNORES, [])
	ProjectSettings.set(GASConstant.AUDIT_PARSERS, [
		"res://addons/gas/audit/parsers/audit_scene_parser.gd"
	])
	ProjectSettings.set(GASConstant.WARN_ON_FONT_SIZE, true)
	ProjectSettings.set(GASConstant.USE_GAS_TIME, true)
	ProjectSettings.set(GASConstant.TEXT_HIGHLIGHT_KEYS, ["person", "place", "thing"])
	add_custom_type(
		"AccessibleRichTextLabel", "RichTextLabel",
		load("res://addons/gas/gas_richtextlabel.gd"),
		load("res://addons/gas/icons/gas_rich_text_label.svg")
	)
	add_custom_type(
		"AccessibleLabel", "Label",
		load("res://addons/gas/gas_label.gd"),
		load("res://addons/gas/icons/gas_label.svg")
	)
	add_custom_type(
		"AccessibleScrollContainer", "ScrollContainer",
		load("res://addons/gas/gas_scroll_container.gd"),
		load("res://addons/gas/icons/gas_scroll_container.svg")
	)
	InputMap.add_action("gas_scroll_down")
	InputMap.action_add_event("gas_scroll_down", _get_keypress(KEY_K))
	InputMap.add_action("gas_scroll_up")
	InputMap.action_add_event("gas_scroll_up", _get_keypress(KEY_I))
	scene_changed.connect(_on_scene_changed)

func _exit_tree():
	if _main_panel:
		_main_panel.queue_free()
	scene_changed.disconnect(_on_scene_changed)
	remove_autoload_singleton("GASInput")
	remove_autoload_singleton("GASConfig")
	remove_autoload_singleton("GASText")
	remove_autoload_singleton("GASTime")
	remove_autoload_singleton("GASUtils")
	ProjectSettings.clear(GASConstant.AUTOSAVE_SETTINGS)
	ProjectSettings.clear(GASConstant.WARN_ON_FONT_SIZE)
	ProjectSettings.clear(GASConstant.USE_GAS_TIME)
	ProjectSettings.clear(GASConstant.TEXT_HIGHLIGHT_KEYS)
	ProjectSettings.clear(GASConstant.AUDIT_PARSERS)
	ProjectSettings.clear(GASConstant.AUDIT_IGNORES)
	remove_custom_type("AccessibleRichTextLabel")
	remove_custom_type("AccessibleLabel")
	remove_custom_type("AccessibleScrollContainer")
	InputMap.erase_action("gas_scroll_down")
	InputMap.erase_action("gas_scroll_up")

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "Accessibility"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("CryptoKey", "EditorIcons")

func _get_keypress(keycode: Key) -> InputEventKey:
	var iek := InputEventKey.new()
	iek.keycode = keycode
	return iek

func _make_visible(visible: bool) -> void:
	if _main_panel:
		_main_panel.visible = visible

func _on_scene_changed(root: Node) -> void:
	if _main_panel && root && root.scene_file_path != "":
		_main_panel.force_path_change(root.scene_file_path)
