extends PowerGridLevel

func _init() -> void:
	super._init(&"level_1")

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		Core.game.day_night_cycle.initial_hour = 18
		Core.audio.play_ambience(&"night")
		Core.game.show_ui(&"phone")
		Core.game._show_mouse()
		Core.player.items.drop_action_enabled = false
