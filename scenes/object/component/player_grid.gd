extends Node2D

func _ready() -> void:
	if Core.player == null:
		return
	
func _process(delta_: float) -> void:
	update_grid_position(delta_)
	
func update_grid_position(delta_: float) -> void:
	if not Core.game.is_enabled:
		return
		
	if Core.player == null:
		return
	
	var player_position_: Vector2 = Core.player.position + Core.player.items.drop_offset
	var sprite_position_: Vector2 = ((player_position_) / Core.TILE_SIZE).floor() * Core.TILE_SIZE + Vector2(128.0, 128.0)
	var shader_position: Vector2 = (player_position_ - sprite_position_ + Vector2(640.0, 640.0)) / Vector2(1280.0, 1280.0)

	var material: ShaderMaterial = %Sprite2DGrid.material
	
	material.set_shader_parameter("position_x", shader_position.x)
	material.set_shader_parameter("position_y", shader_position.y)
	
	position = sprite_position_
		
