class_name Save

const FILE_PATH = &"user://save.json"

var data: Dictionary = {}

func _init() -> void:
	_load_save_fromdata(data)

func save_game() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	
	if not file:
		return
		
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_game() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		return
		
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	var data_ = JSON.parse_string(content)
	
	if not data_ is Dictionary:
		return
		
	_load_save_fromdata(data_)
		
func _load_save_fromdata(data_: Dictionary) -> void:
	data = data_
