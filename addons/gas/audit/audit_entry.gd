class_name GASAuditEntry extends RefCounted

enum Grade { Passed, Warning, Failed }

var source: String
var message: String
var grade: Grade
var ignored: bool
var url: String
var key: String

func _init(id: String, p: String, s: String, m: String, u: String, g := Grade.Failed) -> void:
	source = s
	message = m
	url = u
	grade = g
	ignored = false
	key = "%s::%s::%s" % [p, s, id]

func grade_as_int() -> int:
	match grade:
		Grade.Passed: return 2
		Grade.Warning: return 1
		Grade.Failed: return 0
	return 0
