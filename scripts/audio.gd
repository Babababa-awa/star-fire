class_name Audio

var _data: AudioDataLoader
var sfx = {}
var music = {}
var ambience = {}
var last = {}

func _init() -> void:
	_data = AudioDataLoader.new()
	_data.load_data()

func reset() -> void:
	reset_state()
	reset_audio()
	
func reset_state() -> void:
	stop_music()
	last.clear()
	
func reset_audio() -> void:
	reset_sfx()
	reset_music()
	reset_ambience()
	
func reset_sfx() -> void:
	for name in sfx:
		Core.game.remove_child(sfx[name])
	sfx = {}
	
func reset_music() -> void:
	for name in music:
		Core.game.remove_child(music[name])
	music = {}

func reset_ambience() -> void:
	for name in ambience:
		Core.game.remove_child(ambience[name])
	ambience = {}

func play_music(name: StringName, fade_time: float = 0.0) -> void:
	_play(Core.AudioType.MUSIC, name, &"", fade_time)

# Stop all music but name if specified
func stop_music(name: StringName = &"", fade_time: float = 0.0) -> void:
	_stop(Core.AudioType.MUSIC, name, fade_time)
	
func load_music(name: StringName) -> void:
	_load(Core.AudioType.MUSIC, name)
	
func unload_music(name: StringName) -> void:
	_unload(Core.AudioType.MUSIC, name)

func play_sfx(name: StringName):
	var count: int = 1
	var rand: bool = false
	var suffix: StringName = &""
	
	if _data.has_sfx(name):
		var data_ = _data.get_sfx(name)
		count = data_.count
		rand = data_.rand
	
	if count == 0:
		return
		
	var last_name = _get_last_name(Core.AudioType.SFX, name)
	
	if count > 1:
		if rand:
			var index: int
			
			while true:
				index = randi() % count + 1
				if not last.has(last_name) or last[last_name] != index:
					break
			
			last[last_name] = index	
			suffix = &"_" + str(last[last_name])
		else:
			if not last.has(last_name) or last[last_name] == count:
				last[last_name] = 1
				suffix = &"_1"
			else:
				last[last_name] += 1
				suffix = &"_" + str(last[last_name])

	_play(Core.AudioType.SFX, name, suffix)

func load_sfx(name: StringName):
	_load(Core.AudioType.SFX, name)

func unload_sfx(name: StringName) -> void:
	_unload(Core.AudioType.SFX, name)
	
func play_ambience(name: StringName, fade_time: float = 0.0) -> void:
	_play(Core.AudioType.AMBIENCE, name, &"", fade_time)

func stop_ambience(name: StringName = &"", fade_time: float = 0.0) -> void:
	_stop(Core.AudioType.AMBIENCE, name, fade_time)
	
func load_ambience(name: StringName):
	_load(Core.AudioType.AMBIENCE, name)

func unload_ambience(name: StringName) -> void:
	_unload(Core.AudioType.AMBIENCE, name)
	
func get_volume(type: Core.AudioType) -> float:
	var bus: int = _get_audio_bus_index(type)
	return db_to_linear(AudioServer.get_bus_volume_db(bus))
	
func set_volume(type: Core.AudioType, value: float) -> void:
	var bus: int = _get_audio_bus_index(type)

	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value < 0.05)

