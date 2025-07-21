extends PlatformerLevel

func _init() -> void:
	super._init(&"menu")

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		Core.game.day_night_cycle.pause_time = true
		Core.game.day_night_cycle.initial_hour = 20
		Core.audio.play_ambience(&"night")
