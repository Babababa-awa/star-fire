extends BaseUI

func _init():
	super._init(&"pause")
	
func _ready() -> void:
	_update_button_visibility()
	
func show_ui():
	super.show_ui()
	
	_update_button_visibility()
	
	if Core.level != null:
		%LabelTimeValue.text = Core.format_time(Core.level.get_play_time())
	else:
		%LabelTimeValue.text = Core.format_time(0)

func _update_button_visibility() -> void:
	if (Core.ENABLE_LEVEL_SELECT and 
		Core.ENABLE_LEVEL_SKIP and
		Core.level and
		Core.level_select.has_next_level(Core.level.alias)
	):
		%GotoButtonSkipLevel.visible = true
	else:
		%GotoButtonSkipLevel.visible = false
	
func _on_button_continue_pressed() -> void:
	hide_ui()
	Core.game.toggle_pause()


func _on_goto_button_restart_pressed() -> void:
	hide_ui()
	Core.game.restart()

func _on_goto_button_skip_level_pressed() -> void:
	if not Core.level_select.has_next_level(Core.level.alias):
		return
		
	var level: StringName = Core.level_select.get_next_level(Core.level.alias)
	Core.game.start_level(level)