func _play(type: Core.AudioType, name: StringName, suffix: StringName = &"", fade_time: float = 0.0) -> void:
	var audio = _get_audio(type)

	_load(type, name, suffix)

	var pitch: float = 1.0
	
	if _data.has_from_alias(type, name):
		var data_ = _data.get_from_alias(type, name)
		if data_.pitch:
			pitch = randf_range(data_.min_pitch, data_.max_pitch)
	
	audio[name + suffix].pitch_scale = pitch
	
	if type == Core.AudioType.SFX:
		audio[name + suffix].play()
	else:
		_stop(type, name)

		if audio[name].playing:
			return
		
		var last_name = _get_last_name(type, name)
		if not last.has(last_name):
			last[last_name] = 0.0
		
		audio[name].play(last[last_name])
		
		if fade_time != 0.0:
			audio[name].volume_db = -80.0
			var tween = Core.game.create_tween()
			tween.tween_property(audio[name], "volume_db", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		

func _stop(type: Core.AudioType, name: StringName = &"", fade_time: float = 0.0) -> void:
	var audio = _get_audio(type)
	
	for existing_name in audio:
		if existing_name == name:
			continue
			
		if not audio[existing_name].playing:
			continue
			
		if fade_time != 0.0:
			var tween = Core.game.create_tween()
			tween.tween_property(audio[existing_name], "volume_db", -80.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_callback(_stop.bind(type, existing_name))
			continue
		 
		if type != Core.AudioType.SFX:
			var last_name = _get_last_name(type, existing_name)
			last[last_name] = audio[existing_name].get_playback_position()
		audio[existing_name].stop()
		audio[existing_name].volume_db = 0.0


func _load(type: Core.AudioType, name: StringName, suffix: StringName = &"") -> void:
	var audio = _get_audio(type)
	
	if audio.has(name + suffix):
		return
	
	var path = _get_path(type)	
	var audio_player = AudioStreamPlayer.new()
	
	match type:
		Core.AudioType.SFX:
			audio_player.bus = &"SFX"
		Core.AudioType.MUSIC:
			audio_player.bus = &"Music"
		Core.AudioType.AMBIENCE:
			audio_player.bus = &"Ambience"
	
	var format: StringName = &""
	if _data.has_from_alias(type, name):
		var data_ = _data.get_from_alias(type, name)
		format = data_.format

	if format != &"":
		audio_player.stream = load("res://assets/audio/" + path + "/" + name + suffix + "." + format)
	else:
		if ResourceLoader.exists("res://assets/audio/" + path + "/" + name + suffix + ".ogg"):
			audio_player.stream = load("res://assets/audio/" + path + "/" + name + suffix + ".ogg")
		elif ResourceLoader.exists("res://assets/audio/" + path + "/" + name + suffix + ".mp3"):
			audio_player.stream = load("res://assets/audio/" + path + "/" + name + suffix + ".mp3")
		else:
			audio_player.stream = load("res://assets/audio/" + path + "/" + name + suffix + ".wav")
	
	Core.game.add_child(audio_player)
	
	audio[name + suffix] = audio_player
	
func _unload(type: Core.AudioType, name: StringName) -> void:
	var audio = _get_audio(type)
	
	if type == Core.AudioType.SFX:
		var count: int = 1
		
		if _data.has_from_alias(type, name):
			var data_ = _data.get_from_alias(type, name)
			count = data_.count
			
		if count > 1:
			for i in count:
				if audio.has(name + "_" + str(count + 1)):
					Core.game.remove_child(audio[name + "_" + str(count + 1)])
		elif audio.has(name):
			Core.game.remove_child(audio[name])
	else:
		if audio.has(name):
			Core.game.remove_child(audio[name])

func _get_audio(type: Core.AudioType) -> Dictionary:
	match type:
		Core.AudioType.SFX:
			return sfx
		Core.AudioType.MUSIC:
			return music
		Core.AudioType.AMBIENCE:
			return ambience
			
	assert(false, "Invalid Core.AudioType passed.")
	return {} 

func _get_path(type: Core.AudioType) -> String:
	match type:
		Core.AudioType.SFX:
			return "sfx"
		Core.AudioType.MUSIC:
			return "music"
		Core.AudioType.AMBIENCE:
			return "ambience"
			
	assert(false, "Invalid Core.AudioType passed.")
	return ""
	
func _get_last_name(type: Core.AudioType, name: StringName) -> String:
	match type:
		Core.AudioType.SFX:
			return "sfx." + name
		Core.AudioType.MUSIC:
			return "music." + name
		Core.AudioType.AMBIENCE:
			return "ambience." + name
			
	assert(false, "Invalid Core.AudioType passed.")
	return ""

func _get_audio_bus_index(type: Core.AudioType) -> int:
	match type:
		Core.AudioType.SFX:
			return AudioServer.get_bus_index(&"SFX")
		Core.AudioType.MUSIC:
			return AudioServer.get_bus_index(&"Music")
		Core.AudioType.AMBIENCE:
			return AudioServer.get_bus_index(&"Ambience")
		Core.AudioType.MASTER:
			return AudioServer.get_bus_index(&"Master")
			
	assert(false, "Invalid Core.AudioType passed.")
	return 0
