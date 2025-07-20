extends BaseUI

func _init():
	super._init(&"settings")

func show_ui() -> void:
	super.show_ui()
	%HSliderMaster.value = Core.audio.get_volume(Core.AudioType.MASTER)
	%HSliderMusic.value = Core.audio.get_volume(Core.AudioType.MUSIC)
	%HSliderSFX.value = Core.audio.get_volume(Core.AudioType.SFX)
	%HSliderAmbience.value = Core.audio.get_volume(Core.AudioType.AMBIENCE)
	
	if Core.level != null and Core.level.level_mode == Core.LevelMode.GAME:		
		%ColorRect.visible = true
	else:
		%ColorRect.visible = false

func _on_h_slider_master_value_changed(value: float) -> void:
	Core.audio.set_volume(Core.AudioType.MASTER, value)
	
func _on_h_slider_music_value_changed(value: float) -> void:
	Core.audio.set_volume(Core.AudioType.MUSIC, value)

func _on_h_slider_sfx_value_changed(value: float) -> void:
	Core.audio.set_volume(Core.AudioType.SFX, value)

func _on_h_slider_ambience_value_changed(value: float) -> void:
	Core.audio.set_volume(Core.AudioType.AMBIENCE, value)

func _on_goto_button_parent_pressed() -> void:
	Core.settings.save_settings()
