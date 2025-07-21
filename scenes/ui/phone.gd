extends BaseUI

func _init():
	super._init(&"phone")

func _on_goto_button_ok_pressed() -> void:
	Core.game._hide_mouse()
	hide_ui()
	Core.player.items.drop_action_enabled = true
