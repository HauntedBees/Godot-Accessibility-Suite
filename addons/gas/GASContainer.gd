@tool
class_name GASContainer
extends Control

@export_enum("First Child", "Last Child") var origin := 0:
	set(v):
		origin = v
		_reposition_nodes()
@export_enum("Left/Top", "Center", "Right/Bottom") var alignment := 0:
	set(v):
		alignment = v
		_reposition_nodes()
@export_enum("Horizontal", "Vertical") var direction := 0:
	set(v):
		direction = v
		_reposition_nodes()
@export_range(15.0, 2000.0) var separation := 15.0:
	set(v):
		separation = v
		_reposition_nodes()

func _ready():
	_reposition_nodes()

func add_child(node: Node, force_readable_name := false, internal := 0):
	super.add_child(node, force_readable_name, internal)
	await get_tree().process_frame
	_reposition_nodes()

func remove_child(node: Node):
	super.remove_child(node)
	await get_tree().process_frame
	_reposition_nodes()

func _reposition_nodes():
	var c := get_children()
	if c.size() < 2: return
	var idxes = range(0, c.size(), 1) if origin == 0 else range(c.size() - 1, -1, -1)
	var start_node:Control = c[0] if origin == 0 else c[c.size() - 1]
	var origin_width := start_node.size.x
	var origin_height := start_node.size.y
	var origin_x := start_node.position.x
	var origin_y := start_node.position.y
	for i in idxes:
		var this_node:Control = c[i]
		if this_node == start_node: continue
		var last_node:Control = c[i - 1] if origin == 0 else c[i + 1]
		var new_pos := last_node.position
		if origin == 0:
			if direction == 0: new_pos.x += last_node.size.x + separation
			else: new_pos.y += last_node.size.y + separation
		else:
			if direction == 0: new_pos.x -= this_node.size.x + separation
			else: new_pos.y -= this_node.size.y + separation
		this_node.position = new_pos
		_adjust_alignment(this_node, origin_width, origin_height, origin_x, origin_y)
# TODO: figure out how to wrap the control around everything without moving everything around
#	var leftmost_x := 999999999.9
#	var topmost_y := 999999999.9
#	var rightmost_x := 0.0
#	var bottommost_y := 0.0
#	for n in c:
#		var node:Control = n
#		var top_left := node.position
#		var bottom_right := node.position + node.size
#		leftmost_x = min(top_left.x, leftmost_x)
#		rightmost_x = max(bottom_right.x, rightmost_x)
#		topmost_y = min(top_left.y, topmost_y)
#		bottommost_y = max(bottom_right.y, bottommost_y)
#	size = Vector2(rightmost_x - leftmost_x, bottommost_y - topmost_y)
#	position = Vector2(leftmost_x, topmost_y)
#	for n in c:
#		(n as Control).position -= position

func _adjust_alignment(this_node: Control, origin_width: float, origin_height: float, origin_x: float, origin_y: float):
	match alignment:
		0: # align to left/top
			if direction == 0: this_node.position.y = origin_y # top
			else: this_node.position.x = origin_x # left
		1: # align to center
			if direction == 0: this_node.position.y = origin_y + (origin_height - this_node.size.y) / 2
			else: this_node.position.x = origin_x + (origin_width - this_node.size.x) / 2
		2: # align to bottom/right
			if direction == 0: this_node.position.y = origin_y + origin_height - this_node.size.y # bottom
			else: this_node.position.x = origin_x + origin_width - this_node.size.x # right
