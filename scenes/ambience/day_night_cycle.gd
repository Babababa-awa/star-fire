extends CanvasModulate

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const GAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day: int, hour: int, minute: int)

@export var pause_time: bool = false
@export var gradient_texture: GradientTexture1D
@export var time_ratio = 1.0
@export var initial_hour = 12:
	set(value):
		initial_hour = value
		past_day = -1
		past_hour = -1
		past_minute = -1
		time = GAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * initial_hour
		if pause_time:
			_update_color()
			_recalculate_time()

var time: float = 0.0

var past_day: int = -1
var past_hour: int = -1
var past_minute: int = -1

func _ready() -> void:
	time = GAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * initial_hour
	
	if pause_time:
		_update_color()
		_recalculate_time()

func _process(delta: float) -> void:
	if not Core.game.is_enabled:
		return
		
	if pause_time:
		return
		
	time += delta * GAME_TO_REAL_MINUTE_DURATION * time_ratio
	_update_color()
	_recalculate_time()

func _update_color() -> void:
	var value = (sin(time - PI / 2.0) + 1.0) / 2.0
	set_color(gradient_texture.gradient.sample(value))
	
func _recalculate_time() -> void:
	var total_minutes = int(time / GAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)

	var current_day_minutes = total_minutes % MINUTES_PER_DAY

	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_day = day
		past_hour = hour
		past_minute = minute
		time_tick.emit(day, hour, minute)
