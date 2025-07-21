extends ItemComponentUnit

var power_level: float = 0.0

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
		
		power_level = 0.0
		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_count_true_edges(4, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)

func update_edges() -> void:
	super.update_edges()
	
	update_power_indicator()

func update_power_indicator() -> void:
	var coords: Vector2i = Vector2i(0, 0)
	
	if power_level <= 0.0:
		%PowerLights1.set_cell(Vector2i(0, 0))
		%PowerLights2.set_cell(Vector2i(0, 0))
		%PowerLights3.set_cell(Vector2i(0, 0))
		return
	
	if power_level > 10:
		%PowerLights3.set_cell(Vector2i(0, 0))
		
		var digit1: int = floor(power_level / 10)
		coords.x = digit1 - 1
		%PowerLights1.set_cell(Vector2i(0, 0), %PowerLights1.tile_set.get_source_id(0), coords)
		
		var digit: int = roundi(power_level) % 10
		if digit == 0:
			coords.x = 9
		else:
			coords.x = digit - 1
		%PowerLights2.set_cell(Vector2i(0, 0), %PowerLights2.tile_set.get_source_id(0), coords)
		return
	
	
	var decimal_part: float = floor((power_level - int(power_level)) * 10)
	if decimal_part == 0:
		%PowerLights1.set_cell(Vector2i(0, 0))
		%PowerLights3.set_cell(Vector2i(0, 0))
		
		var digit: int = roundi(power_level)
		coords.x = digit - 1
		%PowerLights2.set_cell(Vector2i(0, 0), %PowerLights2.tile_set.get_source_id(0), coords)
	else:
		coords.x = floori(power_level) - 1
		%PowerLights1.set_cell(Vector2i(0, 0), %PowerLights1.tile_set.get_source_id(0), coords)
		coords.x = decimal_part - 1
		%PowerLights2.set_cell(Vector2i(0, 0), %PowerLights2.tile_set.get_source_id(0), coords)
		%PowerLights3.set_cell(Vector2i(0, 0), %PowerLights3.tile_set.get_source_id(0), Vector2i(10, 0))
	
	
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
