extends UnitActor
class_name ClimbPlatformerActor

var slow_climbing_speed: float = 60.0
var normal_climbing_speed: float = 120.0
var fast_climbing_speed: float = 120.0

# NONE: Cannot jump off ladder
# JUMP: Jumps off ladder (handled by platformer jump actor)
var climb_jump_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Cannot crouch on ladder
# CROUCH: Crouch on ladder, but can't move
# MOVE: Crouch and move on ladder
# FALL: Let go of ladder
var climb_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Cannot move off ladder
# FALL: Can move off ladder (handled by platformer move actor)
var climb_off_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Climb up, down, and grab in air
# CLIMB: Climb up action also grabs in air
var climb_on_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.CLIMB

var is_climbing: bool = false
var is_climbing_start: bool = false

var is_in_climb_area: bool = false
var is_in_climb_up_area: bool = false
var is_in_climb_down_area: bool = false
var is_in_climb_left_area: bool = false
var is_in_climb_right_area: bool = false

var action_climb: StringName = &"player_climb"
var action_climb_up: StringName = &"player_climb_up"
var action_climb_down: StringName = &"player_climb_down"
var action_climb_left: StringName = &"player_climb_left"
var action_climb_right: StringName = &"player_climb_right"
var action_climb_slow: StringName = &"player_climb_slow"
var action_climb_fast: StringName = &"player_climb_fast"

var climb_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL

# Used to require release of up button before it can be used again to 
# prevent jumpyness at top of ladders
var _cancel_action_climb_up: bool = false

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"climb", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)
	unit_modes.push_back(Core.UnitMode.CLIMBING)
	
func ready() -> void:
	super.ready()
	
	unit.connect(&"unit_mode_changed", _on_unit_mode_changed)
	
	var climb_area = unit.get_node_or_null("%Area2DClimb")
	if climb_area != null:
		climb_area.connect(&"body_entered", _on_climb_body_entered)
		climb_area.connect(&"body_exited", _on_climb_body_exited)
	
	var climb_up_area = unit.get_node_or_null("%Area2DClimbUp")
	if climb_up_area != null:
		climb_up_area.connect(&"body_entered", _on_climb_up_body_entered)
		climb_up_area.connect(&"body_exited", _on_climb_up_body_exited)
		
	var climb_down_area = unit.get_node_or_null("%Area2DClimbDown")
	if climb_down_area != null:
		climb_down_area.connect(&"body_entered", _on_climb_down_body_entered)
		climb_down_area.connect(&"body_exited", _on_climb_down_body_exited)
		
	var climb_left_area = unit.get_node_or_null("%Area2DClimbLeft")
	if climb_left_area != null:
		climb_left_area.connect(&"body_entered", _on_climb_left_body_entered)
		climb_left_area.connect(&"body_exited", _on_climb_left_body_exited)
		
	var climb_right_area = unit.get_node_or_null("%Area2DClimbRight")
	if climb_right_area != null:
		climb_right_area.connect(&"body_entered", _on_climb_right_body_entered)
		climb_right_area.connect(&"body_exited", _on_climb_right_body_exited)

func _on_unit_mode_changed(unit_mode_: Core.UnitMode, _previous_unit_mode: Core.UnitMode) -> void:
	if unit_mode_ == Core.UnitMode.CLIMBING and unit_modes.has(Core.UnitMode.CLIMBING):
		is_climbing = true
		is_climbing_start = true
		_update_state(Core.ActorState.START)

func _on_climb_body_entered(_body: Node2D) -> void:
	is_in_climb_area = true

func _on_climb_body_exited(_body: Node2D) -> void:
	is_in_climb_area = false
	
func _on_climb_up_body_entered(_body: Node2D) -> void:
	is_in_climb_up_area = true

func _on_climb_up_body_exited(_body: Node2D) -> void:
	is_in_climb_up_area = false
	
func _on_climb_down_body_entered(_body: Node2D) -> void:
	is_in_climb_down_area = true

func _on_climb_down_body_exited(_body: Node2D) -> void:
	is_in_climb_down_area = false
	
func _on_climb_left_body_entered(_body: Node2D) -> void:
	is_in_climb_left_area = true

func _on_climb_left_body_exited(_body: Node2D) -> void:
	is_in_climb_left_area = false
	
func _on_climb_right_body_entered(_body: Node2D) -> void:
	is_in_climb_right_area = true

func _on_climb_right_body_exited(_body: Node2D) -> void:
	is_in_climb_right_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_climbing = false
		is_climbing_start = false
		
		is_in_climb_area = false
		is_in_climb_up_area = false
		is_in_climb_down_area = false
		is_in_climb_left_area = false
		is_in_climb_right_area = false

		climb_speed = Core.UnitSpeed.NORMAL
		
		_cancel_action_climb_up = false

