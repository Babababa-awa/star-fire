extends UnitActor
class_name LifeActor

var is_killed: bool = false
var _reason: StringName = &""

var lose_on_kill: bool = false
var health_on_revive: float = 0.0

var kill_cooldown_delta: float = 0.0
var _kill_cooldown: CooldownTimer

var revive_cooldown_delta: float = 0.0
var _revive_cooldown: CooldownTimer

var kill_action_enabled: bool = true
var kill_action_enabled_default: bool = true
var signal_can_kill: bool = false
var signal_kill_handled: bool = false

var revive_action_enabled: bool = true
var revive_action_enabled_default: bool = true
var signal_can_revive: bool = false
var signal_revive_handled: bool = false

signal kill_error(reason_: StringName, error_: Core.Error) 
signal kill_before(reason_: StringName)
signal kill_after(reason_: StringName)

signal revive_error(reason_: StringName, error_: Core.Error) 
signal revive_before(reason_: StringName)
signal revive_after(reason_: StringName)

var action_kill = &"player_life_kill"
var action_revive = &"player_life_revive"

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"kill", enabled)

func ready() -> void:
	super.ready()
	
	_kill_cooldown = CooldownTimer.new(kill_cooldown_delta)
	_kill_cooldown.add_step(&"hide", 0.0)
	
	_revive_cooldown = CooldownTimer.new(revive_cooldown_delta)
	_revive_cooldown.add_step(&"show", 0.0)
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
		
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_killed = false
		_reason = &""
		
		_kill_cooldown.reset()
		kill_action_enabled = kill_action_enabled_default
	
		_revive_cooldown.reset()
		revive_action_enabled = revive_action_enabled_default

func process(delta_: float) -> void:
	super.process(delta_)

	if not can_process():
		return
		
	if not can_unit_process():
		return

		
	_process_kill(delta_)
	_process_revive(delta_)
		
	if not can_unit_input():
		return
	
	_action_kill(delta_)
	_action_revive(delta_)

func _process_kill(delta_: float) -> void:
	if state.has(Core.ActorState.STOP, &"kill"):
		_update_state(Core.ActorState.NONE, &"kill")
		return
	
	if not is_killed or _kill_cooldown.is_stopped:
		return
	
	_kill_cooldown.process(delta_)

	if _kill_cooldown.is_on_step(&"hide"):
		_update_state(Core.ActorState.UPDATE, &"kill_hide")
	elif _kill_cooldown.is_complete:
		_kill_cooldown.stop()
		_update_state(Core.ActorState.STOP, &"kill")
		if lose_on_kill:
			lose(_reason)
		kill_after.emit(_reason)
	
func _process_revive(delta_: float) -> void:
	if state.has(Core.ActorState.STOP, &"revive"):
		_update_state(Core.ActorState.NONE, &"revive")
		return
		
	if is_killed or _revive_cooldown.is_stopped:
		return
		
	_revive_cooldown.process(delta_)

	if _revive_cooldown.is_on_step(&"show"):
		_update_state(Core.ActorState.UPDATE, &"revive_show")
	elif _revive_cooldown.is_complete:
		_revive_cooldown.stop()
		_update_state(Core.ActorState.STOP, &"revive")
		revive_after.emit(_reason)
	
func _action_kill(_delta: float) -> void:
	if not kill_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_kill):
		return
		
	if not unit.actions.has(action_kill):
		kill_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	kill(&"action")
	
func _action_revive(_delta: float) -> void:
	if not revive_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_revive):
		return
		
	if not unit.actions.has(action_revive):
		revive_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	revive(&"action")
	
func can_kill() -> bool:
	if not state.has(Core.ActorState.NONE):
		return false
		
	return not is_killed
	
func can_revive() -> bool:
	if not state.has(Core.ActorState.NONE):
		return false
		
	return is_killed
	
func kill(reason_: StringName = &"") -> void:
	_reason = reason_
		
	if not can_kill():
		kill_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		
	signal_can_kill = true
	signal_kill_handled = false
	
	kill_before.emit(reason_)
	
	if signal_can_kill == false:
		kill_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return
	
	if signal_kill_handled:
		kill_after.emit(reason_)
	else:
		if not _kill():
			kill_error.emit(reason_, Core.Error.UNHANDLED)
			return

func revive(reason_: StringName = &"") -> void:
	_reason = reason_
		
	if not can_revive():
		revive_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		
	signal_can_revive = true
	signal_revive_handled = false
	
	revive_before.emit(reason_)
	
	if signal_can_revive == false:
		revive_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return
	
	if signal_revive_handled:
		_update_state(Core.ActorState.START, &"revive")
		revive_after.emit(reason_)
	else:
		if not _revive():
			revive_error.emit(reason_, Core.Error.UNHANDLED)
			return

func _kill() -> bool:
	is_killed = true
	
	if not _kill_cooldown.start():
		return false
			
	_update_state(Core.ActorState.START, &"kill")
	
	return true
	
func _revive() -> bool:
	is_killed = false
	
	if health_on_revive != 0.0:
		set_unit_health(health_on_revive)
	
	if not _revive_cooldown.start():
		return false
			
	_update_state(Core.ActorState.START, &"revive")
	
	return true

func get_actions() -> Array[StringName]:
	return [action_kill]
