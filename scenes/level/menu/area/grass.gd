extends PlatformerArea

var _launcher_index: int = 0
var _launch_delta: float = 3.0
var _current_launch_delta: float = 2.0

@onready var _launchers: Array[ItemComponentUnit] = [
	%Launcher1,
	%Launcher2,
]

var _last_color: Color = Color(1.0, 1.0, 1.0)
var _colors: Array[Color] = [
	Color(1.0, 1.0, 0.0),
	Color(0.0, 0.0, 1.0),
	Color(1.0, 0.0, 0.0),
	Color(1.0, 1.0, 1.0),
	Color(0.0, 1.0, 0.0),
	Color(0.0, 1.0, 1.0),
	Color(1.0, 0.0, 1.0),
]

func _init() -> void:
	super._init(&"grass")


func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
		
	_current_launch_delta += delta_
	if _current_launch_delta >= _launch_delta:
		_launchers[_launcher_index].color = _get_random_color()
		_launchers[_launcher_index].launch()
		
		_launcher_index += 1
		
		if _launcher_index == _launchers.size():
			_launcher_index = 0
			
		_current_launch_delta = 0.0
		
func _get_random_color() -> Color:
	var color_: Color = _colors.pick_random()
	
	if color_ == _last_color:
		return _get_random_color()
	
	_last_color = color_
	return color_
