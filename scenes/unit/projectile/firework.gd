extends BaseCharacterBody2D

@export var target_position: Vector2 = Vector2.ZERO

var _has_exploded: bool = false
var _current_direction: float = 0.0

var speed: float = 1200
var turn_speed: float = 360.0

func _ready() -> void:
	super._ready()
	
	if %Firework.process_material:
		%Firework.process_material = %Firework.process_material.duplicate()
	
	%Firework.finished.connect(_on_firework_finished)

func _on_firework_finished() -> void:
	Core.nodes.free_node(self)
	
func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		Core.audio.play_sfx(&"whistle")
		_has_exploded = false
		position = Core.DEAD_ZONE
		%Ordinance.set_cell(Vector2i(0, 0), %Ordinance.tile_set.get_source_id(0), Vector2i(0, 4))
		_current_direction = 0.0
		rotation = _current_direction
		%Fire.restart()
		%Fire.visible = true
		%Firework.process_material.color = Color(0.0, 1.0, 0.0)
	
func _process(delta_: float) -> void:
	super._process(delta_)
		
	if not is_running():
		return
	
	if _has_exploded:
		return
	
	if position.y < target_position.y + 100:
		Core.audio.play_sfx(&"firework")
		_has_exploded = true
		%Fire.visible = false
		%Ordinance.set_cell(Vector2i(0, 0))
		%Firework.restart()

func _physics_process(delta_: float) -> void:
	if not is_running():
		return
		
	if _has_exploded:
		return
		
	var current_turn_speed_ = turn_speed * delta_
	
	var target_direction_ = rad_to_deg(position.angle_to_point(target_position)) + 90
	
	target_direction_ = _clean_direction(target_direction_)
	
	var angle_diff_ = target_direction_ - _current_direction
	angle_diff_ = _clean_direction(angle_diff_ + 180.0) - 180.0
	
	if abs(angle_diff_) > current_turn_speed_:
		angle_diff_ = sign(angle_diff_) * current_turn_speed_
		
	_current_direction = _clean_direction(_current_direction + angle_diff_)
		
	velocity = Vector2(0, -speed).rotated(deg_to_rad(_current_direction))
	rotation = deg_to_rad(_current_direction)

	move_and_slide()
	
func _clean_direction(direction_: float) -> float:
	if direction_ < 0.0:
		direction_ = 360 + direction_
	
	if direction_ >= 360.0:
		direction_ -= 360.0
		
	return direction_
	
func set_color(color_: Color) -> void:
	%Firework.process_material.color = color_
