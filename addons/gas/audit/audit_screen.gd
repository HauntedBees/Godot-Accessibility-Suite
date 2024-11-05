@tool
class_name GASAuditScreen extends Control

const _AUDIT_ROW_SCENE := preload("res://addons/gas/audit/audit_row.tscn")
const _INVALID_PATH_ICON := preload("res://addons/gas/icons/hazard-sign.png")
const _VALID_PATH_ICON := preload("res://addons/gas/icons/confirmed.png")

var _parsers: Array[GASAuditFileParser] = []
var _time_since_last_parse := 0.0
var _no_results := false

@onready var _file_path: TextEdit = %FilePath
@onready var _browse_button: Button = %BrowseButton
@onready var _audit_button: Button = %AuditButton
@onready var _file_dialog: FileDialog = %FileDialog
@onready var _error_message: AccessibleLabel = %ErrorMessage
@onready var _records: VBoxContainer = %Records
@onready var _results_label: Label = %ResultsLabel
@onready var _results_timer: Label = %ResultsTimer
@onready var _path_check_icon: TextureRect = %PathCheckIcon
@onready var _heading: HBoxContainer = %Heading
@onready var _support_string: Label = %SupportString

func _ready() -> void:
	_browse_button.pressed.connect(_file_dialog.popup)
	_file_path.text_changed.connect(_test_file)
	_file_dialog.file_selected.connect(func(path: String) -> void:
		_file_path.text = path
		_test_file()
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
		_support_string.text = "No parsers found."
	else:
		print("Parsers loaded.")
		var supported: PackedStringArray = []
		for p in _parsers:
			supported.append(p.get_supported_types())
		_support_string.text = "Supports %s." % ", ".join(supported)

func _on_try_audit() -> void:
	if !_test_file():
		return
	var file := load(_file_path.text)
	_error_message.visible = false
	if !file:
		_error_message.visible = true
		_error_message.text = "Couldn't read file %s." % _file_path.text
		_heading.visible = false
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
		_heading.visible = false
	elif _no_results:
		_error_message.visible = true
		_error_message.text = "No accessibility issues found in this file."
		_heading.visible = false
	else:
		_heading.visible = true

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
	_no_results = results.size() == 0
	_results_label.text = "Audit Results for %s" % file.resource_path.split("/")[-1]
	_results_timer.text = "(Just Now)"
	_results_timer.visible = true
	_time_since_last_parse = 0.0

func _process(delta: float) -> void:
	_time_since_last_parse += delta
	if _time_since_last_parse >= 60.0:
		_results_timer.text = "(%dm ago)" % floori(_time_since_last_parse / 60.0)
	elif _time_since_last_parse >= 10.0:
		_results_timer.text = "(%ds ago)" % (10 * floori(_time_since_last_parse / 10.0))

func force_path_change(path: String) -> void:
	_file_path.text = path
	_test_file()

func _test_file() -> bool:
	if !FileAccess.file_exists(_file_path.text):
		_path_check_icon.texture = _INVALID_PATH_ICON
		_path_check_icon.tooltip_text = "This is not a valid file path."
		_audit_button.disabled = true
		return false
	_audit_button.disabled = false
	_path_check_icon.texture = _VALID_PATH_ICON
	_path_check_icon.tooltip_text = "This is a valid file path."
	return true
