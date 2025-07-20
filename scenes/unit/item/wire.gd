extends ItemComponentUnit

var _orientation_reset: bool = true
var _orientation_index = -1
var _orientations_default: Array = [
	[true, true, false, false],
	[false, false, true, true],
	[false, true, true, false],
	[false, true, false, true],
	[true, false, false, true],
	[true, false, true, false],
]
var _orientations: Array = []

func _init() -> void:
	super._init(&"wire", Core.ItemType.COMPONENT)

	top_edge = true
	bottom_edge = true
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.RESTART):
		top_edge = true
		bottom_edge = true
		left_edge = false
		right_edge = false
		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_count_true_edges(2, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)

func update_edges() -> void:
	var coords: Vector2i = Vector2i(0, 0)
	
	if top_edge:
		if right_edge:
			coords.x = 4
		if left_edge:
			coords.x = 5
	elif bottom_edge:
		if right_edge:
			coords.x = 2
		if left_edge:
			coords.x = 3
	else:
		coords.x = 1
	
	%Component.set_cell(Vector2i(0, 0), %Component.tile_set.get_source_id(0), coords)
	
func update_connection(edge_: Core.Edge = Core.Edge.NONE) -> void:
	if _orientation_reset:
		_orientation_index = -1
	
		_update_edges_to_open_connections(edge_)

	super.update_connection(edge_)
	
func _update_edges_to_open_connections(edge_: Core.Edge) -> void:
	if is_fully_connected():
		return
	
	var rect_: Rect2 = get_position_rect()
	
	var edges_: Array[Core.Edge] = [
		Core.Edge.TOP,
		Core.Edge.BOTTOM,
		Core.Edge.LEFT,
		Core.Edge.RIGHT
	]
	var used_edges_: Array[Core.Edge] = []
	var available_edges_: Array[Core.Edge] = []
	
	for current_edge_ in edges_:
		if edge_ == current_edge_ or edge_ == Core.Edge.NONE:
			if not is_edge_connected(current_edge_) and _can_connect_edge_internal(rect_, current_edge_):
				if has_edge(current_edge_):
					used_edges_.push_back(current_edge_)
				else:
					available_edges_.push_back(current_edge_)
	
	if used_edges_.size() == 2 or available_edges_.size() == 0:
		return
		
	for available_edge_ in available_edges_:
		used_edges_.push_back(available_edge_)
		if used_edges_.size() == 2:
			break
			
	if used_edges_.size() == 0:
		return
		
	if used_edges_.size() == 1:
		if edge_ == Core.Edge.NONE:
			used_edges_.push_back(_get_oposite_edge(used_edges_[0]))
		else:
			for current_edge_ in edges_:
				if is_edge_connected(current_edge_) and edge_ != current_edge_:
					used_edges_.push_back(current_edge_)
					break
			
			if used_edges_.size() == 1:
				for current_edge_ in edges_:
					if has_edge(current_edge_) and edge_ != current_edge_:
						used_edges_.push_back(current_edge_)
						break
		
	top_edge = used_edges_.has(Core.Edge.TOP)
	bottom_edge = used_edges_.has(Core.Edge.BOTTOM)
	left_edge = used_edges_.has(Core.Edge.LEFT)
	right_edge = used_edges_.has(Core.Edge.RIGHT)
	
	update_edges()

func is_open_edge(edge_: Core.Edge) -> bool:
	if super.is_open_edge(edge_):
		return true
		
	if not is_fully_connected():
		return true
		
	return false

func connect_edge(edge_: Core.Edge) -> void:
	super.connect_edge(edge_)
	
	if edge_ == Core.Edge.TOP:
		%ConnectionTop.set_cell(Vector2i(0, 0), %ConnectionTop.tile_set.get_source_id(0), Vector2i(8, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%ConnectionBottom.set_cell(Vector2i(0, 0), %ConnectionBottom.tile_set.get_source_id(0), Vector2i(6, 0))
		
	if edge_ == Core.Edge.LEFT:
		%ConnectionLeft.set_cell(Vector2i(0, 0), %ConnectionLeft.tile_set.get_source_id(0), Vector2i(7, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%ConnectionRight.set_cell(Vector2i(0, 0), %ConnectionRight.tile_set.get_source_id(0), Vector2i(9, 0))
	
func disconnect_edge(edge_: Core.Edge) -> void:
	super.disconnect_edge(edge_)
	
	if edge_ == Core.Edge.TOP:
		%ConnectionTop.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%ConnectionBottom.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.LEFT:
		%ConnectionLeft.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%ConnectionRight.set_cell(Vector2i(0, 0))

func orientate() -> void:
	_orientation_reset = false
	
	if _orientations.size() == 0:
		_orientation_index = -1
	
	if _orientation_index == -1:
		_orientations = _get_ordered_orientations()
	
	_orientation_index += 1
	if _orientation_index >= _orientations.size():
		_orientation_index = 0
	
	var orientation_ = _orientations[_orientation_index]

	set_edges(orientation_[0], orientation_[1], orientation_[2], orientation_[3])
	
	_orientation_reset = true
 
func _get_ordered_orientations() -> Array:
	#TODO: smart ordering based available connectionsv
	var orientations_ = _orientations_default
	
	for index in orientations_.size():
		if (orientations_[index][0] == top_edge and
			orientations_[index][1] == bottom_edge and
			orientations_[index][2] == left_edge and
			orientations_[index][3] == right_edge
		):
			_orientation_index = index
			break
	
	return orientations_
