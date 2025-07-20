class_name ActorState

var actor_state: Core.ActorState
var alias: StringName
var _repeat: int = 0

func _init(actor_state_: Core.ActorState, alias_: StringName = &"") -> void:
	actor_state = actor_state_
	alias = alias_
	
func has(actor_state_: Core.ActorState, alias_: StringName = &"") -> bool:
	if actor_state_ == actor_state and alias_ == alias:
		return true
		
	return false

func is_equal(state_: ActorState) -> bool:
	if state_.actor_state == actor_state and state_.alias == alias:
		return true
	
	return false

func repeat() -> void:
	_repeat += 1
	
func get_repeat() -> int:
	return _repeat
