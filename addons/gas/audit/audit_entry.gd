class_name GASAuditEntry extends RefCounted

enum Grade { Passed, Warning, Failed }

var source: String
var message: String
var passed: Grade
var ignored: bool

func _init(s: String, m: String, p := Grade.Failed) -> void:
	source = s
	message = m
	passed = p
	ignored = false
