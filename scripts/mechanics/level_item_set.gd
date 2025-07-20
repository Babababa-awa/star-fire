class_name LevelItemSet

var items: Array[LevelItemValue]

signal add_item_before(item_level_value_: LevelItemValue)
signal add_item_after(item_level_value_: LevelItemValue)

signal remove_item_before(item_level_value: LevelItemValue)
signal remove_item_after(item_level_value_: LevelItemValue)

func _init(data_: BaseLevelDataLoader) -> void:
	for area_ in data_.get_area_data():
		if not area_.has("items"):
			continue
			
		for area_item_ in area_.items:
			var item_value_: ItemValue
			
			item_value_ = Core.items.get_item(area_item_.alias)
		
			var level_item_value_ = LevelItemValue.new(
				item_value_,
				area_.alias,
				area_item_.position, # Item position within the area
				area_item_.meta if area_item_.has("meta") else {},
			)
			
			if area_item_.has("visible") and not area_item_.visible:
				level_item_value_.visible = false
				
			items.push_back(level_item_value_)

func populate_area_items(area_alias_: StringName = &"") -> void:
	if area_alias_ == &"":
		area_alias_ = Core.game.get_level_area_alias()
	
	for item in items:
		if item.area_alias == area_alias_:
			populate_item(item)

func depopulate_area_items(area_alias_: StringName = &"") -> void:
	if area_alias_ == &"":
		area_alias_ = Core.game.get_level_area_alias()
		
	for item in items:
		if item.area_alias == area_alias_:
			depopulate_item(item)

func populate_item(level_item_value_: LevelItemValue) -> void:
	assert(Core.level != null and Core.level.area != null, "Level area is null.")
	
	var item_value_ = level_item_value_.item.duplicate()
	
	if level_item_value_.meta.has("item"):
		item_value_.meta.merge(level_item_value_.meta.item, true)
	
	var node = await Core.items.get_level_item_unit(item_value_)
		
	if node == null:
		return
	
	level_item_value_.node = node
	
	var offset = Vector2.ZERO
	if level_item_value_.meta.has("alignment"):
		offset = node.get_align_offset(level_item_value_.meta.alignment)
	
	node.global_position = Core.level.area.global_position + level_item_value_.position + offset
	
	node.set_meta
	
	node.visible = level_item_value_.visible

func depopulate_item(item_: LevelItemValue) -> void:
	if item_.node != null:
		Core.nodes.free_node(item_.node)
	
func get_item(area_alias_: StringName) -> LevelItemValue:
	for item_ in items:
		if item_.area_alias == area_alias_:
			return item_
			
	return null
	
func get_adjacent_item(rect_: Rect2, edge_: Core.Edge) -> LevelItemValue:
	for item_ in items:
		if item_.node == null:
			continue

		if Core.is_adjacent_rect(rect_, item_.node.get_position_rect(), edge_):
			return item_
			
	return null

	
func get_items() -> Array[LevelItemValue]:
	return items

func get_items_from_area(area_alias_: StringName) -> Array[LevelItemValue]:
	var area_items: Array[LevelItemValue] = []
	
	for item in items:
		if item.area_alias == area_alias_:
			area_items.push_back(item)
			
	return area_items
	
func get_items_from_meta(meta: Dictionary) -> Array[LevelItemValue]:
	var items_: Array[LevelItemValue] = []
	
	for item_ in items:
		if Core.dictionary_contains(item_.meta, meta):
			items_.push_back(item_)
	
	return items_

func get_items_from_type(type_: Core.ItemType) -> Array[LevelItemValue]:
	var items_: Array[LevelItemValue] = []
	
	for item_ in items:
		if item_.item.type == type_:
			items_.push_back(item_)
	
	return items_
	
func get_items_from_area_meta(area_alias_: StringName, meta: Dictionary) -> Array[LevelItemValue]:
	var items_: Array[LevelItemValue] = []
	
	for item_ in items:
		if (item_.area_alias == area_alias_ and 
			Core.dictionary_contains(item_.meta, meta)
		):
			items_.push_back(item_)
	
	return items_

func get_items_from_area_type(area_alias_: StringName, type_: Core.ItemType) -> Array[LevelItemValue]:
	var items_: Array[LevelItemValue] = []
	
	for item_ in items:
		if (item_.area_alias == area_alias_ and 
			item_.type == type_
		):
			items_.push_back(item_)
	
	return items_
	
func add_item(item_: LevelItemValue):
	add_item_before.emit(item_)
	
	items.push_back(item_)
	
	if (item_.area_alias != &"" and 
		item_.area_alias == Core.game.get_level_area_alias()
	):
		await populate_item(item_)

	add_item_after.emit(item_)
	
func remove_item(item_: LevelItemValue) -> void:
	for index in items.size():
		if items[index] == item_:
			remove_item_before.emit(items[index])
			await depopulate_item(items[index])
			
			var removed_item_: LevelItemValue = items[index]
			
			items.remove_at(index)
			
			removed_item_.node = null
			remove_item_after.emit(removed_item_)
			break

func remove_items() -> void:
	for index in range(items.size() - 1, -1, -1):
		remove_item_before.emit(items[index])
		await depopulate_item(items[index])
		
		var removed_item_: LevelItemValue = items[index]
		
		items.remove_at(index)
		
		removed_item_.node = null
		remove_item_after.emit(removed_item_)

func remove_items_from_area(area_alias_: StringName) -> void:
	for index in range(items.size() - 1, -1, -1):
		if items[index].area_alias == area_alias_:
			remove_item_before.emit(items[index])
			await depopulate_item(items[index])
			
			var removed_item_: LevelItemValue = items[index]
			
			items.remove_at(index)
		
			removed_item_.node = null
			remove_item_after.emit(items[index])
