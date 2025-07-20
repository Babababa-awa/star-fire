extends UnitActor
class_name WinActor

var is_win: bool = false
var is_in_win_area: bool = false

var win_cooldown_delta: float = 0.0
var _win_cooldown: CooldownTimer = null

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"win", enabled_)

func ready() -> void:
	var win_area = unit.get_node_or_null("%Area2DWin")
	
	if win_area == null:
		_win_cooldown = null
	else:
		_win_cooldown = CooldownTimer.new(win_cooldown_delta)

		win_area.connect(&"body_entered", _on_win_body_entered)
		win_area.connect(&"body_exited", _on_win_body_exited)
	
func _on_win_body_entered(_body: Node2D) -> void:
	is_in_win_area = true
	win()

func _on_win_body_exited(_body: Node2D) -> void:
	is_in_win_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_win = false
		is_in_win_area = false
		
		if _win_cooldown != null:
			_win_cooldown.reset()

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
		
	if not can_unit_process():
		return
		
	if _win_cooldown == null:
		return
	
	if state.has(Core.ActorState.STOP):
		_update_state(Core.ActorState.NONE)
		return
	
	if state.has(Core.ActorState.NONE):
		if Core.game.is_win or Core.game.is_lose or not is_win:
			return

	_win_cooldown.process(delta)
	
	if _win_cooldown.start():
		_update_state(Core.ActorState.START)
	elif _win_cooldown.is_complete:
		Core.game.is_win = true
		_win_cooldown.stop()
		_update_state(Core.ActorState.STOP)

func win(_reason: StringName = &"") -> void:
	is_win = true
