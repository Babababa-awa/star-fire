class_name PowerGrid

var grid: Array = []

func update_power_levels() -> void:
	for cell_ in grid:
		if (not cell_.item.item.alias == &"launcher" and 
			not cell_.item.item.alias == &"ground"
		):
			continue
		
		cell_.item.node.power_level = max(0, get_power_level(cell_.coords))
		cell_.item.node.update_power_indicator()

func can_add_component(coords: Vector2i, item: LevelItemValue) -> bool:
	if not Core.level:
		return false
		
	if item.node == null or not item.node is ItemComponentUnit:
		return false
	
	var item_ = get_component(coords)
	if item_ == null:
		return true
		
	if item_.item.meta.can_pick_up:
		return true
	
	return false
	
func add_component(coords: Vector2i, item: LevelItemValue) -> void:
	remove_component(coords)
	grid.push_back({"coords": coords, "item": item})

func remove_component(coords: Vector2i) -> void:
	for index in grid.size():
		if grid[index].coords == coords:
			grid.remove_at(index)
			break

func get_component(coords: Vector2i) -> LevelItemValue:
	for cell_ in grid:
		if cell_.coords == coords:
			return cell_.item
			
	return null
	
func get_power_button() -> LevelItemValue:
	for cell_ in grid:
		if cell_.item.item.alias == &"power_button":
			return cell_.item
			
	return null
	
func can_launch() -> bool:
	for cell_ in grid:
		if cell_.item.item.alias == &"launcher":
			if get_power_level(cell_.coords) != 1:
				return false
		elif cell_.item.item.alias == &"ground":
			if get_power_level(cell_.coords) > 1:
				return false
	
	return true
	
func launch() -> void:
	for cell_ in grid:
		if cell_.item.item.alias == &"launcher":
			cell_.item.node.launch()
			
func launch_view_position() -> Vector2:
	var launch_view_position_ = Vector2.ZERO
	var count_: int = 0
	
	for cell_ in grid:
		if cell_.item.item.alias == &"launcher":
			launch_view_position_ += cell_.item.node.target_position
			count_ += 1
	
	return launch_view_position_ / count_
	
func get_power_level(coords: Vector2i) -> int:
	var item_ = get_component(coords)
	if item_ == null:
		return -1
	
	var power_button_: LevelItemValue
	var start_coords: Vector2i
	
	for cell_ in grid:
		if cell_.item.item.alias == &"power_button":
			power_button_ = cell_.item
			start_coords = cell_.coords
			break
	
	if power_button_ == null:
		return -1
		
	var power_level_: float = power_button_.node.power_level
	
	power_level_ = _find_end_power_level(power_level_, start_coords, coords)
	
	return _normalize_power_level(power_level_)

func _normalize_power_level(power_level_: float) -> int:
	if is_equal_approx(power_level_, -1.0):
		return -1
	elif is_equal_approx(power_level_, 1.0):
		return 1
	elif power_level_ > 1.0:
		return ceil(power_level_)
	else:
		return 0

func _find_end_power_level(
	start_power_level_: float, 
	start_coords_: Vector2i, 
	end_coords_: Vector2i,
	visited_: Dictionary = {}
) -> float:
	var visited_splitters_: Dictionary = {}
	var stack_splitters_: Array[Dictionary] = []
	var coord_to_item_: Dictionary = {}

	var stack_: Array[Dictionary] = [{"power_level": start_power_level_, "coords": start_coords_}]
	
	while stack_.size() > 0:
		var current: Dictionary = stack_.pop_back()
		
		if current.coords == end_coords_:
			return maxf(0.0, current.power_level)
		
		if visited_.has(current.coords):
			continue
			
		var current_item: LevelItemValue = get_component(current.coords)
		if current_item == null:
			visited_[current.coords] = true
			continue

		# If component is a splitter, wait for stack to empty first
		# before continuing in case multiple power level inputs
		if (current_item.node.alias == &"splitter_three" or
			current_item.node.alias == &"splitter_four"
		):
			if current.coords != start_coords_:
				if visited_splitters_.has(current.coords):
					visited_splitters_[current.coords] += current.power_level
				else:
					visited_splitters_[current.coords] = current.power_level
					stack_splitters_.push_back(current)
		
				if stack_.size() == 0:
					stack_splitters_ = _update_splitter_power_level(stack_splitters_, visited_splitters_)

					return _find_splitters_end_power_level(stack_splitters_, end_coords_, visited_)
					
				continue
		
		visited_[current.coords] = true
	
		var neighbors_: Array[Dictionary] = _get_connected_neighbors(
			current.power_level, 
			current.coords, 
			current_item,
			visited_
		)
			
		if neighbors_.size() >= 0:
			for neighbor_: Dictionary in neighbors_:
				stack_.append(neighbor_)
		
		if stack_.size() == 0 and stack_splitters_.size() > 0:
			stack_splitters_ = _update_splitter_power_level(stack_splitters_, visited_splitters_)
			return _find_splitters_end_power_level(stack_splitters_, end_coords_, visited_)

	return -1.0
	
