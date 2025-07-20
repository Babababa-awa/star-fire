extends PlatformerLevel

func _init() -> void:
	super._init(&"menu")

func start() -> void:
	await super.start()
	
	Core.game.day_night_cycle.pause_time = true
	Core.game.day_night_cycle.initial_hour = 20
	Core.audio.play_ambience(&"night")
