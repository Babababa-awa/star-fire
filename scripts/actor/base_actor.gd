class_name BaseActor

var alias: StringName
var is_enabled: bool
var is_enabled_default: bool
var state: ActorState

var is_started: bool = false
var has_changed: bool = false

var current_process_skip: int = -1
var process_skip: int = 0 # For actors that don't need to be run every time
var process_skip_offset: int = 0

var current_physics_process_skip: int = -1
var physics_process_skip: int = 0 # For actors that don't need to be run every time
var physics_process_skip_offset: int = 0

signal state_changed(actor_: BaseActor, state_: ActorState, previous_state_: ActorState)

func _init(alias_: StringName, enabled_: bool = true) -> void:
	alias = alias_
	is_enabled = enabled_
	is_enabled_default = enabled_
	state = ActorState.new(Core.ActorState.NONE)
	
func ready() -> void:
	pass

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_enabled = is_enabled_default
		is_started = false
		current_process_skip = -1
		assert(process_skip >= process_skip_offset, "Invalid process skip offset for current proccess skip.")
		state = ActorState.new(Core.ActorState.NONE)

func start() -> void:
	reset(Core.ResetType.START)
	is_started = true

func restart() -> void:
	reset(Core.ResetType.RESTART)
	is_started = true
	
func stop() -> void:
	is_started = false

func process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_process_skip()
	
	if can_process():
		has_changed = false

func physics_process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_physics_process_skip()
	
	if can_physics_process():
		has_changed = false
		
func _update_process_skip() -> void:
	current_process_skip += 1
	
	if current_process_skip >= process_skip:
		current_process_skip = 0
		
func _update_physics_process_skip() -> void:
	current_physics_process_skip += 1
	
	if current_physics_process_skip >= physics_process_skip:
		current_physics_process_skip = 0
			
func _update_state(
	actor_state_: Core.ActorState, 
	alias_: StringName = &"", 
	repeat_: bool = false
) -> void:
	if (state.actor_state == actor_state_ and
		state.alias == alias_ and
		not repeat_
	):
		return
	
	var prev_state = state
	state = ActorState.new(actor_state_, alias_)
	
	if state.is_equal(prev_state):
		state.repeat()
	
	has_changed = true
	
	state_changed.emit(self, state, prev_state)
	
func can_process() -> bool:
	if current_process_skip != process_skip_offset:
		return false
		
	if not is_enabled:
		return false

	return true
	
func can_physics_process() -> bool:
	if current_physics_process_skip != physics_process_skip_offset:
		return false
		
	if not is_enabled:
		return false

	return true
