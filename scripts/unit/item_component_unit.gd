extends ItemUnit
class_name ItemComponentUnit

var top_edge: bool = false
var bottom_edge: bool = false
var left_edge: bool = false
var right_edge: bool = false

var is_top_edge_connected: bool = false
var is_bottom_edge_connected: bool = false
var is_left_edge_connected: bool = false
var is_right_edge_connected: bool = false

static var _handled: Array[LevelItemValue] = []

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.RESTART):
		top_edge = false
		bottom_edge = false
		left_edge = false
		right_edge = false
		
		is_top_edge_connected = false
		is_bottom_edge_connected = false
		is_left_edge_connected = false
		is_right_edge_connected = false
		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	var rect_: Rect2 = get_position_rect()
	var item_: LevelItemValue
	
	# Remove defunct edge connections
	if top_edge and not top_edge_:
		item_ = _get_adjacent_item(rect_, Core.Edge.TOP)
		if item_ != null:
			item_.node.disconnect_edge(Core.Edge.BOTTOM)
			
	if bottom_edge and not bottom_edge_:
		item_ = _get_adjacent_item(rect_, Core.Edge.BOTTOM)
		if item_ != null:
			item_.node.disconnect_edge(Core.Edge.TOP)
	
	if left_edge and not left_edge_:
		item_ = _get_adjacent_item(rect_, Core.Edge.LEFT)
		if item_ != null:
			item_.node.disconnect_edge(Core.Edge.RIGHT)
			
	if right_edge and not right_edge_:
		item_ = _get_adjacent_item(rect_, Core.Edge.RIGHT)
		if item_ != null:
			item_.node.disconnect_edge(Core.Edge.LEFT)
	
	top_edge = top_edge_
	bottom_edge = bottom_edge_
	left_edge = left_edge_
	right_edge = right_edge_
	
	update_component()

func update_component() -> void:
	# Needs to be LevelItemValue, shouldn't matter, 
	# just an exra test could happen if loop
	#_handled.push_back(self)
	update_connection()
	update_edges()
	_handled.clear()

func update_edges() -> void:
	pass
	
func update_connection(edge: Core.Edge = Core.Edge.NONE) -> void:
	var rect_: Rect2 = get_position_rect()
		
	var edges_: Array[Core.Edge] = [
		Core.Edge.TOP,
		Core.Edge.BOTTOM,
		Core.Edge.LEFT,
		Core.Edge.RIGHT
	]
	
	for current_edge_ in edges_:
		if edge == current_edge_ or edge == Core.Edge.NONE:
			if has_edge(current_edge_) and _can_connect_edge_internal(rect_, current_edge_, true):
				connect_edge(current_edge_)
			else:
				disconnect_edge(current_edge_)

func connect_edge(edge_: Core.Edge) -> void:
	if edge_ == Core.Edge.TOP:
		is_top_edge_connected = true
	elif edge_ == Core.Edge.BOTTOM:
		is_bottom_edge_connected = true
	elif edge_ == Core.Edge.LEFT:
		is_left_edge_connected = true
	elif edge_ == Core.Edge.RIGHT:
		is_right_edge_connected = true
	
func disconnect_edge(edge_: Core.Edge) -> void:
	if edge_ == Core.Edge.TOP:
		is_top_edge_connected = false
	elif edge_ == Core.Edge.BOTTOM:
		is_bottom_edge_connected = false
	elif edge_ == Core.Edge.LEFT:
		is_left_edge_connected = false
	elif edge_ == Core.Edge.RIGHT:
		is_right_edge_connected = false

func orientate() -> void:
	pass

func has_edge(edge_: Core.Edge) -> bool:
	if edge_ == Core.Edge.TOP:
		return top_edge
	elif edge_ == Core.Edge.BOTTOM:
		return bottom_edge
	elif edge_ == Core.Edge.LEFT:
		return left_edge
	elif edge_ == Core.Edge.RIGHT:
		return right_edge
		
	return true

func is_edge_connected(edge_: Core.Edge = Core.Edge.NONE) -> bool:
	if edge_ == Core.Edge.TOP:
		return is_top_edge_connected
	elif edge_ == Core.Edge.BOTTOM:
		return is_bottom_edge_connected
	elif edge_ == Core.Edge.LEFT:
		return is_left_edge_connected
	elif edge_ == Core.Edge.RIGHT:
		return is_right_edge_connected
	
	return is_top_edge_connected or is_bottom_edge_connected or is_left_edge_connected or is_right_edge_connected

func is_fully_connected() -> bool:
	var count_connects_: int = int(is_top_edge_connected) + int(is_bottom_edge_connected) + int(is_left_edge_connected) + int(is_right_edge_connected)
	var count_edges_: int = int(top_edge) + int(bottom_edge) + int(left_edge) + int(right_edge)
	return count_connects_ == count_edges_

func can_connect_edge(edge_: Core.Edge) -> bool:
	var rect_: Rect2 = get_position_rect()
	return _can_connect_edge_internal(rect_, edge_)
	
func is_open_edge(edge_: Core.Edge) -> bool:
	if has_edge(edge_):
		return true
		
	return false
		
func _can_connect_edge_internal(rect_: Rect2, edge_: Core.Edge, handle_: bool = false) -> bool:
	var item_: LevelItemValue = _get_adjacent_item(rect_, edge_)

	if item_ == null:
		return false
	
	var target_edge_: Core.Edge = _get_oposite_edge(edge_)
	
	if not item_.node.is_open_edge(target_edge_):
		return false
	
	if handle_ and not _handled.has(item_):
		_handled.push_back(item_)
		item_.node.update_connection(target_edge_)
		item_.node.update_edges()
	
	return true
	
func _get_oposite_edge(edge_: Core.Edge) -> Core.Edge:
	if edge_ == Core.Edge.TOP:
		return Core.Edge.BOTTOM
		
	if edge_ == Core.Edge.BOTTOM:
		return Core.Edge.TOP
	
	if edge_ == Core.Edge.LEFT:
		return Core.Edge.RIGHT
	
	if edge_ == Core.Edge.RIGHT:
		return Core.Edge.LEFT
	
	return Core.Edge.NONE
	
func _get_adjacent_item(rect_: Rect2, edge_: Core.Edge) -> LevelItemValue:
	if not Core.level is AreaLevel:
		return null
	
	var item_: LevelItemValue = Core.level.items.get_adjacent_item(rect_, edge_)
	
	if item_ == null or not item_.node is ItemComponentUnit:
		return null
		
	return item_

func _count_true_edges(count_: int, top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> bool:
	var count: int = int(top_edge_) + int(bottom_edge_) + int(left_edge_) + int(right_edge_)
	return count == count_

func _is_linear_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> bool:
	if top_edge_:
		if not bottom_edge_ or left_edge_ or right_edge_:
			return false
	elif bottom_edge_:
		if not top_edge_ or left_edge_ or right_edge_:
			return false
	elif left_edge_:
		if not right_edge_ or top_edge_ or bottom_edge_:
			return false
	elif right_edge_:
		if not left_edge_ or top_edge_ or bottom_edge_:
			return false
	
	return true
