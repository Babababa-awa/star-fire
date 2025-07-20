extends Node
class_name BaseGame

var _level_alias: StringName = &""
var current_level = null
var current_player: PlayerUnit = null
var current_cursor: BaseCursor = null

var is_paused: bool = false
var _pause_volume: float = 0.0
var is_enabled: bool = true

var is_lose: bool = false
var _is_lose_handeld = false
var is_win: bool = false
var _is_win_handeld = false
var is_started = false

func _init() -> void:
	Core.nodes = NodeLoader.new()
	Core.game = self
	Core.items = ItemLoader.new()
	Core.items.load_data()
	
	if Core.ENABLE_LEVEL_SELECT:
		Core.level_select = LevelSelectLoader.new()
		Core.level_select.load_data()
		
	Core.help = Help.new()
	Core.audio = Audio.new()
	Core.speech = Speech.new()
	Core.states = {}
	
	Core.settings = Settings.new()
	Core.settings.load_settings()
	
	Core.save = Save.new()
	Core.save.load_game()

func _ready() -> void:
	Core.hud = $UI/Hud
	Core.camera = $Level/Camera
	
	await menu()
	is_started = true
	
func start() -> void:
	await start_level(Core.START_LEVEL)
	
func start_level(level_alias_: StringName) -> void:
	if Core.hud != null:
		await Core.hud.start()
		
	_level_alias = level_alias_
	await reset(Core.ResetType.START)
	
func restart() -> void:
	if Core.hud != null:
		await Core.hud.restart()
		
	await reset(Core.ResetType.RESTART)

func refresh() -> void:
	if Core.hud != null:
		Core.hud.refresh()
		
	await reset(Core.ResetType.REFRESH)
	
func reset(reset_type_: Core.ResetType) -> void:
	if current_level == null:
		reset_type_ = Core.ResetType.START
	
	if reset_type_ == Core.ResetType.START:
		if _level_alias == &"":
			_level_alias = Core.START_LEVEL
		
		level(_level_alias)
	elif reset_type_ == Core.ResetType.RESTART:
		show_ui(&"loading")
		
		reset_player()
		reset_game()
		
		Core.nodes.free_all()
		Core.states.clear()
		Core.speech.reset()
			
		start_load()
		_hide_mouse()
		hide_uis(Core.UIType.MENU)
		hide_uis(Core.UIType.GAME)
		
		await current_level.restart()

func menu() -> void:
	show_ui(&"loading")
	
	if is_started:
		reset_level()
		reset_player()
		reset_game()
		
		Core.nodes.reset()
		Core.help.reset()
		Core.audio.reset()
		Core.states.clear()
		Core.speech.reset()
	
	start_load()
	
	if is_started:
		_show_mouse()
		hide_uis(Core.UIType.GAME)
		
	await change_level(Core.MENU_LEVEL, Core.LevelMode.MENU)
	
func level(level_alias_: StringName) -> void:
	show_ui(&"loading")
	
	reset_level()
	reset_player()
	reset_game()
	
	Core.nodes.reset()
	Core.help.reset()
	Core.audio.reset()
	if level_alias_ == Core.START_LEVEL:
		Core.states.clear()
	Core.speech.reset()
	
	start_load()	
	_show_mouse()
	hide_uis(Core.UIType.MENU)
	
	await change_level(level_alias_, Core.LevelMode.GAME)

func reset_game() -> void:
	reset_state()
	reset_win_lose()
	
func reset_player() -> void:
	reset_cursor()

	if current_player != null:
		current_player.queue_free()
		current_player = null
	
	Core.player = null

func reset_level() -> void:
	$Level.visible = false
	hide_uis(Core.UIType.GAME)
	
	if current_level != null:
		$Level.remove_child(current_level)
		current_level.queue_free()
		current_level = null
		Core.level = null
		
func reset_cursor() -> void:
	if current_cursor != null:
		$Level.remove_child(current_cursor)
		current_cursor.queue_free()
		current_cursor = null
		Core.cursor = null

