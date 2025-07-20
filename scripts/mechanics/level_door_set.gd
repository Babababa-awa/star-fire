class_name LevelDoorSet

var doors: Array[LevelDoorValue]

func _init(data_: BaseLevelDataLoader) -> void:
	for area in data_.get_area_data():
		if not area.has("doors"):
			continue
			
		for door in area.doors:
			if not door.has("area"):
				continue
			
			if not door.area.has("alias"):
				continue
			
			doors.push_back(LevelDoorValue.new(
				door.alias,
				door.area.alias,
				door.area.position if door.area.has("position") else Vector2i.ZERO,
				door.area.mode if door.area.has("mode") else Core.UnitMode.NORMAL,
				door.meta if door.has("meta") else {},
			))
			
func get_door(alias_: StringName) -> LevelDoorValue:
	for door_ in doors:
		if door_.alias == alias_:
			return door_
			
	return null
	
func get_doors() -> Array[LevelDoorValue]:
	return doors
