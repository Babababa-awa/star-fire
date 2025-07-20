extends BaseDataLoader
class_name AudioDataLoader

func load_data() -> void:
	super.load_data()

	_data[Core.AudioType.MUSIC] = {} # TODO: For future audio features
	_data[Core.AudioType.AMBIENCE] = {}
	_data[Core.AudioType.SFX] = _load_json_data(Core.AudioType.SFX, "res://data/audio/sfx.json")

func get_data() -> Dictionary:	
	return _data

func has_from_alias(audio_type: Core.AudioType, alias: StringName) -> bool:
	return _data[audio_type].has(alias)
	
func get_from_alias(audio_type: Core.AudioType, alias: StringName) -> Dictionary:
	if has_from_alias(audio_type, alias):
		return _data[audio_type][alias]
			
	assert(false, "Audio not found. (" + str(audio_type) + ", " + alias + ")")
	return {}
	
func has_sfx(alias_: StringName) -> bool:
	return has_from_alias(Core.AudioType.SFX, alias_)
	
func get_sfx(alias_: StringName) -> Dictionary:
	return get_from_alias(Core.AudioType.SFX, alias_)
	
func _load_json_data(audio_type: Core.AudioType, file: String) -> Dictionary:
	var json = _load_json_file(file)
	
	if not json.is_empty():
		json = _format_data(audio_type, json)
		
	return json

func _format_data(_audio_type: Core.AudioType, json_data: Dictionary) -> Dictionary:
	var data_: Dictionary = {}
	
	for key in json_data:
		var item_: Dictionary = json_data[key]
		
		if item_.has("format"):
			item_.format = StringName(item_.format)
		else:
			item_.format = &""

		if not item_.has("count"):
			item_.count = 1
			
		if not item_.has("rand"):
			item_.rand = false
			
		if not item_.has("pitch"):
			item_.pitch = false
		elif item_.pitch:
			if not item_.has("min_pitch"):
				item_.min_pitch = Core.MIN_AUDIO_PITCH

			if not item_.has("max_pitch"):
				item_.max_pitch = Core.MAX_AUDIO_PITCH
		
		data_[StringName(key)] = item_
			
	return data_
		
