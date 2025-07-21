extends ItemComponentUnit

@export var power_level: int = 1

var _is_button_pressed: bool = false
var _button_timer: StepTimer

func _init() -> void:
	super._init(&"power_button", Core.ItemType.COMPONENT)

	top_edge = true
	
	_button_timer = StepTimer.new(4)
		
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):		
		top_edge = true
		bottom_edge = false
		left_edge = false
		right_edge = false
		
		_is_button_pressed = false
		_button_timer.reset()
		
		_update_from_meta()

func set_item_meta(meta_: Dictionary) -> void:
	super.set_item_meta(meta_)
	
	_update_from_meta()

func _update_from_meta() -> void:
	if item_meta.has("power_level"):
		power_level = max(0, min(8, int(item_meta.power_level)))
		
func press_button() -> void:
	Core.audio.play_sfx(&"power_button")
	_is_button_pressed = true
	
func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
		
	_button_timer.process(delta_)
	
	if _is_button_pressed:
		_is_button_pressed = false
		_button_timer.start()
	elif _button_timer.requires_update:
		_update_button(_button_timer.current_step)
	elif _button_timer.is_complete:
		_button_timer.stop()

		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(top_edge_ and _count_true_edges(1, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)
	
func set_power_level(power_level_: int) -> void:
	assert(power_level_ >= 1 and power_level_ <= 8, "Invalid power level.")
	
	power_level = power_level_
	
	update_power_level()

func update_edges() -> void:
	super.update_edges()
	
	%Component.set_cell(Vector2i(0, 0), %Component.tile_set.get_source_id(0), Vector2i(2, 1))
	
	update_power_level()

func _update_button(step: int = 0) -> void:
	if step == 1 or step == 3:
		%Button.set_cell(Vector2i(0, 0), %Button.tile_set.get_source_id(0), Vector2i(5, 2))
	elif step == 2:
		%Button.set_cell(Vector2i(0, 0), %Button.tile_set.get_source_id(0), Vector2i(6, 2))
	else:
		%Button.set_cell(Vector2i(0, 0), %Button.tile_set.get_source_id(0), Vector2i(4, 2))

func update_power_level() -> void:
	%PowerLevelLights.set_cell(Vector2i(0, 0), %PowerLevelLights.tile_set.get_source_id(0), Vector2i(power_level, 3))
	
func connect_edge(edge_: Core.Edge) -> void:
	super.connect_edge(edge_)
	
	if edge_ == Core.Edge.NONE:
		return

	if edge_ == Core.Edge.TOP:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(8, 0))
	elif edge_ == Core.Edge.BOTTOM:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(6, 0))
	elif edge_ == Core.Edge.LEFT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(7, 0))	
	elif edge_ == Core.Edge.RIGHT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(9, 0))
	
func disconnect_edge(edge_: Core.Edge) -> void:
	super.disconnect_edge(edge_)
	
	if not is_edge_connected():
		%Connection.set_cell(Vector2i(0, 0))
