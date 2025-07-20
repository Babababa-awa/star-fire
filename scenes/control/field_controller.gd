extends BaseNode2D
class_name FieldController

@onready var area_2d_boxes: Array[Area2D] = [
	%Area2DField,
	%Area2DSpeed,
	%Area2DMove,
]

@export var rect: Rect2 = Rect2()

var _field_rect: Rect2

var _fields: Dictionary

const FIELD_OFFSET: float = 0.5
const BOUNDS_THICKNESS: float = 0.5
const BOUNDS_OFFSET: float = 0.5

var is_in_field_area: bool:
	get:
		return not _fields[&"fields"].is_empty()
		
var is_in_field_left_area: bool:
	get:
		return not _fields[&"left"].is_empty()
		
var is_in_field_right_area: bool:
	get:
		return not _fields[&"right"].is_empty()
		
var is_in_field_up_area: bool:
	get:
		return not _fields[&"up"].is_empty()
		
var is_in_field_down_area: bool:
	get:
		return not _fields[&"down"].is_empty()
		
var is_in_field_move_area: bool:
	get:
		return not _fields[&"move"].is_empty()
		
var is_in_field_speed_area: bool:
	get:
		return not _fields[&"speed"].is_empty()

signal field_entered(filed_value_: FieldValue)
signal field_exited(filed_value_: FieldValue)

func _ready() -> void:
	%Area2DField.set_collision_layer_value(Core.FIELD_COLLISION_LAYER, true)
	%Area2DField.set_collision_mask_value(Core.FIELD_COLLISION_LAYER, true)
	
	%Area2DFieldLeft.set_collision_layer_value(Core.FIELD_COLLISION_LAYER, true)
	%Area2DFieldLeft.set_collision_mask_value(Core.FIELD_COLLISION_LAYER, true)
	
	%Area2DFieldRight.set_collision_layer_value(Core.FIELD_COLLISION_LAYER, true)
	%Area2DFieldRight.set_collision_mask_value(Core.FIELD_COLLISION_LAYER, true)
	
	%Area2DFieldUp.set_collision_layer_value(Core.FIELD_COLLISION_LAYER, true)
	%Area2DFieldUp.set_collision_mask_value(Core.FIELD_COLLISION_LAYER, true)
	
	%Area2DFieldDown.set_collision_layer_value(Core.FIELD_COLLISION_LAYER, true)
	%Area2DFieldDown.set_collision_mask_value(Core.FIELD_COLLISION_LAYER, true)
	
	%Area2DMove.set_collision_layer_value(Core.FIELD_MOVE_COLLISION_LAYER, true)
	%Area2DMove.set_collision_mask_value(Core.FIELD_MOVE_COLLISION_LAYER, true)
	
	%Area2DSpeed.set_collision_layer_value(Core.FIELD_SPEED_COLLISION_LAYER, true)
	%Area2DSpeed.set_collision_mask_value(Core.FIELD_SPEED_COLLISION_LAYER, true)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	_fields = {
		&"field": {},
		&"left": {},
		&"right": {},
		&"up": {},
		&"down": {},
		&"move": {},
		&"speed": {},
	}
	
	_update_rect()

func refresh() -> void:
	super.refresh()
	
	_update_rect()
	
func set_rect(rect_: Rect2) -> void:
	rect = rect_
	_update_rect()

func _update_rect() -> void:
	var rect_: Rect2 = rect
	
	if not rect_.has_area():
		rect_ = _get_parent_collision_rect()
		
		if not rect_.has_area():
			rect_ = Rect2(Vector2(-16.0, -16.0), Vector2(32.0, 32.0))
	
	# Subtract a bit so it will actually 
	# be on the tile before triggering
	_field_rect = Rect2(
		rect_.position + Vector2(FIELD_OFFSET, FIELD_OFFSET),
		rect_.size - Vector2(FIELD_OFFSET * 2, FIELD_OFFSET * 2)
	)

	for area_2d in area_2d_boxes:
		for child in area_2d.get_children():
			if child is CollisionShape2D and child.shape is RectangleShape2D:
				var shape = child.shape as RectangleShape2D
				shape.size = _field_rect.size
				child.position = _field_rect.position + _field_rect.size * 0.5
	
	_position_area_2d_fields_to_rect(rect_)
				
func _get_parent_collision_rect() -> Rect2:
	var parent = get_parent()
	
	if parent is BaseNode2D or parent is BaseCharacterBody2D:
		return parent.get_rect()
	
	if parent is CollisionObject2D:
		return Core.get_collision_rect(parent)
	
	return Rect2()
	
