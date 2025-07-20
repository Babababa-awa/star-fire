extends BaseUI

func _init():
	super._init(&"lose")
	
func _ready() -> void:
	_update_button_visibility()

func show_ui():
	super.show_ui()
	
	Core.audio.play_sfx(&"ui/lose")
	_update_button_visibility()
	
	if Core.level != null:
		%LabelTimeValue.text = Core.format_time(Core.level.get_play_time())
	else:
		%LabelTimeValue.text = Core.format_time(0)
	
func _update_button_visibility() -> void:
	if not Core.ENABLE_GAME_DIFFICULTY:
		%ButtonTryAgainEasy.visible = false
		%ButtonTryAgainNormal.visible = false
	elif Core.game_difficulty == Core.GameDifficulty.EASY:
		%ButtonTryAgainEasy.visible = false
		%ButtonTryAgainNormal.visible = false
	elif Core.game_difficulty == Core.GameDifficulty.NORMAL:
		%ButtonTryAgainEasy.visible = true
		%ButtonTryAgainNormal.visible = false
	else:
		%ButtonTryAgainEasy.visible = false
		%ButtonTryAgainNormal.visible = true

func _on_button_try_again_pressed() -> void:
	Core.game.restart()

func _on_button_try_again_easy_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.EASY
	Core.game.restart()

func _on_button_try_again_normal_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.NORMAL
	Core.game.restart()
