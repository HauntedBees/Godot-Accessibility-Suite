@tool
class_name GASAuditRow extends VBoxContainer

const _IGNORED_COLOR := Color(Color.WHITE, 0.5)
const _CONFIRMED = preload("res://addons/gas/icons/confirmed.png")
const _HAZARD_SIGN = preload("res://addons/gas/icons/hazard-sign.png")
const _INFO = preload("res://addons/gas/icons/info.png")

var entry: GASAuditEntry:
	set(value):
		entry = value
		if !is_inside_tree():
			await ready
		if entry.source.count("/") >= 2:
			var split := entry.source.split("/")
			_source.text = ".../%s/%s" % [split[-2], split[-1]]
		else:
			_source.text = entry.source
		_source.tooltip_text = entry.source
		_issue.text = entry.message
		_ignored.button_pressed = entry.ignored
		modulate = _IGNORED_COLOR if entry.ignored else Color.WHITE
		match entry.grade:
			GASAuditEntry.Grade.Passed:
				_icon.texture = _CONFIRMED
				_icon.tooltip_text = "Verified"
				_ignored.visible = false
			GASAuditEntry.Grade.Warning:
				_icon.texture = _INFO
				_icon.tooltip_text = "Informational"
			GASAuditEntry.Grade.Failed:
				_icon.texture = _HAZARD_SIGN
				_icon.tooltip_text = "Accessibility Issue"
		if entry.icon:
			_source_icon.visible = true
			_source_icon.texture = entry.icon
		else:
			_source_icon.visible = false

@onready var _icon: TextureRect = %Icon
@onready var _source: Label = %Source
@onready var _issue: RichTextLabel = %Issue
@onready var _link: TextureButton = %Link
@onready var _ignored: CheckBox = %Ignored
@onready var _source_icon: TextureRect = %SourceIcon

func _ready() -> void:
	_link.pressed.connect(_on_link_clicked)
	_ignored.toggled.connect(_on_toggle)

func _on_link_clicked() -> void:
	OS.shell_open(entry.url)

func _on_toggle(toggled_on: bool) -> void:
	entry.ignored = toggled_on
	modulate = _IGNORED_COLOR if entry.ignored else Color.WHITE
	var ignored: Array = ProjectSettings.get_setting(GASConstant.AUDIT_IGNORES, [])
	if toggled_on && !ignored.has(entry.key):
		ignored.append(entry.key)
	elif !toggled_on && ignored.has(entry.key):
		ignored.erase(entry.key)
	else:
		return
	ProjectSettings.set_setting(GASConstant.AUDIT_IGNORES, ignored)
