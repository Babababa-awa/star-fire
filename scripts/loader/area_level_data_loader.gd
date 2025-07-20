extends BaseLevelDataLoader
class_name AreaLevelDataLoader

func _format_data(data_type: Core.DataType, json_data_: Dictionary):
	match data_type:
		Core.DataType.AREA:
			return _format_area_data(json_data_)
		Core.DataType.ITEM:
			return ItemDataFormatter.get_value(json_data_)
		Core.DataType.LEVEL:
			return AreaLevelDataFormatter.get_data(json_data_)
		
	return json_data_

func _format_area_data(json_data: Dictionary) -> Dictionary:
	json_data.alias = StringName(json_data.alias)
	
	if json_data.has("doors"):
		for i in json_data.doors.size():
			json_data.doors[i] = _format_area_door_data(json_data, json_data.doors[i])
				
	
	if json_data.has("items"):
		for i in json_data.items.size():
			json_data.items[i] = _format_area_item_data(json_data, json_data.items[i])
			
	
	return json_data
	
func _format_area_door_data(area: Dictionary, door: Dictionary) -> Dictionary:
	assert(door.has("alias"), "Area door missing alias. (" + area.alias + ")")
	
	door.alias = StringName(door.alias)
	
	if door.has("area"):
		assert(door.area.has("alias"), "Area door area missing alias. (" + area.alias + ", " + door.alias + ")")
		assert(door.area.has("position"), "Area door area missing position. (" + area.alias + ", " + door.alias + ")")
	
		door.area.alias = StringName(door.area.alias)
		door.area.position = Vector2(door.area.position[0], door.area.position[1])	
		
	return door
	
func _format_area_item_data(area: Dictionary, item: Dictionary) -> Dictionary:
	assert(item.has("alias"), "Item area missing alias. (" + area.alias + ")")
	assert(item.has("position"), "Item area missing position. (" + area.alias + ", " + item.alias + ")")
	
	item.alias = StringName(item.alias)
	item.position = Vector2(item.position[0], item.position[1])
	
	return item
