extends BaseNode2D

@export var cloud_travel_distance: float = 20480.0
@export var cloud_speed: float = 50.0
@export var cloud_delay: float = 50.0

var _current_delta: float = 0.0

@onready var clouds: Array[Sprite2D] = [
	%Sprite2DCloud1,
	%Sprite2DCloud2,
	%Sprite2DCloud3,
	%Sprite2DCloud4,
	%Sprite2DCloud5,
]

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		_current_delta = 0.0
		clouds.shuffle()

func _process(delta_: float) -> void:
	super._process(delta_)

	if not is_running():
		return
		
	_current_delta += delta_
	
	var is_complete_: int = 0
	
	for index in clouds.size():
		if _current_delta >= index * cloud_delay:
			clouds[index].position.x += cloud_speed * delta_
			if clouds[index].position.x > cloud_travel_distance:
				is_complete_ += 1
				
	if is_complete_ == clouds.size():
		_current_delta = 0.0
		for index in clouds.size():
			clouds[index].position.x = -4096.0
		
		clouds.shuffle()
