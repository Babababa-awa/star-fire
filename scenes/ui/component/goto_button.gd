@tool

extends TextureButton
class_name GotoButton

@export var goto_ui_id: StringName

@export_category("Visual")
@export_enum("Small", "Large", "Tile") var style: String = "Large":
	set(value):
		style = value
		_update_style()

@export_multiline var text: String:
	get: return %Label.text
	set(value):
		%Label.text = value

@export_category("Audio")
@export var entered_sfx: StringName = &"button_entered"
@export var exited_sfx: StringName = &"button_exited"
@export var pressed_sfx: StringName = &"button_pressed"

var small_normal_texture = preload("res://assets/ui/small_button_normal.png")
var small_pressed_texture = preload("res://assets/ui/small_button_pressed.png")
var small_hover_texture = preload("res://assets/ui/small_button_hover.png")
var small_focused_texture = preload("res://assets/ui/small_button_focused.png")

var large_normal_texture = preload("res://assets/ui/large_button_normal.png")
var large_pressed_texture = preload("res://assets/ui/large_button_pressed.png")
var large_hover_texture = preload("res://assets/ui/large_button_hover.png")
var large_focused_texture = preload("res://assets/ui/large_button_focused.png")

var tile_normal_texture = preload("res://assets/ui/tile_button_normal.png")
var tile_pressed_texture = preload("res://assets/ui/tile_button_pressed.png")
var tile_hover_texture = preload("res://assets/ui/tile_button_hover.png")
var tile_focused_texture = preload("res://assets/ui/tile_button_focused.png")

func _ready() -> void:
	_update_style()

func _update_style() -> void:
	if style == "Large":
		texture_normal = large_normal_texture
		texture_pressed = large_pressed_texture
		texture_hover = large_hover_texture
		texture_focused = large_focused_texture
		size = large_normal_texture.get_size()
		%Label.remove_theme_font_size_override(&"font_size")
	elif style == "Small":
		texture_normal = small_normal_texture
		texture_pressed = small_pressed_texture
		texture_hover = small_hover_texture
		texture_focused = small_focused_texture
		size = small_normal_texture.get_size()
		%Label.remove_theme_font_size_override(&"font_size")
	else: # Tile
		texture_normal = tile_normal_texture
		texture_pressed = tile_pressed_texture
		texture_hover = tile_hover_texture
		texture_focused = tile_focused_texture
		size = tile_normal_texture.get_size()
		%Label.add_theme_font_size_override(&"font_size", 48)

func _on_pressed() -> void:
	if goto_ui_id == &"":
		return

	var parent = get_parent_ui()
	if parent != null:
		Core.audio.play_sfx(pressed_sfx)
		parent.goto(goto_ui_id)

func get_parent_ui() -> BaseUI:
	var parent = get_parent()

	while parent != null:
		if parent is BaseUI:
			break

		parent = parent.get_parent()
		
	return parent

func _on_mouse_entered() -> void:
	Core.audio.play_sfx(entered_sfx)

func _on_mouse_exited() -> void:
	Core.audio.play_sfx(exited_sfx)