func reset_state() -> void:
	is_paused = false
	Engine.time_scale = 1
	is_enabled = true
	
	if Core.camera != null:
		Core.camera.position_smoothing_enabled = true

func reset_win_lose() -> void:
	is_lose = false
	_is_lose_handeld = false
	is_win = false
	_is_win_handeld = false

func add_modes(mode_: StringName) -> void:
	if Core.level: Core.level.add_mode(mode_, true)
	if Core.player: Core.player.add_mode(mode_, true)
	
func remove_mode(mode_: StringName) -> void:
	if Core.level != null: 
		Core.level.remove_mode(mode_, true)
		
	if Core.player != null: 
		Core.player.remove_mode(mode_, true)
	
	if Core.cursor != null: 
		Core.player.remove_mode(mode_, true)
		
	if Core.hud != null and Core.hud is BaseNode2D: 
		Core.hud.remove_mode(mode_, true)

func add_level_child(node: Node2D) -> void:
	$Level.add_child(node)

func remove_level_child(node: Node2D) -> void:
	$Level.remove_child.call_deferred(node)

func get_level_alias() -> StringName:
	if Core.level != null:
		return Core.level.alias
		
	return &""
	
func get_level_area_alias() -> StringName:
	if Core.level != null and Core.level.area != null:
			return Core.level.area.alias
	
	return &""

func change_level(
	level_alias_: StringName,
	level_mode_: Core.LevelMode = Core.LevelMode.GAME
) -> void:
	if current_level == null or current_level.alias != level_alias_:
		reset_level()
		
		var level_path = "res://scenes/level/" + level_alias_ + ".tscn"
		
		var level = await load(level_path).instantiate()

		$Level.add_child(level)
			
		current_level = level
		Core.level = level
		level.set_level_mode(level_mode_)

		level.started.connect(_level_started)

		await level.start()
		
		$Level.visible = true
	else:
		start_load()
		current_level.set_level_mode(level_mode_)
		await current_level.restart()
		
func change_player(player_alias: StringName) -> void:
	if current_player and current_player.alias == player_alias:
		current_player.reset(Core.ResetType.RESTART)
		return
		
	reset_player()
	
	var player_path = "res://scenes/unit/player/" + player_alias + ".tscn"
	
	var player = await load(player_path).instantiate()

	$Level.add_child(player)
	current_player = player
	Core.player = player
	
	player.start()
	
func set_player_position(position: Vector2i) -> void:
	assert(current_player != null, "Player is not loaded.")
	current_player.position = position
	
func change_cursor(cursor_alias: StringName) -> void:
	if current_cursor and current_cursor.alias == cursor_alias:
		current_cursor.reset(Core.ResetType.RESTART)
		return
		
	reset_cursor()
	
	var cursor_path = "res://scenes/cursor/" + cursor_alias + ".tscn"
	
	var cursor = await load(cursor_path).instantiate()

	current_cursor = cursor
	Core.cursor = cursor
	
	$Level.add_child(cursor)
	
	cursor.start()	

func _level_started(_reset_type: Core.ResetType) -> void:
	end_load()
	hide_ui(&"loading")
	
func start_load() -> void:
	if Core.camera != null:
		Core.camera.position_smoothing_enabled = false
	is_enabled = false
	#Engine.time_scale = 0
	
func end_load() -> void:
	if Core.camera != null:
		Core.camera.position_smoothing_enabled = true
	#Engine.time_scale = 1
	is_enabled = true

func _process(delta_: float) -> void:
	_handle_pause()
	
	if not is_enabled:
		return
		
	Core.speech.process(delta_)
	
	if is_lose and not _is_lose_handeld:
		_is_lose_handeld = true
		_show_mouse()
		show_ui(&"lose")
		
	if is_win and not _is_win_handeld:
		_is_win_handeld = true
		_show_mouse()
		show_ui(&"win")

func _physics_process(_delta: float) -> void:
	pass

