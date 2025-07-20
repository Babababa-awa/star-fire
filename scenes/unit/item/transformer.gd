extends ItemComponentUnit

func _init() -> void:
	super._init(&"transformer", Core.ItemType.COMPONENT)

	top_edge = true
	bottom_edge = true

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.RESTART):
		top_edge = true
		bottom_edge = true
		left_edge = false
		right_edge = false
				
		_update_from_meta()

func set_item_meta(meta_: Dictionary) -> void:
	super.set_item_meta(meta_)
	
	_update_from_meta()
	
func _update_from_meta() -> void:
	if item_meta.has("orientation"):
		if item_meta.orientation == 1:
			set_edges(true, true, false, false)
		elif item_meta.orientation == 2:
			set_edges(false, false, true, true)
			
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_is_linear_edges(top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)

func update_edges() -> void:
	super.update_edges()
	
	var coords: Vector2i = Vector2i(0, 5)
	
	if top_edge:
		coords.x = 7
	elif left_edge:
		coords.x = 6
	
	%Component.set_cell(Vector2i(0, 0), %Component.tile_set.get_source_id(0), coords)
	
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

func orientate() -> void:
	if top_edge and bottom_edge:
		set_edges(false, false, true, true)
	else:
		set_edges(true, true, false, false)
