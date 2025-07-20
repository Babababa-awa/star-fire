extends BaseNode2D

const COOLDOWN_DELTA: float = 0.25
var cooldown: CooldownTimer

var available_space: Vector2
var _player_items_slots: int = 0

func _init() -> void:
	super._init()
	
	cooldown = CooldownTimer.new(COOLDOWN_DELTA)
	# Items need to update more often
	cooldown.add_step(&"items", COOLDOWN_DELTA / 2)
	
func _ready() -> void:
	super._ready()
	
	get_viewport().connect(&"size_changed", _on_screen_resized)
	_update_available_space()
	_reposition()
	
func _process(delta_: float) -> void:
	super._process(delta_)

	if not is_running():
		return
		
	cooldown.process(delta_)
			
	if cooldown.start():
		pass # No update until second step
	elif cooldown.is_on_step(&"items"):
		%PlayerItems.refresh()
		_reposition()
	elif cooldown.is_complete:
		cooldown.stop()
		%PlayerItems.refresh()
		_reposition()
		
func _on_screen_resized():
	_update_available_space()
	_reposition(true)
	
func _update_available_space() -> void:
	available_space = Vector2(get_viewport().get_visible_rect().size) / scale

func _reposition(force: bool = false) -> void:
	var slots_: int = %PlayerItems.get_slots()
	
	if force or slots_ != _player_items_slots:
		_player_items_slots = slots_
		
		var player_items_size: Vector2 = %PlayerItems.get_scale_rect().size
		var offset: Vector2 = Vector2((available_space.x - player_items_size.x) / 2, available_space.y - 16.0)
		%PlayerItems.position = offset
