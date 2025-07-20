extends UnitActor
class_name PlayerActor

func _init(
	unit_: PlayerUnit, 
	alias_: StringName,
	enabled_: bool = true
) -> void:
	super._init(unit_, alias_, enabled_)
