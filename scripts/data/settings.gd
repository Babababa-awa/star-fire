class_name Settings

const FILE_PATH = "user://settings.json"

var _data: Dictionary = {
	"locale": "en",
	"audio": {
		"master": 0.5,
		"sfx": 0.5,
		"music": 0.5,
		"ambience": 0.5
	},
	"mouse_speed: float": 1.0,
	"joystick_speed_slow": 1.0,
	"joystick_speed_fast": 1.0
}

func _init() -> void:
	_load_settings_from_data(_data)

func save_settings() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if not file:
		return

	_data.locale = Core.locale
	_data.audio.master = Core.audio.get_volume(Core.AudioType.MASTER)
	_data.audio.music = Core.audio.get_volume(Core.AudioType.MUSIC)
	_data.audio.sfx = Core.audio.get_volume(Core.AudioType.SFX)
	_data.audio.ambience = Core.audio.get_volume(Core.AudioType.AMBIENCE)
	_data.mouse_speed = Core.mouse_speed
	_data.joystick_speed_slow = Core.joystick_speed_slow
	_data.joystick_speed_fast = Core.joystick_speed_fast
		
	file.store_string(JSON.stringify(_data))
	file.close()

func save():
	pass
	
func load_settings() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		return
		
	var file: FileAccess = FileAccess.open(FILE_PATH, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	var data_ = JSON.parse_string(content)
	
	if not data_ is Dictionary:
		return
		
	_load_settings_from_data(data_)
		
func _load_settings_from_data(data_: Dictionary) -> void:
	if data_.has("locale"):
		Core.locale = data_.locale
		if TranslationServer.get_locale() != Core.locale and TranslationServer.get_locale().substr(0, 3) != Core.locale + "_":
			TranslationServer.set_locale(Core.locale)

	if data_.has("audio") and data_.audio is Dictionary:
		if data_.audio.has("master"):
			Core.audio.set_volume(Core.AudioType.MASTER, data_.audio.master)
			_data.audio.master = data_.audio.master
		
		if data_.audio.has("music"):
			Core.audio.set_volume(Core.AudioType.MUSIC, data_.audio.music)
			_data.audio.music = data_.audio.music
		
		if data_.audio.has("sfx"):
			Core.audio.set_volume(Core.AudioType.SFX, data_.audio.sfx)
			_data.audio.sfx = data_.audio.sfx
			
		if data_.audio.has("ambience"):
			Core.audio.set_volume(Core.AudioType.AMBIENCE, data_.audio.ambience)
			_data.audio.ambience = data_.audio.ambience
	
	if data_.has("mouse_speed"):
		Core.mouse_speed = data_.mouse_speed
		_data.mouse_speed = data_.mouse_speed
	
	if data_.has("joystick_speed_slow"):
		Core.mouse_speed = data_.joystick_speed_slow
		_data.joystick_speed_slow = data_.joystick_speed_slow
	
	if data_.has("joystick_speed_fast"):
		Core.mouse_speed = data_.joystick_speed_fast
		_data.joystick_speed_fast = data_.joystick_speed_fast
