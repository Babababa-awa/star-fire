extends BaseUI

func _init():
	super._init(&"win")
	
func _ready() -> void:
	_update_button_visibility()

func show_ui():
	super.show_ui()
	
	Core.audio.play_sfx(&"ui/win")
	_update_button_visibility()
	
	if Core.level != null:
		%LabelTimeValue.text = Core.format_time(Core.level.get_play_time())
	else:
		%LabelTimeValue.text = Core.format_time(0)

func _update_button_visibility() -> void:
	if Core.ENABLE_LEVEL_SELECT:
		%GotoButtonLevelSelect.visible = true
		if Core.level != null and Core.level_select.has_next_level(Core.level.alias):
			%GotoButtonNextLevel.visible = true
		else:
			%GotoButtonNextLevel.visible = false
	else:
		%GotoButtonLevelSelect.visible = false
		%GotoButtonNextLevel.visible = false
	
	if Core.ENABLE_PLAY_AGAIN:
		%GotoButtonPlayAgain.visible = true
		
		if not Core.ENABLE_GAME_DIFFICULTY:
			%GotoButtonPlayAgainNormal.visible = false
			%GotoButtonPlayAgainHard.visible = false
		elif Core.game_difficulty == Core.GameDifficulty.EASY:
			%GotoButtonPlayAgainNormal.visible = true
			%GotoButtonPlayAgainHard.visible = false
		elif Core.game_difficulty == Core.GameDifficulty.NORMAL:
			%GotoButtonPlayAgainNormal.visible = false
			%GotoButtonPlayAgainHard.visible = true
		else:
			%GotoButtonPlayAgainNormal.visible = false
			%GotoButtonPlayAgainHard.visible = false
	else:
		%GotoButtonPlayAgain.visible = false
		%GotoButtonPlayAgainNormal.visible = false
		%GotoButtonPlayAgainHard.visible = false

func _on_goto_button_next_level_pressed() -> void:
	if not Core.level_select.has_next_level(Core.level.alias):
		return
		
	var level: StringName = Core.level_select.get_next_level(Core.level.alias)
	Core.game.start_level(level)

func _on_button_play_again_pressed() -> void:
	Core.game.restart()

func _on_button_play_again_normal_pressed() -> void:
	Core.game_difficulty = Global.GameDifficulty.NORMAL
	Core.game.restart()

func _on_button_play_again_hard_pressed() -> void:
	Core.game_difficulty = Global.GameDifficulty.HARD
	Core.game.restart()
