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
		_source.text = entry.source
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

@onready var _icon: TextureRect = %Icon
@onready var _source: Label = %Source
@onready var _issue: RichTextLabel = %Issue
@onready var _ignored: CheckBox = %Ignored

func _ready() -> void:
	_ignored.toggled.connect(_on_toggle)

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
