extends UnitActor
class_name CrouchPlatformerActor

#var slow_crouch_speed: float = 60.0
#var normal_crouch_speed: float = 60.0
#var fast_crouch_speed: float = 200.0

var is_crouch_toggle = false

var is_crouching: bool = false
var is_crouching_start: bool = false

var action_crouch: StringName = &"player_crouch"

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"crouch", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_crouching = false

func physics_process(delta: float) -> void:
	super.physics_process(delta)

	is_crouching_start = false

	if not can_physics_process():
		return
	
	if not can_unit_process():
		return
	
	if state.has(Core.ActorState.START) and not is_crouching:
		_update_state(Core.ActorState.STOP)
		return
		
	if state.has(Core.ActorState.STOP):
		_update_state(Core.ActorState.NONE)
		return
		
	var can_input: bool = can_unit_input()

	if is_crouch_toggle:
		if can_input and unit.actions.is_just_pressed(action_crouch, true):
			is_crouching = not is_crouching
			
			if is_crouching:
				is_crouching_start = true
				_update_state(Core.ActorState.START)
			else:
				_update_state(Core.ActorState.STOP)
			return
	elif can_input and unit.actions.is_pressed(action_crouch, true):
		if not is_crouching:
			_update_state(Core.ActorState.START)
			is_crouching = true
			is_crouching_start = true
			return
	elif is_crouching:
		_update_state(Core.ActorState.STOP)
		is_crouching = false
		return
	
func get_actions() -> Array[StringName]:
	return [action_crouch]
