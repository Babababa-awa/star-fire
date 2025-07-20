extends BaseDataLoader
class_name ItemLoader

func load_data() -> void:
	super.load_data()

	_data = _load_data("res://data/item")

func get_data() -> Dictionary:
	return _data

func has_item(alias_: StringName) -> bool:
	if _data.has(alias_):
		return true
	
	if Core.level is AreaLevel:
		return Core.level.data.has_item(alias_)
				
	return false
	
func get_item(alias_: StringName) -> ItemValue:
	if has_item(alias_):
		return _data[alias_]
		
	if Core.level is AreaLevel:
		if Core.level.data.has_item(alias_): # Level specific items
			return Core.level.data.get_item(alias_)

	assert(false, "Item not found. (" + alias_ + ")")
	return null

func _load_data(base_path: String) -> Dictionary:
	var data: Dictionary = {}
	
	var dir = DirAccess.open(base_path)
	
	if dir == null:
		return data

	dir.list_dir_begin()
	
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			var sub_map = _load_data(base_path + "/" + file_name)
			data.merge(sub_map)  # Merge results
		elif file_name.ends_with(".json"):
			var item_value_ = _load_item_value(base_path + "/" + file_name)
			
			if item_value_ != null:
				data[item_value_.alias] = item_value_
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
	return data
	
func _load_item_value(file: String) -> ItemValue:
	var json_data_ = _load_json_file(file)
	
	if json_data_.is_empty():
		return null
		
	if not json_data_.has("alias"):
		json_data_.alias = file.get_basename().get_file()
	
	return ItemDataFormatter.get_value(json_data_)

func get_item_unit(item_value_: ItemValue) -> ItemUnit:
	var path
			
	if item_value_.scene != null and item_value_.scene.is_path:
		path = item_value_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_value_.alias + ".tscn"

	var node: Node
	
	# If the node doesn't exist, just load it
	if Core.nodes.scenes.has(path):
		node = await Core.nodes.scenes[path].instantiate()
	else:
		node = await load(path).instantiate()
		
	if node == null or not node is ItemUnit:
		return null
		
	node.set_item_value(item_value_)
	
	return node

func get_level_item_unit(item_value_: ItemValue) -> ItemUnit:
	var path
			
	if item_value_.scene != null and item_value_.scene.is_path:
		path = item_value_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_value_.alias + ".tscn"

	var node: Node = await Core.nodes.get_node(path)
		
	if node == null or not node is ItemUnit:
		return null
		
	node.set_item_value(item_value_)
	
	return node
