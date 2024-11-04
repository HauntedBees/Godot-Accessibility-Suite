@tool
class_name GASAuditRow extends HBoxContainer

const _CONFIRMED = preload("res://addons/gas/icons/confirmed.png")
const _HAZARD_SIGN = preload("res://addons/gas/icons/hazard-sign.png")
const _INFO = preload("res://addons/gas/icons/info.png")

@onready var _icon: TextureRect = %Icon
@onready var _source: Label = %Source
@onready var _issue: RichTextLabel = %Issue
@onready var _ignored: CheckBox = %Ignored

func set_entry(entry: GASAuditEntry):
	if !is_inside_tree():
		await ready
	_source.text = entry.source
	_issue.text = entry.message
	_ignored.button_pressed = entry.ignored
	match entry.grade:
		GASAuditEntry.Grade.Passed:
			_icon.texture = _CONFIRMED
		GASAuditEntry.Grade.Warning:
			_icon.texture = _INFO
			_icon.tooltip_text = "Informational"
		GASAuditEntry.Grade.Failed:
			_icon.texture = _HAZARD_SIGN
			_icon.tooltip_text = "Accessibility Issue"
