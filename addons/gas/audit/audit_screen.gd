@tool
class_name GASAuditScreen extends Control

const _AUDIT_ROW_SCENE := preload("res://addons/gas/audit/audit_row.tscn")

var _parsers: Array[GASAuditFileParser] = []

@onready var _file_path: TextEdit = %FilePath
@onready var _browse_button: Button = %BrowseButton
@onready var _audit_button: Button = %AuditButton
@onready var _file_dialog: FileDialog = %FileDialog
@onready var _error_message: AccessibleLabel = %ErrorMessage
@onready var _records: VBoxContainer = %Records

func _ready() -> void:
	_browse_button.pressed.connect(_file_dialog.popup)
	_file_path.text_changed.connect(_on_path_changed)
	_file_dialog.file_selected.connect(func(path: String) -> void:
		_file_path.text = path
	)
	_audit_button.pressed.connect(_on_try_audit)
	_load_parsers.call_deferred()

func _load_parsers() -> void:
	var parsers: Array = ProjectSettings.get_setting(GASConstant.AUDIT_PARSERS, [])
	for p: String in parsers:
		if !FileAccess.file_exists(p):
			printerr("Invalid parser path: %s" % p)
			continue
		var maybe_parser := load(p)
		if maybe_parser is not GDScript:
			printerr("Parser should be a script file: %s" % p)
			continue
		var parser := (maybe_parser as GDScript).new()
		if parser is not GASAuditFileParser:
			printerr("Parser script does not inherit from GASAuditFileParser: %s" % p)
			continue
		_parsers.append(parser)
	if _parsers.size() == 0:
		printerr("No parsers found, audit will not work. Please specify some parsers in Project Settings, or disable and re-enable the Godot Accessibility Suite plugin to restore the default parsers.")
	else:
		print("Parsers loaded.")

func _on_try_audit() -> void:
	if !_test_file():
		return
	var file := load(_file_path.text)
	if !file:
		_error_message.visible = true
		_error_message.text = "Couldn't read file %s." % _file_path.text
		return
	for p in _records.get_children():
		p.queue_free()
	var parsed := false
	for p in _parsers:
		if p.can_parse(file):
			parsed = true
			_parse(p, file)
	if !parsed:
		_error_message.visible = true
		_error_message.text = "No parser exists to handle this file's format."

func _parse(parser: GASAuditFileParser, file: Resource) -> void:
	var results := parser.parse(file)
	var ignored: Array = ProjectSettings.get_setting(GASConstant.AUDIT_IGNORES, [])
	for r in results:
		if ignored.has(r.key):
			r.ignored = true
	results.sort_custom(func(a: GASAuditEntry, b: GASAuditEntry) -> bool:
		if a.ignored && !b.ignored:
			return false
		elif !a.ignored && b.ignored:
			return true
		return a.grade_as_int() < b.grade_as_int()
	)
	for r in results:
		var a: GASAuditRow = _AUDIT_ROW_SCENE.instantiate()
		_records.add_child(a)
		a.entry = r

func force_path_change(path: String) -> void:
	_file_path.text = path

func _on_path_changed() -> void:
	print(get_tree().edited_scene_root.scene_file_path)
	_test_file()

func _test_file() -> bool:
	if !FileAccess.file_exists(_file_path.text):
		_error_message.visible = true
		_error_message.text = "File %s not found." % _file_path.text
		return false
	_error_message.visible = false
	return true
