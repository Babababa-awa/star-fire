extends BaseNode2D

var _show: bool = false
var _modulate_delta = 1.0

func _ready() -> void:
	super._ready()
	
	Core.game.day_night_cycle.time_tick.connect(_day_night_cycle_time_tick)
	if Core.game.day_night_cycle.past_hour >= 17 or Core.game.day_night_cycle.past_hour <= 5:
		_show = true

func _day_night_cycle_time_tick(day: int, hour: int, minute: int) -> void:
	if hour >= 17 or hour <= 5:
		if not _show:
			_show = true
	elif _show:
		_show = false
		

func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
	
	if _show and _modulate_delta != 1.0:
		_modulate_delta += delta_
		_modulate_delta = min(1.0, _modulate_delta)
		%Fireflies.modulate = Color(1.0, 1.0, 1.0, _modulate_delta)
	elif not _show and _modulate_delta != 0.0:
		_modulate_delta -= delta_
		_modulate_delta = max(0.0, _modulate_delta)
		%Fireflies.modulate = Color(1.0, 1.0, 1.0, _modulate_delta)
