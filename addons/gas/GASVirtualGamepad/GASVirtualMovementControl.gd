tool
extends GASVirtualControl
class_name GASVirtualMovementControl

export(float) var dead_zone := 0.15
export(float) var max_zone := 0.8
export(bool) var fixed_position := true setget _set_fixed_position
func _set_fixed_position(p:bool):
	fixed_position = p
	visible = Engine.editor_hint || fixed_position
