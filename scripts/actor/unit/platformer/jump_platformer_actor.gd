extends UnitActor
class_name JumpPlatformerActor

var jump_speed: float = 450

var air_time_delay: float = 0.1 # Delay from start of fall to when jump is no longer available

# NONE: Cannot jump while crouched
# CROUCH: Can jump while crouched
# JUMP: Can jump, but will be uncrouched
var jump_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

var is_jumping: bool = false
var is_jumping_start: bool = false
var is_crouch_jumping: bool = false
var is_climb_jumping: bool = false

var action_jump: StringName = &"player_jump"

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"jump", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_jumping = false
		is_jumping_start = false
		is_crouch_jumping = false
		is_climb_jumping = false

func interupt() -> void:
	is_jumping = false
	is_jumping_start = false
	is_crouch_jumping = false
	is_climb_jumping = false

func physics_process(delta: float) -> void:
	super.physics_process(delta)

	is_jumping_start = false
	if is_crouch_jumping and not is_unit_crouching():
		is_crouch_jumping = false

	if not can_physics_process():
		return
	
	if not can_unit_process():
		return

	var fall_actor = unit.get_actor_or_null(&"fall")
	if fall_actor == null:
		return

	if state.has(Core.ActorState.START) and not is_jumping:
		_update_state(Core.ActorState.STOP)
		return

	if state.has(Core.ActorState.STOP):
		_update_state(Core.ActorState.NONE)
		return

	if _can_jump():
		is_jumping = true
		is_jumping_start = true
		if jump_crouch_behavior == Core.PlatformerBehavior.CROUCH and is_unit_crouching():
			is_crouch_jumping = true
		_update_state(Core.ActorState.START)
		return

	if is_jumping and not fall_actor.is_in_air:
		is_jumping = false
		is_crouch_jumping = false
		is_climb_jumping = false
		_update_state(Core.ActorState.STOP)
		return

func _can_jump() -> bool:
	if is_jumping:
		return false
		
	if not can_unit_input():
		return false

	if not unit.actions.is_just_pressed(action_jump, true):
		return false

	var climb_actor = unit.get_actor_or_null(&"climb")
	if climb_actor != null and climb_actor.is_climbing:
		if climb_actor.climb_jump_behavior != Core.PlatformerBehavior.JUMP:
			return false

		climb_actor.interupt()
		is_climb_jumping = true
		return true

	var fall_actor = unit.get_actor_or_null(&"fall")
	if fall_actor != null and fall_actor.is_in_air:
		if fall_actor.air_time >= air_time_delay:
			return false

	var crouch_actor = unit.get_actor_or_null(&"crouch")
	if crouch_actor != null and crouch_actor.is_crouching:
		if jump_crouch_behavior == Core.PlatformerBehavior.NONE:
			return false

	return true

func get_actions() -> Array[StringName]:
	return [action_jump]

func move_process(_delta: float) -> void:
	if is_jumping_start:
		var move_actor = unit.get_actor_or_null(&"move")
		if move_actor != null:
			move_actor.apply_velocity(Vector2(0.0, -jump_speed))
