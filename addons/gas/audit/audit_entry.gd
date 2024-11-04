class_name GASAuditEntry extends RefCounted

enum Grade { Passed, Warning, Failed }

var source: String
var message: String
var grade: Grade
var ignored: bool

func _init(s: String, m: String, p := Grade.Failed) -> void:
	source = s
	message = m
	grade = p
	ignored = false
