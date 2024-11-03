class_name GASAuditFileParser extends RefCounted

func can_parse(_file: Resource) -> bool:
	return false

func parse(_file: Resource) -> Array[GASAuditEntry]:
	return []
