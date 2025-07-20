extends UnitActor
class_name EnemyActor

func _init(
	unit_: EnemyUnit,
	alias_: StringName,
	enabled_: bool = true
) -> void:
	super._init(unit_, alias_, enabled_)