func _position_area_2d_fields_to_rect(rect_: Rect2) -> void:
	_set_area_shape(
		%Area2DFieldLeft, 
		Vector2(
			rect_.position.x - BOUNDS_OFFSET - BOUNDS_THICKNESS * 0.5, 
			rect_.position.y + rect_.size.y * 0.5
		), 
		Vector2(BOUNDS_THICKNESS, rect_.size.y)
	)
	
	_set_area_shape(
		%Area2DFieldRight, 
		Vector2(
			rect_.position.x + rect_.size.x + BOUNDS_OFFSET + BOUNDS_THICKNESS * 0.5, 
			rect_.position.y + rect_.size.y * 0.5
		), 
		Vector2(BOUNDS_THICKNESS, rect_.size.y)
	)

	_set_area_shape(
		%Area2DFieldUp, 
		Vector2(
			rect_.position.x + rect_.size.x * 0.5, 
			rect_.position.y - BOUNDS_OFFSET - BOUNDS_THICKNESS * 0.5
		), 
		Vector2(rect_.size.x, BOUNDS_THICKNESS)
	)
	
	_set_area_shape(
		%Area2DFieldDown, 
		Vector2(
			rect_.position.x + rect_.size.x * 0.5, 
			rect_.position.y + rect_.size.y + BOUNDS_OFFSET + BOUNDS_THICKNESS * 0.5
		), 
		Vector2(rect_.size.x, BOUNDS_THICKNESS)
	)

func _set_area_shape(area: Area2D, center: Vector2, size: Vector2) -> void:
	for child in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			var shape := child.shape as RectangleShape2D
			shape.size = size
			child.position = center
			return


func _on_area_2d_field_body_entered(body: Node2D) -> void:
	_field_entered(&"field", body)

func _on_area_2d_field_body_exited(body: Node2D) -> void:
	_field_exited(&"field", body)

func _on_area_2d_field_left_body_entered(body: Node2D) -> void:
	_field_entered(&"left", body)

func _on_area_2d_field_left_body_exited(body: Node2D) -> void:
	_field_exited(&"left", body)

func _on_area_2d_field_right_body_entered(body: Node2D) -> void:
	_field_entered(&"right", body)

func _on_area_2d_field_right_body_exited(body: Node2D) -> void:
	_field_exited(&"right", body)

func _on_area_2d_field_up_body_entered(body: Node2D) -> void:
	_field_entered(&"up", body)

func _on_area_2d_field_up_body_exited(body: Node2D) -> void:
	_field_exited(&"up", body)

func _on_area_2d_field_down_body_entered(body: Node2D) -> void:
	_field_entered(&"down", body)

func _on_area_2d_field_down_body_exited(body: Node2D) -> void:
	_field_exited(&"down", body)

func _on_area_2d_move_body_entered(body: Node2D) -> void:
	_field_entered(&"move", body)

func _on_area_2d_move_body_exited(body: Node2D) -> void:
	_field_exited(&"move", body)

func _on_area_2d_speed_body_entered(body: Node2D) -> void:
	_field_entered(&"speed", body)

func _on_area_2d_speed_body_exited(body: Node2D) -> void:
	_field_exited(&"speed", body)
	
func _field_entered(alias_: StringName, body_: Node2D) -> void:
	#TODO: Use a Core.get_parent_object(body_)
	if not body_.get_parent().is_ancestor_of(self):
		return
		
	var field_value_: FieldValue
	
	if alias_ == &"move":
		field_value_ = _get_move_field_value(alias_, body_)
	elif alias_ == &"speed":
		field_value_ = _get_speed_field_value(alias_, body_)
	else:
		field_value_ = _get_field_field_value(alias_, body_)
	
	_fields[alias_][body_.get_instance_id()] = field_value_

	field_entered.emit(field_value_)

func _field_exited(alias_: StringName, body_: Node2D) -> void:
	var field_value_: FieldValue = null
	
	if _fields[alias_].has(body_.get_instance_id()):
		field_value_ = _fields[alias_][body_.get_instance_id()]
		_fields[alias_].erase(body_.get_instance_id())
		
	field_exited.emit(field_value_)

