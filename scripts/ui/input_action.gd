class_name InputAction

var action_name: StringName

func _init(action_name_: StringName) -> void:
	action_name = action_name_
	
func get_keyboard_inputs() -> String:
	return _get_inputs(Core.InputType.KEYBOARD)
	
func get_mouse_inputs() -> String:
	return _get_inputs(Core.InputType.MOUSE)

func get_joypad_inputs() -> String:
	return _get_inputs(Core.InputType.JOYPAD)
	
func _get_inputs(input_type_: Core.InputType):
	var events = InputMap.action_get_events(action_name)
	
	var inputs: Array[String] = []
	
	for event in events:
		if input_type_ == Core.InputType.KEYBOARD and event is InputEventKey:
			inputs.push_back(event.as_text_key_label())
		elif input_type_ == Core.InputType.MOUSE and event is InputEventMouseButton:
			inputs.push_back(_get_mouse_button_name(event.button_index))
		elif input_type_ == Core.InputType.JOYPAD:
			if event is InputEventJoypadButton:
				inputs.push_back(_get_joy_button_name(event.button_index))
			elif event is InputEventJoypadMotion:
				inputs.push_back(_get_joy_axis_name(event.axis))

func _get_mouse_button_name(button_index: int) -> String:
	return tr(&"MOUSE_BUTTON_" + str(button_index))
	
func _get_joy_button_name(button_index: int) -> String:
	if _is_playstation_joypad(Core.last_joypad_device):
		var key = &"JOY_BUTTON_PLAYSTATION_" + str(button_index)
		var translation = tr(key)
		if translation != key:
			return translation
	elif _is_nintendo_joypad(Core.last_joypad_device):
		var key = &"JOY_BUTTON_NINTENDO_" + str(button_index)
		var translation = tr(key)
		if translation != key:
			return translation
	
	return tr(&"JOY_BUTTON_" + str(button_index))

func _get_joy_axis_name(button_index: int) -> String:
	if _is_playstation_joypad(Core.last_joypad_device):
		var key = &"JOY_AXIS_PLAYSTATION_" + str(button_index)
		var translation = tr(key)
		if translation != key:
			return translation
	elif _is_nintendo_joypad(Core.last_joypad_device):
		var key = &"JOY_AXIS_NINTENDO_" + str(button_index)
		var translation = tr(key)
		if translation != key:
			return translation
	
	# Otherwise just display xbox
	return tr(&"JOY_AXIS_" + str(button_index))

func _is_playstation_joypad(device_index: int) -> bool:
	var name = Input.get_joy_name(device_index).to_lower()
	if "playstation" in name or "ps4" in name or "ps5" in name:
		return true

	return false
	
func _is_nintendo_joypad(device_index: int) -> bool:
	var name = Input.get_joy_name(device_index).to_lower()
	if "nintendo" in name or "joy-con" in name:
		return true

	return false
