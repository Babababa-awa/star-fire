extends BaseArea
class_name PlatformerArea
	
signal door_opened(door_alias_: StringName, door_type_: Core.DoorType)
signal door_closed(door_alias_: StringName, door_type_: Core.DoorType)

func _ready() -> void:
	super._ready()
	
	for child in get_children():
		if child is DoorObject:
			child.connect(&"door_opened", _on_door_opened)
			child.connect(&"door_opened", _on_door_closed)

func _on_door_opened(door_alias_: StringName, door_type_: Core.DoorType) -> void:
	door_opened.emit(door_alias_, door_type_)

func _on_door_closed(door_alias_: StringName, door_type_: Core.DoorType) -> void:
	door_closed.emit(door_alias_, door_type_)