func _get_field_field_value(alias_: StringName, _body: Node2D) -> FieldValue:
	var field_value_: FieldValue = FieldValue.new(Core.FieldType.FIELD)
	
	match alias_:
		&"left":
			field_value_.direction_x = Core.UnitDirection.LEFT
		&"right":
			field_value_.direction_x = Core.UnitDirection.RIGHT
		&"up":
			field_value_.direction_y = Core.UnitDirection.UP
		&"down":
			field_value_.direction_y = Core.UnitDirection.DOWN
	
	return field_value_

func _get_move_field_value(_alias: StringName, body_: Node2D) -> FieldValue:
	var field_value_: FieldValue
	
	if body_ is TileMapLayer:
		field_value_ = _get_field_values(Core.FieldType.MOVE, body_)
	else: 
		field_value_ = FieldValue.new(Core.FieldType.MOVE)
	
	return field_value_

func _get_speed_field_value(_alias: StringName, body_: Node2D) -> FieldValue:
	var field_value_: FieldValue
	
	if body_ is TileMapLayer:
		field_value_ = _get_field_values(Core.FieldType.SPEED, body_)
	else: 
		field_value_ = FieldValue.new(Core.FieldType.SPEED)
	
	return field_value_

func _get_field_values(field_type_: Core.FieldType, tile_map_layer_: TileMapLayer) -> FieldValue:
	var field_value_: FieldValue = FieldValue.new(field_type_)
	
	var local_rect_ = Rect2(
		tile_map_layer_.to_local(to_global(_field_rect.position)),
		_field_rect.size
	)
	
	var start_ = tile_map_layer_.local_to_map(local_rect_.position)
	var end_ = tile_map_layer_.local_to_map(local_rect_.position + local_rect_.size)
	
	for y in range(start_.y, end_.y + 1):
		for x in range(start_.x, end_.x + 1):
			var coords_ = Vector2i(x, y)

			if not _has_tile_physics_layer(field_type_, tile_map_layer_, coords_):
				continue
				
			var data = tile_map_layer_.get_cell_tile_data(coords_)
			if data == null:
				continue
				
			var direction_x: int = data.get_custom_data("direction_x")
			match direction_x:
				-1:
					field_value_.direction_x = Core.UnitDirection.LEFT
				1:
					field_value_.direction_x = Core.UnitDirection.RIGHT
				_:
					field_value_.direction_x = Core.UnitDirection.NONE
					
			var direction_y: int = data.get_custom_data("direction_y")
			match direction_y:
				-1:
					field_value_.direction_y = Core.UnitDirection.UP
				1:
					field_value_.direction_y = Core.UnitDirection.DOWN
				_:
					field_value_.direction_y = Core.UnitDirection.NONE
					
			var speed: int = data.get_custom_data("speed")
			match speed:
				-1:
					field_value_.speed = Core.UnitSpeed.SLOW
				1:
					field_value_.speed = Core.UnitSpeed.FAST
				_:
					field_value_.speed = Core.UnitSpeed.NORMAL

			break
	
	return field_value_

func _has_tile_physics_layer(
	field_type_: Core.FieldType,
	tile_map_layer_: TileMapLayer, 
	coords_: Vector2i,
) -> bool:
	var source_id_ = tile_map_layer_.get_cell_source_id(coords_)
	if source_id_ == -1:
		return false

	var atlas_coords_ = tile_map_layer_.get_cell_atlas_coords(coords_)
	var tile_data_ = tile_map_layer_.tile_set.get_source(source_id_).get_tile_data(atlas_coords_, 0)
	if tile_data_ == null:
		return false
		
	var layer_id: int
	
	match field_type_:
		Core.FieldType.MOVE:
			layer_id = Core.FIELD_MOVE_TILE_SET_PHYSICS_LAYER
		Core.FieldType.SPEED:
			layer_id = Core.FIELD_SPEED_TILE_SET_PHYSICS_LAYER
		_:
			layer_id = Core.FIELD_TILE_SET_PHYSICS_LAYER
	
	if tile_data_.get_collision_polygons_count(layer_id) > 0:
		return true

	#for i in tile_data_.get_collision_polygons_count(layer_id):
		#var shape_ = tile_data_.get_collision_shape(i)
		#
		#if not shape_:
			#continue
			#
		#match field_type_:
			#Core.FieldType.MOVE:
				#if shape_.physics_layer == Core.FIELD_MOVE_COLLISION_LAYER:
					#return true
			#Core.FieldType.SPEED:
				#if shape_.physics_layer == Core.FIELD_SPEED_COLLISION_LAYER:
					#return true
			#_:
				#if shape_.physics_layer == Core.FIELD_COLLISION_LAYER:
					#return true

	return false
