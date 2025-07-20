extends ItemComponentUnit

@export var target_position: Vector2 = Vector2.ZERO
@export var color: Color = Color(1.0, 0.0, 0.0)
@export_enum("Normal") var firework_style: String = "Normal"

var _launch_delay: float = 0.0
var is_launching: bool = false
var _current_delta: float = 0.0

var power_level: int = 0

func _init() -> void:
	super._init(&"launcher", Core.ItemType.COMPONENT)

	bottom_edge = true
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		top_edge = false
		bottom_edge = true
		left_edge = false
		right_edge = false
		
		power_level = 0
		
		is_launching = false
		_current_delta = 0.0

func set_item_meta(meta_: Dictionary) -> void:
	super.set_item_meta(meta_)
	
	if item_meta.has("target_position"):
		target_position = Vector2(item_meta.target_position[0], item_meta.target_position[1])
	
	if item_meta.has("color"):
		color = Color(item_meta.color[0], item_meta.color[1], item_meta.color[2])
		
func _process(delta_: float) -> void:
	super._process(delta_)

	if not is_running():
		return

	if not is_launching:
		return
		
	if _launch_delay > 0.0:
		_launch_delay -= delta_
		return
	
	if _current_delta == 0.0:
		Core.audio.play_sfx(&"launcher")
		%Smoke.emitting = true
	
	_current_delta += delta_
	
	if _current_delta > 1.0:
		is_launching = false
		var node = await Core.nodes.get_node("res://scenes/unit/projectile/firework.tscn")
		node.position = global_position + Vector2(128, 108)
		node.target_position = target_position
		node.set_color(color)
		
func launch(delay: float = 0.0) -> void:
	_launch_delay = delay
	_current_delta = 0.0
	is_launching = true
		
func set_edges(top_edge_: bool, bottom_edge_: bool, left_edge_: bool, right_edge_: bool) -> void:
	assert(_count_true_edges(1, top_edge_, bottom_edge_, left_edge_, right_edge_), "Invalid edges.")
	
	super.set_edges(top_edge_, bottom_edge_, left_edge_, right_edge_)
	
func set_firework_style(firework_style_: String) -> void:
	firework_style = firework_style_
	#TODO: Other styles

func update_edges() -> void:
	super.update_edges()
	
	var coords: Vector2i = Vector2i(0, 1)
	
	if top_edge:
		coords.x = 2
	elif right_edge:
		coords.x = 3
	elif left_edge:
		coords.x = 1
	
	%Component.set_cell(Vector2i(0, 0), %Component.tile_set.get_source_id(0), coords)

	update_power_indicator()
	update_firework_launcher()

func update_firework_launcher() -> void:
	var coords: Vector2i = Vector2i(0, 0)
	
	if top_edge:
		coords.y = 2
	elif right_edge:
		coords.y = 3
	elif left_edge:
		coords.y = 1
	
	%Firework.set_cell(Vector2i(0, 0), %Firework.tile_set.get_source_id(0), coords)
	
func update_power_indicator() -> void:
	var coords: Vector2i = Vector2i(0, 4)
	
	if top_edge:
		coords.x = 3
	elif left_edge:
		coords.y = 5
	elif right_edge:
		coords.x = 3
		coords.y = 5
	
	%PowerBar.set_cell(Vector2i(0, 0), %PowerBar.tile_set.get_source_id(0), coords)
	
	if power_level == 0:
		%PowerLights.set_cell(Vector2i(0, 0))
	elif power_level == 1:
		coords.x += 1
		%PowerLights.set_cell(Vector2i(0, 0), %PowerLights.tile_set.get_source_id(0), coords)
	else:
		coords.x += 2
		%PowerLights.set_cell(Vector2i(0, 0), %PowerLights.tile_set.get_source_id(0), coords)
		
func connect_edge(edge_: Core.Edge) -> void:
	super.connect_edge(edge_)
	
	if edge_ == Core.Edge.NONE:
		return
	
	if edge_ == Core.Edge.TOP:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(8, 0))
		
	if edge_ == Core.Edge.BOTTOM:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(6, 0	))
		
	if edge_ == Core.Edge.LEFT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(7, 0))
		
	if edge_ == Core.Edge.RIGHT:
		%Connection.set_cell(Vector2i(0, 0), %Connection.tile_set.get_source_id(0), Vector2i(9, 0))
	
func disconnect_edge(edge_: Core.Edge) -> void:
	super.disconnect_edge(edge_)
	
	if not is_edge_connected():
		%Connection.set_cell(Vector2i(0, 0))
