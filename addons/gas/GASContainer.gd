tool
class_name GASContainer
extends Control

export(int, "First Child", "Last Child") var origin := 0 setget _set_origin
export(int, "Left/Top", "Center", "Right/Bottom") var alignment := 0 setget _set_alignment
export(int, "Horizontal", "Vertical") var direction := 0 setget _set_direction
export(float, 15.0, 2000.0) var separation := 15.0 setget _set_separation

func _set_origin(o:int):
	origin = o
	_reposition_nodes()
func _set_alignment(a:int):
	alignment = a
	_reposition_nodes()
func _set_direction(d:int):
	direction = d
	_reposition_nodes()
func _set_separation(s:float):
	separation = s
	_reposition_nodes()
func _ready(): _reposition_nodes()

func add_child(node:Node, legible_unique_name := false):
	.add_child(node, legible_unique_name)
	yield(get_tree(), "idle_frame")
	_reposition_nodes()

func remove_child(node:Node):
	.remove_child(node)
	yield(get_tree(), "idle_frame")
	_reposition_nodes()

func _reposition_nodes():
	var c := get_children()
	if c.size() < 2: return
	var idxes = range(0, c.size(), 1) if origin == 0 else range(c.size() - 1, -1, -1)
	var start_node:Control = c[0] if origin == 0 else c[c.size() - 1]
	var origin_width := start_node.rect_size.x
	var origin_height := start_node.rect_size.y
	var origin_x := start_node.rect_position.x
	var origin_y := start_node.rect_position.y
	for i in idxes:
		var this_node:Control = c[i]
		if this_node == start_node: continue
		var last_node:Control = c[i - 1] if origin == 0 else c[i + 1]
		var new_pos := last_node.rect_position
		if origin == 0:
			if direction == 0: new_pos.x += last_node.rect_size.x + separation
			else: new_pos.y += last_node.rect_size.y + separation
		else:
			if direction == 0: new_pos.x -= this_node.rect_size.x + separation
			else: new_pos.y -= this_node.rect_size.y + separation
		this_node.rect_position = new_pos
		_adjust_alignment(this_node, origin_width, origin_height, origin_x, origin_y)
# TODO: figure out how to wrap the control around everything without moving everything around
#	var leftmost_x := 999999999.9
#	var topmost_y := 999999999.9
#	var rightmost_x := 0.0
#	var bottommost_y := 0.0
#	for n in c:
#		var node:Control = n
#		var top_left := node.rect_position
#		var bottom_right := node.rect_position + node.rect_size
#		leftmost_x = min(top_left.x, leftmost_x)
#		rightmost_x = max(bottom_right.x, rightmost_x)
#		topmost_y = min(top_left.y, topmost_y)
#		bottommost_y = max(bottom_right.y, bottommost_y)
#	rect_size = Vector2(rightmost_x - leftmost_x, bottommost_y - topmost_y)
#	rect_position = Vector2(leftmost_x, topmost_y)
#	for n in c:
#		(n as Control).rect_position -= rect_position

func _adjust_alignment(this_node:Control, origin_width:float, origin_height:float, origin_x:float, origin_y:float):
	match alignment:
		0: # align to left/top
			if direction == 0: this_node.rect_position.y = origin_y # top
			else: this_node.rect_position.x = origin_x # left
		1: # align to center
			if direction == 0: this_node.rect_position.y = origin_y + (origin_height - this_node.rect_size.y) / 2
			else: this_node.rect_position.x = origin_x + (origin_width - this_node.rect_size.x) / 2
		2: # align to bottom/right
			if direction == 0: this_node.rect_position.y = origin_y + origin_height - this_node.rect_size.y # bottom
			else: this_node.rect_position.x = origin_x + origin_width - this_node.rect_size.x # right
