class_name AuditSceneNodeParser extends RefCounted

var _node: GASAuditSceneNodeInfo
var _notes: Array[GASAuditEntry]
var _resources: Dictionary[String, GASAuditSceneResourceInfo]

func _init(node: GASAuditSceneNodeInfo, notes: Array[GASAuditEntry], subresources: Dictionary[String, GASAuditSceneResourceInfo]) -> void:
	_node = node
	_notes = notes
	_resources = subresources

func _add_audit_entry(id: String, message: String, url: String, icon: Texture2D = null, grade := GASAuditEntry.Grade.Failed) -> void:
	_notes.append(GASAuditEntry.new(id, _node.source_path, _node.path, message, url, icon, grade))
