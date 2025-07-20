extends BaseGame
class_name Game

var rain: bool = true
var is_lightning: bool = true
var is_outside: bool = true
var day_night_cycle: CanvasModulate = null

func _ready() -> void:
	day_night_cycle = %DayNightCycle
	
	super._ready()
	
	day_night_cycle.time_tick.connect(_day_night_cycle_time_tick)

func _day_night_cycle_time_tick(day: int, hour: int, minute: int) -> void:
	if Core.level == null or Core.level.level_mode == Core.LevelMode.MENU:
		return
		
	if hour == 18:
		Core.audio.play_ambience(&"night", 10.0)
	elif hour == 16:
		Core.audio.stop_ambience(&"", 10.0)
	elif hour == 7:
		Core.audio.play_ambience(&"day", 10.0)
	elif hour == 5:
		Core.audio.stop_ambience(&"", 10.0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func change_level(
	level_alias_: StringName,
	level_mode_: Core.LevelMode = Core.LevelMode.GAME
) -> void:
	super.change_level(level_alias_, level_mode_)
	
	%PlayerGrid.visible = (level_mode_ == Core.LevelMode.GAME)