func _handle_pause() -> void:
	if Input.is_action_just_pressed("game_pause") and current_level != null:
		toggle_pause()
		
func toggle_pause() -> void:
	if is_paused:
		is_paused = false
		is_enabled = true
		Engine.time_scale = 1
		if get_ui(&"settings").visible:
			var music_bus = AudioServer.get_bus_index("Music")
			_pause_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
		_increase_music_volume()
		_hide_mouse()
		hide_uis(Core.UIType.MENU)
	elif _can_pause():
		Engine.time_scale = 0
		is_enabled = false
		is_paused = true
		_decrease_music_volume()
		_show_mouse()
		show_ui(&"pause")

func _can_pause() -> bool:
	if not is_enabled:
		return false
		
	if has_visible_uis(Core.UIType.MENU):
		return false
	
	if current_level != null and current_level.level_mode == Core.LevelMode.MENU:
		return false
		
	if is_ui_visible(&"win"):
		return false
	
	if is_ui_visible(&"lose"):
		return false
		
	return true

func get_ui(id: StringName) -> BaseUI:
	for child in $UI.get_children():
		if child is BaseUI and child.id == id:
			return child
		
	return null
	
func has_visible_uis(ui_type: Core.UIType) -> bool:
	for child in $UI.get_children():
		if child is BaseUI and child.ui_type == ui_type and child.visible:
			return true
		
	return false

func is_ui_visible(id: StringName) -> bool:
	var ui = get_ui(id)
	
	if ui != null and ui.visible == true:
		return true
		
	return false

func hide_uis(ui_type: Core.UIType) -> void:
	for child in $UI.get_children():
		if child is BaseUI and child.ui_type == ui_type:
			child.hide_ui()
			
	if ui_type == Core.UIType.GAME and Core.hud != null:
		Core.hud.visible = false

func hide_ui(id: StringName) -> void:
	var ui = get_ui(id)
	if ui != null:
		ui.hide_ui()
	elif id == &"hud" and Core.hud != null:
		Core.hud.visible = false
			
func show_ui(id: StringName) -> void:
	var ui = get_ui(id)
	if ui != null:
		ui.show_ui()
	elif id == &"hud" and Core.hud != null:
		Core.hud.visible = true
	
func prepare_ui_id(id_: StringName, from_id_: StringName) -> StringName:
	if id_ != &"parent":
		if id_ == &"difficulty" and not Core.ENABLE_GAME_DIFFICULTY:
			id_ = &"level_select"
	
		if id_ == &"level_select" and not Core.ENABLE_LEVEL_SELECT:
			id_ = &"start"
			
		return id_
		
	if is_paused:
		return &"pause"
		
	if from_id_ == &"level_select" and Core.ENABLE_GAME_DIFFICULTY:
		return &"difficulty"
		
	return &"menu"
		
func prepare_ui(id: StringName, from_id: StringName) -> void:
	if id == &"menu":
		if current_level != null and current_level.level_mode != Core.LevelMode.MENU:
			menu()
	if id == &"settings" and from_id == &"pause":
		_increase_music_volume()
	elif id == &"pause"	and from_id == &"settings":
		_decrease_music_volume()
	
func _increase_music_volume() -> void:
	if _pause_volume == 0.0:
		return
		
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(_pause_volume))
	AudioServer.set_bus_mute(music_bus, _pause_volume < 0.05)
	_pause_volume = 0.0
	
func _decrease_music_volume() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	_pause_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	
	if _pause_volume != 0.0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(_pause_volume / 3))
		AudioServer.set_bus_mute(music_bus, _pause_volume / 3 < 0.05)
		
	
func _hide_mouse() -> void:
	if Core.ENABLE_MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
		if Core.cursor:
			Core.cursor.visible = true

func _show_mouse() -> void:
	if Core.ENABLE_MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		if Core.cursor:
			Core.cursor.visible = false

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Core.last_joypad_device = event.device

func exit():
	get_tree().quit()
