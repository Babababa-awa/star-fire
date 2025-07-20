extends BaseDataLoader
class_name BaseLevelDataLoader

var level_alias: StringName

func _init(level_alias_: StringName) -> void:
	level_alias = level_alias_

func load_data() -> void:
	super.load_data()

	_data[Core.DataType.AREA] = _load_data(Core.DataType.AREA, "res://data/level/" + level_alias + "/area")
	_data[Core.DataType.OBJECT] = _load_data(Core.DataType.OBJECT, "res://data/level/" + level_alias + "/object")
	_data[Core.DataType.ITEM] = _load_data(Core.DataType.ITEM, "res://data/level/" + level_alias + "/item")
	_data[Core.DataType.LEVEL] = _load_data_from_json(Core.DataType.LEVEL, "res://data/level/" + level_alias + "/level.json")

func get_data() -> Dictionary:
	return _data
	
func get_area_data() -> Array[Dictionary]:
	return _data[Core.DataType.AREA]

func get_object_data() -> Array[Dictionary]:
	return _data[Core.DataType.OBJECT]

func get_item_data() -> Array[ItemValue]:
	return _data[Core.DataType.ITEM]
	
func get_level_data() -> Dictionary:
	return _data[Core.DataType.LEVEL]
	
func has_from_alias(data_type: Core.DataType, alias: StringName) -> bool:
	if _data[data_type] is Dictionary:
		if _data[data_type].alias == alias:
			return true
	else:
		for value in _data[data_type]:
			if value.alias == alias:
				return true
				
	return false

func get_from_alias(data_type: Core.DataType, alias: StringName):
	if _data[data_type] is Dictionary:
		if _data[data_type].alias == alias:
			return _data[data_type]
	else:
		for value in _data[data_type]:
			if value.alias == alias:
				return value
				
	assert(false, "Data not found. (" + str(data_type) + ", " + alias + ")")
	return {}
	
func get_area(area_alias_: StringName) -> Dictionary:
	return get_from_alias(Core.DataType.AREA, area_alias_)
	
func get_object(object_alias_: StringName) -> Dictionary:
	return get_from_alias(Core.DataType.OBJECT, object_alias_)

func has_item(item_alias_: StringName) -> bool:
	return has_from_alias(Core.DataType.ITEM, item_alias_)
	
func get_item(item_alias_: StringName) -> ItemValue:
	return get_from_alias(Core.DataType.ITEM, item_alias_)

func _load_data(data_type: Core.DataType, base_path: String) -> Array:
	var data: Array[Dictionary] = []
	
	var dir = DirAccess.open(base_path)
	
	if dir == null:
		if data_type == Core.DataType.OBJECT:
			return data
			
		if data_type == Core.DataType.ITEM:
			return data
		
		assert(dir != null, "Data directory is empty.")

	dir.list_dir_begin()
	
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			var sub_map = _load_data(data_type, base_path + "/" + file_name)
			data.append_array(sub_map)  # Merge results
		elif file_name.ends_with(".json"):
			var current_data_ = _load_data_from_json(data_type, base_path + "/" + file_name)
			if current_data_ is Dictionary:
				if not current_data_.is_empty():
					data.push_back(current_data_)
			elif current_data_ != null:
				data.push_back(current_data_)
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
	return data
	
func _load_data_from_json(data_type: Core.DataType, file: String):
	var json = _load_json_file(file)
	
	if json.is_empty():
		return json
		
	if not json.has("alias"):
		json.alias = file.get_basename().get_file()

	json = _format_data(data_type, json)
	
	return json

func _format_data(_data_type: Core.DataType, json_data: Dictionary):
	return json_data