func _find_splitters_end_power_level(
	splitters_: Array[Dictionary],
	end_coords_: Vector2i,
	visited_: Dictionary
) -> float:
	for splitter_ in splitters_:
		var power_level: float = _find_end_power_level(
			splitter_.power_level, 
			splitter_.coords, 
			end_coords_, 
			visited_
		)
		
		if power_level >= 0.0:
			return power_level

	return -1.0

func _update_splitter_power_level(stack_splitters__: Array[Dictionary], visited_splitters__: Dictionary) -> Array[Dictionary]:
	for index in stack_splitters__.size():
		var power_level_ = visited_splitters__[stack_splitters__[index].coords]

		var level_item_value_: LevelItemValue = get_component(stack_splitters__[index].coords)
		level_item_value_.node.power_level = power_level_
		level_item_value_.node.update_power_indicator()
		
		stack_splitters__[index].power_level = power_level_
		
	return stack_splitters__

func _get_connected_neighbors(
	power_level_: float, 
	coords_: Vector2i, 
	level_item_value_: LevelItemValue,
	visited_: Dictionary
) -> Array[Dictionary]:
	var neighbors: Array[Dictionary] = []

	var directions: Dictionary = {}

	if level_item_value_.node.top_edge:
		directions[Vector2i.UP] = &"bottom_edge"
	
	if level_item_value_.node.bottom_edge:
		directions[Vector2i.DOWN] = &"top_edge"
	
	if level_item_value_.node.left_edge:
		directions[Vector2i.LEFT] = &"right_edge"
	
	if level_item_value_.node.right_edge:
		directions[Vector2i.RIGHT] = &"left_edge"
	
	var outputs_: int = 0
	var no_end_directions_: Array[Vector2i] = []
	
	if (level_item_value_.node.alias == &"splitter_three" or 
		level_item_value_.node.alias == &"splitter_four"
	):
		for direction_: Vector2i in directions.keys():
			var neighbor_coords: Vector2i = coords_ + direction_
			if visited_.has(neighbor_coords):
				continue
				
			var neighbor_item: LevelItemValue = get_component(neighbor_coords)
			if neighbor_item == null:
				continue
			
			if not _has_end_component(
				coords_, 
				direction_,
				visited_
			):
				no_end_directions_.push_back(direction_)
				continue
				
			outputs_ += 1
	else:
		outputs_ = 1
		
	#if coords_ == Vector2i(13, 5):
		#print(outputs_)
		#print(power_level_)
	
	if outputs_ == 0:
		return neighbors
		
	if outputs_ > 1:
		power_level_ /= outputs_
	
	for direction: Vector2i in directions.keys():
		var neighbor_coords: Vector2i = coords_ + direction
		
		if no_end_directions_.has(direction):
			continue
		
		if visited_.has(neighbor_coords):
			continue
		
		var neighbor_item: LevelItemValue = get_component(neighbor_coords)
		
		if neighbor_item == null:
			continue
		
		if neighbor_item.node.get(directions[direction]):
			var neighbor_power_level = power_level_
			
			if level_item_value_.node.alias == &"diode":
				var bad_flow: bool = false
				
				if directions[direction] == &"top_edge" and level_item_value_.node.negative_edge != Core.Edge.TOP:
					bad_flow = true
				elif directions[direction] == &"bottom_edge" and level_item_value_.node.negative_edge != Core.Edge.BOTTOM:
					bad_flow = true
				elif directions[direction] == &"left_edge" and level_item_value_.node.negative_edge != Core.Edge.LEFT:
					bad_flow = true
				elif directions[direction] == &"right_edge" and level_item_value_.node.negative_edge != Core.Edge.RIGHT:
					bad_flow = true
					
				if bad_flow:
					neighbor_power_level = 0.0
			elif neighbor_power_level > 0.0: # If power level reaches zero, it can't be increased again
				if level_item_value_.node.alias == &"resister":
					neighbor_power_level -= 1.0 # Should i prevent going below zero?
				elif level_item_value_.node.alias == &"transformer":
					neighbor_power_level += 1.0 # Should i prevent going below zero?
			
			neighbor_power_level = maxf(0.0, neighbor_power_level)
			
			
			neighbors.push_back({"power_level": neighbor_power_level, "coords": neighbor_coords})

	return neighbors

func _has_end_component(
	start_coords_: Vector2i, 
	direction_: Vector2i,
	visited_: Dictionary = {}
) -> bool:
	return true
	for cell_ in grid:
		if (not cell_.item.item.alias == &"launcher" and
			not cell_.item.item.alias == &"ground"
		):
			continue
		
		var current_visited_ = visited_.duplicate()
		current_visited_[start_coords_] = true
		
		var power_level_: float = _find_end_power_level(
			1000, 
			start_coords_ + direction_, 
			cell_.coords,
			current_visited_
		)
		
		if not is_equal_approx(power_level_, -1.0):
			return true

	return false
