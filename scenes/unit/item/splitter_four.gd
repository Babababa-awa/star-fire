extends ItemComponentUnit

func _init() -> void:
	super._init(&"splitter_four", Core.ItemType.COMPONENT)

	top_edge = true
	bottom_edge = true
	left_edge = true
	right_edge = true
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.RESTART):
		top_edge = true
		bottom_edge = true
		left_edge = true
		right_edge = true
		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_count_true_edges(4, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)
	
func connect_edge(edge_: Core.Edge) -> void:
	if edge_ == Core.Edge.TOP:
		%ConnectionTop.set_cell(Vector2i(0, 0), %ConnectionTop.tile_set.get_source_id(0), Vector2i(8, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%ConnectionBottom.set_cell(Vector2i(0, 0), %ConnectionBottom.tile_set.get_source_id(0), Vector2i(6, 0))
		
	if edge_ == Core.Edge.LEFT:
		%ConnectionLeft.set_cell(Vector2i(0, 0), %ConnectionLeft.tile_set.get_source_id(0), Vector2i(7, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%ConnectionRight.set_cell(Vector2i(0, 0), %ConnectionRight.tile_set.get_source_id(0), Vector2i(9, 0))
	
func disconnect_edge(edge_: Core.Edge) -> void:
	if edge_ == Core.Edge.TOP:
		%ConnectionTop.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%ConnectionBottom.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.LEFT:
		%ConnectionLeft.set_cell(Vector2i(0, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%ConnectionRight.set_cell(Vector2i(0, 0))
