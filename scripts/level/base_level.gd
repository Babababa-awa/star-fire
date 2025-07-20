extends BaseNode2D
class_name BaseLevel

var alias: StringName
var level_type: Core.LevelType
var level_mode: Core.LevelMode = Core.LevelMode.GAME

var _start_time: int = 0
var _stop_time: int = 0
var _pause_delta: float = 0.0
var auto_start_play_time: bool = false
var auto_stop_play_time: bool = false

func _init(alias_: StringName, level_type_: Core.LevelType) -> void:
	super._init()

	alias = alias_
	level_type = level_type_

func _process(delta: float) -> void:
	super._process(delta)

	if not is_running():
		return

	if auto_stop_play_time and _stop_time == 0:
		if Core.game.is_lose or Core.game.is_win:
			_stop_time = Time.get_ticks_msec()

	if Core.game.is_paused and _start_time != 0 and _stop_time == 0:
		_pause_delta += delta

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		if auto_start_play_time:
			_start_time = Time.get_ticks_msec()
		else:
			_start_time = 0
		_stop_time = 0
		_pause_delta = 0.0

	reset_camera(reset_type_)
	reset_level(reset_type_)

func reset_level(_reset_type: Core.ResetType) -> void:
	Core.game.reset_cursor()

	if level_mode == Core.LevelMode.GAME:
		Core.game.show_ui(&"hud")

func reset_camera(_reset_type: Core.ResetType) -> void:
	if Core.camera == null:
		return

	if level_mode == Core.LevelMode.MENU:
		Core.camera.zoom.x = Core.MENU_CAMERA_ZOOM
		Core.camera.zoom.y = Core.MENU_CAMERA_ZOOM
		Core.camera.target_offset = Core.MENU_CAMERA_TARGET_OFFSET
	else:
		Core.camera.zoom.x = Core.LEVEL_CAMERA_ZOOM
		Core.camera.zoom.y = Core.LEVEL_CAMERA_ZOOM
		Core.camera.target_offset = Core.LEVEL_CAMERA_TARGET_OFFSET

	Core.camera.target_offset_rotation_enabled = true
	Core.camera.limit_smoothed = true
	Core.camera.position_smoothing_enabled = true
	Core.camera.enabled = true
	Core.camera.make_current()

func set_level_type(level_type_: Core.LevelType) -> void:
	level_type = level_type_

func set_level_mode(level_mode_: Core.LevelMode) -> void:
	level_mode = level_mode_

func get_play_time() -> int:
	if _start_time == 0:
		return 0

	if _stop_time == 0:
		return Time.get_ticks_msec() - _start_time - round(_pause_delta)

	return _stop_time - _start_time - round(_pause_delta)
