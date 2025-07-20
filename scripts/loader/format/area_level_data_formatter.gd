class_name AreaLevelDataFormatter

static func get_data(data_: Dictionary) -> Dictionary:
	assert(data_.has("type"), "Level type missing. (" + data_.alias + ")")
	assert(data_.has("area"), "Level area missing. (" + data_.alias + ")")
	assert(data_.has("player"), "Level player missing. (" + data_.alias + ")")
	
	match data_.type:
		"platformer":
			data_.type = Core.LevelType.PLATFORMER
			
	data_.area = _format_level_area_data(data_, data_.area)

	data_.player = _format_level_player_data(data_, data_.player)
	
	if data_.has("locks"):
		for i in data_.locks.size():
			data_.locks[i] = _format_level_lock_data(data_, data_.locks[i])
	
	return data_
	
static func _format_level_area_data(level: Dictionary, area: Dictionary) -> Dictionary:
	assert(level.area.has("alias"), "Level area missing alias. (" + level.alias + ")")
	
	area.alias = StringName(area.alias)
	
	return area
	
static func _format_level_player_data(level_: Dictionary, player_: Dictionary) -> Dictionary:
	assert(player_.has("alias"), "Level player missing alias. (" + level_.alias + ")")
	assert(player_.has("position"), "Level player missing position. (" + level_.alias + ")")
	assert(player_.has("mode"), "Level player missing mode. (" + level_.alias + ")")
	
	player_.alias = StringName(player_.alias)
	
	player_.position = Vector2(player_.position[0], player_.position[1])
	
	match player_.mode:
		"none":
			player_.mode = Core.UnitMode.NONE
		"normal":
			player_.mode = Core.UnitMode.NORMAL
		"climbing":
			player_.mode = Core.UnitMode.CLIMBING
			
	
	if not player_.has("physics") or player_.physics == "platform":
		player_.physics = Core.UnitPhysics.PLATFORM
	else:
		player_.physics = Core.UnitPhysics.PLANE
	
	if player_.has("items"):
		for i in player_.items.size():
			player_.items[i] = _format_player_item_data(level_, player_, player_.items[i])
			
	return player_


static func _format_player_item_data(
	level_: Dictionary, 
	player_: Dictionary, 
	item_: Dictionary
) -> Dictionary:
	assert(item_.has("alias"), "Level player missing alias. (" + level_.alias + ", " + player_.alias + ")")
	
	item_.alias = StringName(item_.alias)
	
	if not item_.has("count"):
		item_.count = 1

	return item_

static func _format_level_lock_data(_level: Dictionary, lock: Dictionary) -> Dictionary:
	lock.alias = StringName(lock.alias)
	
	if lock.has("type"):
		match lock.type:
			"none":
				lock.type = Core.LockType.NONE
			"key":
				lock.type = Core.LockType.KEY
			"passcode":
				lock.type = Core.LockType.PASSCODE
			"terminal":
				lock.type = Core.LockType.TERMINAL
			"obstruction":
				lock.type = Core.LockType.OBSTRUCTION
	else:
		lock.type = Core.LockType.KEY
		
	if lock.has("mode"):
		match lock.mode:
			"lock_only":
				lock.mode = Core.LockMode.LOCK_ONLY
			"unlock_only":
				lock.mode = Core.LockMode.UNLOCK_ONLY
			"manual":
				lock.mode = Core.LockMode.MANUAL
			"auto":
				lock.mode = Core.LockMode.AUTO
			_:
				assert(false, "Invalid lock mode. (" + lock.mode + ")")
	else:
		lock.mode = Core.LockMode.MANUAL
		
	if not lock.has("unlocked"):
		lock.unlocked = false
	
	if not lock.has("bypassable"):
		lock.bypassable = false
		
	if lock.has("meta") and lock.meta.has("keys"):
		lock.meta.keys = lock.meta.keys.map(func(value): return StringName(value))
		
	return lock
