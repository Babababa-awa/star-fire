extends ItemComponentUnit

var power_level: int = 0

func _init() -> void:
	super._init(&"ground", Core.ItemType.COMPONENT)

	bottom_edge = true
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.RESTART):
		top_edge = false
		bottom_edge = true
		left_edge = false
		right_edge = false
		
		power_level = 0
			
		_update_from_meta()

func set_item_meta(meta_: Dictionary) -> void:
	super.set_item_meta(meta_)
	
	_update_from_meta()
	
func _update_from_meta() -> void:
	if item_meta.has("orientation"):
		if item_meta.orientation == 1:
			set_edges(false, true, false, false)
		elif item_meta.orientation == 2:
			set_edges(false, false, true, false)
		elif item_meta.orientation == 3:
			set_edges(true, false, false, false)
		elif item_meta.orientation == 4:
			set_edges(false, false, false, true)
			
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_count_true_edges(1, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)

func update_edges() -> void:
	super.update_edges()
	
	var coords: Vector2i = Vector2i(0, 1)
	
	if top_edge:
		coords.x = 2
	elif right_edge:
		coords.x = 3
	elif left_edge:
		coords.x = 1
	
	%Component.set_cell(Vector2i(0, 0), %Component.tile_set.get_source_id(0), coords)
	
	coords.y = 2
	%Symbol.set_cell(Vector2i(0, 0), %Symbol.tile_set.get_source_id(0), coords)
	
	update_power_indicator()

func update_power_indicator() -> void:
	var coords: Vector2i = Vector2i(0, 4)
	
	if top_edge:
		coords.x = 3
	elif left_edge:
		coords.y = 5
	elif right_edge:
		coords.x = 3
		coords.y = 5
	
	%PowerBar.set_cell(Vector2i(0, 0), %PowerBar.tile_set.get_source_id(0), coords)
	
	if power_level == 0:
		%PowerLights.set_cell(Vector2i(0, 0))
	elif power_level == 1:
		coords.x += 1
		%PowerLights.set_cell(Vector2i(0, 0), %PowerLights.tile_set.get_source_id(0), coords)
	else:
		coords.x += 2
		%PowerLights.set_cell(Vector2i(0, 0), %PowerLights.tile_set.get_source_id(0), coords)

func connect_edge(edge_: Core.Edge) -> void:
	super.connect_edge(edge_)
	
	if edge_ == Core.Edge.NONE:
		return
		
	if edge_ == Core.Edge.TOP:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(8, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(6, 0))
		
	if edge_ == Core.Edge.LEFT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(7, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(9, 0))
	
func disconnect_edge(edge_: Core.Edge) -> void:
	super.disconnect_edge(edge_)
	
	if not is_edge_connected():
		%Connection.set_cell(Vector2i(0, 0))
