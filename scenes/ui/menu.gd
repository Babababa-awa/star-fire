extends BaseUI

@onready var sprite_title: AnimatedSprite2D = $MarginContainer/AnimatedSprite2DTitle

func _init():
	super._init(&"menu")

func _ready() -> void:
	super._ready()
	_update_title_position()
	_update_locale()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_title_position()
		
func _update_title_position() -> void:
	if sprite_title:
		var scale: float = 1.0
		var title_size: Vector2 = Vector2(1024, 768)
		var available_space: Vector2 = Vector2(
			get_viewport().get_visible_rect().size.x / 2.0,
			get_viewport().get_visible_rect().size.y / 5.0 * 3.0
		)
		
		if title_size.y > available_space.y:
			scale = available_space.y / title_size.y
			title_size *= scale
			
		var offset = Vector2(available_space.x, available_space.y - (title_size.y / 2.0))
		
		sprite_title.position = offset
		sprite_title.scale = Vector2(scale, scale)
		
func _update_locale() -> void:
	sprite_title.play(Core.locale)
	
	if Core.locale == "jp":
		%ButtonToggleLocale.text = "BUTTON_LOCALE:en"
	else:
		%ButtonToggleLocale.text = "BUTTON_LOCALE:jp"

func _on_button_toggle_locale_pressed() -> void:
	if TranslationServer.get_locale() == "en" or TranslationServer.get_locale().substr(0, 3) == "en_":
		Core.locale = "jp"
		TranslationServer.set_locale("jp")
	else:
		Core.locale = "en"
		TranslationServer.set_locale('en')
		
	_update_locale()
	
	Core.settings.save_settings()
