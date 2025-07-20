class_name BaseDataLoader

var has_loaded: bool = false
var _data: Dictionary = {}

func load_data() -> void:
	assert(has_loaded == false, "Data has already been loaded.")
	
	has_loaded = true
	
func _load_json_file(file: String) -> Dictionary:
	var handle = FileAccess.open(file, FileAccess.READ)
	if not handle:
		return {}
	
	var contents = handle.get_as_text()
	handle.close()

	var json = JSON.new()
	
	if json.parse(contents) != OK:
		return {}
	
	return json.data
