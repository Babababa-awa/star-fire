extends BaseNode2D
class_name BaseArea

var alias: StringName

func _init(alias_: StringName) -> void:
	super._init()
	
	alias = alias_

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	reset_area(reset_type_)

func reset_area(_reset_type: Core.ResetType) -> void:
	pass
	
