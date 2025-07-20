extends AreaLevel
class_name PlatformerLevel


func _init(alias_: StringName) -> void:
	super._init(alias_, Core.LevelType.PLATFORMER)
#var _update_map_cooldown = 0
#const UPDATE_MAP_COOLDOWN_DELTA = 1.0
	
#func _process(delta: float) -> void:
	#if not Core.game.is_enabled:
		#return
