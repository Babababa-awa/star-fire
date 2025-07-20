extends UnitActor
class_name LoseActor

var is_lose: bool = false
var is_in_lose_area: bool = false

var lose_cooldown_delta: float = 0.0
var _lose_cooldown: CooldownTimer = null

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"lose", enabled)

func ready() -> void:
	var lose_area = unit.get_node_or_null("%Area2DLose")
		
	if lose_area == null:
		_lose_cooldown = null
	else:
		_lose_cooldown = CooldownTimer.new(lose_cooldown_delta)

		lose_area.connect(&"body_entered", _on_lose_body_entered)
		lose_area.connect(&"body_exited", _on_lose_body_exited)
	
func _on_lose_body_entered(_body: Node2D) -> void:
	is_in_lose_area = true
	lose()

func _on_lose_body_exited(_body: Node2D) -> void:
	is_in_lose_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_lose = false
		is_in_lose_area = false
		
		if _lose_cooldown != null:
			_lose_cooldown.reset()

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
	
	if not can_unit_process():
		return
		
	if _lose_cooldown == null:
		return
		
	if state.has(Core.ActorState.STOP):
		_update_state(Core.ActorState.NONE)
		return
	
	if state.has(Core.ActorState.NONE):
		if Core.game.is_lose or Core.game.is_win or not is_lose:
			return

	_lose_cooldown.process(delta)

	if _lose_cooldown.start():
		_update_state(Core.ActorState.START)
	elif _lose_cooldown.is_complete:
		Core.game.is_lose = true
		_lose_cooldown.stop()
		_update_state(Core.ActorState.STOP)

func lose(_reason: StringName = &"") -> void:
	is_lose = true
