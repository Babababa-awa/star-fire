extends BaseDataLoader
class_name LevelSelectLoader

func load_data() -> void:
	super.load_data()

	_data = _load_json_data("res://data/level_select.json")

func get_data() -> Dictionary:
	return _data

func has_level(level_alias_: StringName) -> bool:
	return _data.levels.has(level_alias_)

func has_next_level(currnet_level_alias_: StringName) -> bool:
	var index: int = _data.levels.find(currnet_level_alias_)

	if index == -1:
		return false
		
	index += 1
	
	if index == _data.levels.size():
		return false
		
	return true
	
func get_next_level(currnet_level_alias_: StringName) -> StringName:
	var index: int = _data.levels.find(currnet_level_alias_)
	
	if index == -1:
		assert(false, "Level not found. (" + currnet_level_alias_ + ")")
		
	index += 1
	
	if index == _data.levels.size():
		assert(false, "Level is last. (" + currnet_level_alias_ + ")")
	
	return _data.levels[index]
	
func _load_json_data(file: String) -> Dictionary:
	var json_data = _load_json_file(file)

	if not json_data.is_empty():
		json_data = _format_data(json_data)
		
	return json_data

func _format_data(json_data: Dictionary) -> Dictionary:
	if not json_data.has("levels"):
		json_data.levels = []
	
	for index in json_data.levels.size():
		json_data.levels[index] = StringName(json_data.levels[index])

	return json_data
