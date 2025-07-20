extends PlayerPlatformerUnit

@onready var animations: AnimationController = %Animationsw

var is_knife_selected: bool = false
var is_knife_stab: bool = false
var is_knife_stab_animation: bool = false

var is_umbrella_selected: bool = false

var current_ladder_climbing_delta: float = 0.0
var is_starving: bool = false

func _init() -> void:
	super._init(&"jelly")
	
	alignment = Core.Alignment.BOTTOM_CENTER
		
	actors.add_all({
		#&"accessory": ItemsActor.new(self),
		&"speech": SpeechActor.new(self),
	})
	
	jump.is_enabled_default = false
	climb.is_enabled_default = false
	fall.is_enabled_default = false
	weapons.is_enabled_default = false
	life.is_enabled_default = false
	
	move.slow_move_speed = 180.0
	move.normal_move_speed = 420.0
	move.fast_move_speed = 480.0
	move.normalize_move_speed = true
	
	items.slots = 1
	items.item_collision_mode = Core.ItemCollisionMode.TILE
	items.drop_swap = true
	items.pick_up_swap = true
	items.drop_offset = Vector2(0, -4.0)
	items.unit_alignment = Core.Alignment.BOTTOM_CENTER
	items.item_alignment = Core.Alignment.TOP_LEFT
	items.pick_up_after.connect(_on_item_pick_up_after)
	items.swap_before.connect(_on_item_swap_before)

func _on_item_pick_up_after(item_value_: ItemValue) -> void:
	Core.audio.play_sfx(&"item_pick_up")

func _on_item_swap_before(item_value_: ItemValue, level_item_value: LevelItemValue) -> void:
	if item_value_.alias == level_item_value.item.alias:
		var coords: Vector2i = (global_position / Core.TILE_SIZE).floor()
		var level_item_value_: LevelItemValue = Core.level.power_grid.get_component(coords)
		if level_item_value_ != null:
			level_item_value_.node.orientate()
			Core.level.power_grid.update_power_levels()
			
		items.signal_can_swap = false
	
func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
	
	if actions.is_just_pressed(&"player_orientate_component"):
		var coords: Vector2i = (global_position / Core.TILE_SIZE).floor()
		var level_item_value_: LevelItemValue = Core.level.power_grid.get_component(coords)
		if level_item_value_ != null:
			level_item_value_.node.orientate()
			Core.level.power_grid.update_power_levels()
	elif interact.is_interacting:
		Core.level.win()
		var coords: Vector2i = (global_position / Core.TILE_SIZE).floor()
		var level_item_value_: LevelItemValue = Core.level.power_grid.get_component(coords)
		if level_item_value_ != null and level_item_value_.item.alias == &"power_button":
			level_item_value_.node.press_button()
			if Core.level.power_grid.can_launch():
				Core.level.win()
			else:
				Core.level.lose()
		
	_update_sprite_state()

func _update_sprite_state() -> void:
	var suffixes_: Array[StringName] = []
	
	if Core.game.is_win:
		play(PlayValue.new(&"win", Core.UnitDirection.NONE, suffixes_))
		return
	
	if Core.game.is_lose:
		play(PlayValue.new(&"lose", Core.UnitDirection.NONE, suffixes_))
		return

	if move == null:
		play(PlayValue.new(&"idle", Core.UnitDirection.NONE, suffixes_))
		return
		
	if is_moving():
		if unit_speed == Core.UnitSpeed.SLOW:
			play(PlayValue.new(&"move_slow", unit_direction, suffixes_))
		elif unit_speed == Core.UnitSpeed.FAST:
			play(PlayValue.new(&"move_fast", unit_direction, suffixes_))
		else:
			play(PlayValue.new(&"move", unit_direction, suffixes_))
			
		#move.lock_direction()
	else:
		play(PlayValue.new(&"idle", Core.UnitDirection.NONE, suffixes_))

func play(play_value_: PlayValue) -> void:
	%Animations.play(play_value_)
