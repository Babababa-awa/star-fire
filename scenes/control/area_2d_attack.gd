extends Area2D
class_name Area2DAttack

@export var type: Core.DamageType = Core.DamageType.NONE

## Base amount of damage before modifiers.
@export var damage: float = 0.0

## Enable if this damage should ignore any damage cooldowns.
@export var independent: bool = false

## Enable if this damage should only apply when the unit is moving.
@export var movement: bool = false

## The minimum movement speed for this damage to apply
@export var min_speed: Core.UnitSpeed = Core.UnitSpeed.SLOW

## The maximum movement speed for this damage to apply
@export var max_speed: Core.UnitSpeed = Core.UnitSpeed.FAST

@export var groups: Array[StringName] = []

func get_damage_value() -> DamageValue:
	var damage_value_ = DamageValue.new(
		type,
		damage, 
		independent
	)
	
	damage_value_.movement = movement
	
	damage_value_.min_speed = min_speed
	
	damage_value_.max_speed = max_speed
	
	damage_value_.groups = groups
	
	damage_value_.node = self

	return damage_value_

func can_damage(unit_: BaseUnit):
	if groups.size() == 0:
		return true
		
	for group_ in groups:
		if unit_.is_in_group(group_):
			return true
	
	return false
	
func process_frame(
	animation_: StringName, 
	frame_: int = 0,
	flip_h_: bool = false,
	flip_v_: bool = false,
) -> void:
	for child in get_children():
		if child is AnimationCollisionShape2D:
			child.process_frame(
				animation_, 
				frame_, 
				flip_h_,
				flip_v_
			)
