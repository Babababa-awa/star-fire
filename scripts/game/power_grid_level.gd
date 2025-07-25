extends PlatformerLevel
class_name PowerGridLevel

var power_grid: PowerGrid

var _remove_item: bool = false
var _remove_coords: Vector2i = Vector2i.ZERO
var _adjacent_components: Array[LevelItemValue] = []

var _is_launching: bool = false
var _launch_delay = 0.75
var _awawa: bool = false

func _init(alias_: StringName) -> void:
	super._init(alias_)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
		
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		Core.game.day_night_cycle.pause_time = false
		Core.game.day_night_cycle.initial_hour = 10
		Core.audio.play_ambience(&"day")
	
		_is_launching = false
		_launch_delay = 0.75
		_awawa = false
	
		power_grid = PowerGrid.new()
		
		var level_item_values_ = items.get_items_from_type(Core.ItemType.COMPONENT)

		for level_item_value_ in level_item_values_:
			if not level_item_value_.node:
				continue
			
			var coords: Vector2i = _get_power_grid_coords(level_item_value_.node.global_position)
			power_grid.add_component(coords, level_item_value_)
			level_item_value_.node.update_component()
			
		items.add_item_after.connect(_on_item_added_after)
		items.remove_item_before.connect(_on_item_removed_before)
		items.remove_item_after.connect(_on_item_removed_after)
		

func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
		
	if _is_launching:
		_launch_delay -= delta_
		if _launch_delay <= 0.0:
			power_grid.launch()
			_is_launching = false
	elif not _awawa:
		var time = get_play_time()
		if time > 900000:
			_awawa = true
			Core.audio.play_sfx(&"awawawawaaaaaaaa")
			Core.speech.say(SpeechValue.new(
				Core.player,
				"AWAWAWAWAWAWAWAWA",
				2.5,
				Core.SpeechStyle.TALK,
				Core.SpeechSize.MEDIUM,
			))		

func _get_power_grid_coords(position: Vector2) -> Vector2i:
	var coords = position / Core.TILE_SIZE
	return coords.floor()

func _on_item_added_after(level_item_value_: LevelItemValue) -> void:
	if level_item_value_.node is ItemComponentUnit:
		var coords: Vector2i = _get_power_grid_coords(level_item_value_.node.position)
		power_grid.add_component(coords, level_item_value_)
		level_item_value_.node.update_component()
		power_grid.update_power_levels()
	
func _on_item_removed_before(level_item_value_: LevelItemValue) -> void:
	if level_item_value_.node is ItemComponentUnit:
		_remove_item = true
		_remove_coords = _get_power_grid_coords(level_item_value_.node.position)
		_adjacent_components = []
		
		var rect_: Rect2 = level_item_value_.node.get_position_rect()
		_adjacent_components.push_back(items.get_adjacent_item(rect_, Core.Edge.TOP))
		_adjacent_components.push_back(items.get_adjacent_item(rect_, Core.Edge.BOTTOM))
		_adjacent_components.push_back(items.get_adjacent_item(rect_, Core.Edge.LEFT))
		_adjacent_components.push_back(items.get_adjacent_item(rect_, Core.Edge.RIGHT))
		
	else:
		_remove_item = false
		
func _on_item_removed_after(level_item_value_: LevelItemValue) -> void:
	if _remove_item:
		power_grid.remove_component(_remove_coords)
		
		for component_ in _adjacent_components:
			if component_ != null or component_ == level_item_value_:
				component_.node.update_component()
			
		power_grid.update_power_levels()

func win() -> void:
	Core.player.velocity = Vector2.ZERO
	Core.player.set_unit_mode(Core.UnitMode.NONE)
	Core.game.hide_ui(&"hud")
	
	var level_: String = str(alias)
	
	if not Core.save.data.has(level_):
		Core.save.data[level_] = {}
	
	Core.save.data[level_].win = true
	Core.save.save_game()
	
	var launch_view_position: Vector2 = power_grid.launch_view_position()
	
	var offset_: Vector2 = Vector2(
		-Core.player.global_position.x + launch_view_position.x,
		-Core.player.global_position.y - 1024.0
	)
	Core.camera.target_offset = offset_
	
	if (Core.game.day_night_cycle.past_hour < 18 or
		Core.game.day_night_cycle.past_hour > 4
	):
		Core.audio.play_ambience(&"night")
		Core.game.day_night_cycle.goto_night()

	_is_launching = true

	Core.player.win.win()
	
func lose() -> void:
	#print("lose")
	pass