func interupt() -> void:
	is_climbing = false
	is_climbing_start = false
	_cancel_action_climb_up = false

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)
	
	is_climbing_start = false
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
	
	if unit.unit_mode == Core.UnitMode.CLIMBING:
		return
	
	var can_input: bool = can_unit_input()
	
	if can_input:
		if unit.actions.is_pressed(action_climb_slow, true):
			climb_speed = Core.UnitSpeed.SLOW
		elif unit.actions.is_pressed(action_climb_fast, true):
			climb_speed = Core.UnitSpeed.FAST
		else:
			climb_speed = Core.UnitSpeed.NORMAL
	
	if state.has(Core.ActorState.START) and not is_climbing:
		_update_state(Core.ActorState.STOP)
		return
		
	if state.has(Core.ActorState.STOP):
		_update_state(Core.ActorState.NONE)
		return
		
	if is_climbing:
		if not is_in_climb_area and not is_in_climb_up_area and not is_in_climb_down_area:
			is_climbing = false
			if can_input and unit.actions.is_pressed(action_climb_up, true):
				_cancel_action_climb_up = true
			_update_state(Core.ActorState.STOP)
			return
		
		if is_unit_crouching():
			if climb_crouch_behavior == Core.PlatformerBehavior.FALL:
				is_climbing = false
				_update_state(Core.ActorState.STOP)
				return
		
		# At bttom of ladder that touches floor	
		if not is_in_climb_down_area and unit.is_on_floor():
			is_climbing = false
			_cancel_action_climb_up = false
			_update_state(Core.ActorState.STOP)
			
		return
	
	if not can_input:
		return
	
	if unit.actions.is_just_pressed(action_climb, true):
		_action_climb()
	elif unit.actions.is_pressed(action_climb_up, true):
		_action_climb_up()
	elif unit.actions.is_just_released(action_climb_up, true):
		_cancel_action_climb_up = false
	elif unit.actions.is_pressed(action_climb_down, true):
		_action_climb_down()

func move_process(_delta: float) -> void:
	if not is_climbing:
		return
	
	# Can't move while crouching
	if is_unit_crouching() and climb_crouch_behavior == Core.PlatformerBehavior.CROUCH:
		return
		
	var move_actor = unit.get_actor_or_null(&"move")
	if move_actor == null:
		return
	
	var direction: Vector2 = Vector2.ZERO
	
	if can_unit_input():
		direction = Vector2(
			sign(unit.actions.get_axis(action_climb_left, action_climb_right, true)),
			sign(unit.actions.get_axis(action_climb_up, action_climb_down, true)),
		)
	
	if move_actor.normalize_move_speed:
		direction = direction.normalized()
	
	# Prevent moving left/right off ladder
	if unit.unit_mode == Core.UnitMode.CLIMBING or climb_off_behavior == Core.PlatformerBehavior.NONE:
		if is_in_climb_down_area:
			if not is_in_climb_left_area and direction.x < 0.0:
				direction.x = 0.0
			elif not is_in_climb_right_area and direction.x > 0.0:
				direction.x = 0.0
	
	var velocity_: Vector2 = Vector2.ZERO
	
	if climb_speed == Core.UnitSpeed.SLOW:
		velocity_.x = direction.x * slow_climbing_speed
		velocity_.y = direction.y * slow_climbing_speed
	elif climb_speed == Core.UnitSpeed.FAST:
		velocity_.x = direction.x * fast_climbing_speed
		velocity_.y = direction.y * fast_climbing_speed
	else:
		velocity_.x = direction.x * normal_climbing_speed
		velocity_.y = direction.y * normal_climbing_speed

	move_actor.apply_velocity(velocity_)

func _action_climb() -> void:
	climb()
	
func _action_climb_up() -> void:
	if _cancel_action_climb_up and is_in_climb_down_area:
		return
	
	if is_in_climb_up_area and unit.is_on_floor():
		_cancel_action_climb_up = false

	climb_up()

func _action_climb_down() -> void:
	climb_down()
	
func can_climb() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_area:
		return false
		
	return true
	
func can_climb_up() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_up_area:
		return false
	
	if is_in_climb_down_area:
		if climb_on_behavior == Core.PlatformerBehavior.NONE:
			return false
		else:
			var jump_actor = unit.get_actor_or_null(&"jump")
			if jump_actor != null and jump_actor.is_climb_jumping:
				return false
	
	return true
		
func can_climb_down() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_down_area or is_in_climb_up_area:
		return false
		
	return true
	
func climb() -> void:
	if not can_climb():
		return
	
	if is_unit_jumping():
		var jump_actor = unit.get_actor_or_null(&"jump")
		
		if jump_actor != null:
			jump_actor.interupt()
		
	is_climbing = true
	is_climbing_start = true
	_update_state(Core.ActorState.START)

func climb_up() -> void:
	if not can_climb_up():
		return
		
	is_climbing = true
	is_climbing_start = true
	unit.position.y -= 1.0
	_update_state(Core.ActorState.START, &"up")
	
func climb_down() -> void:
	if not can_climb_down():
		return
		
	is_climbing = true
	is_climbing_start = true
	unit.position.y += 1.0
	_update_state(Core.ActorState.START, &"down")
	
func get_actions() -> Array[StringName]:
	return [
		action_climb,
		action_climb_up,
		action_climb_down,
		action_climb_left,
		action_climb_right,
		action_climb_fast,
		action_climb_slow
	]
