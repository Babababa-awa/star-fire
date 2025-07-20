extends Control
class_name BaseUI

@export var ui_type: Core.UIType = Core.UIType.MENU

var id: StringName

func _init(id_: StringName):
	id = id_
	
func _ready() -> void:
	if visible:
		_focus_first_button()

func show_ui():
	visible = true
	_focus_first_button()
	
func hide_ui():
	visible = false
	
func goto(id_: StringName):
	id_ = Core.game.prepare_ui_id(id_, id)
	
	if id_ == &"":
		return
		
	if id_ == &"exit":
		if Core.EXIT_DELAY > 0.0:
			await get_tree().create_timer(Core.EXIT_DELAY).timeout
			
		Core.game.exit()
		
	if id_ == &"start":
		Core.game.start()
		return
	elif id_.begins_with(&"start:"):
		var level_alias_ = id_.substr(6)
		Core.game.start_level(level_alias_)

	var ui_node = _get_ui(id_)
	
	if ui_node != null:
		Core.game.prepare_ui(id_, id)
		hide_ui()
		ui_node.show_ui()

func _get_ui(id_: StringName) -> BaseUI:
	var parent = get_parent()
	
	for child in parent.get_children():
		if not child is BaseUI:
			continue
			
		if child.id != id_:
			continue
			
		return child
		
	return null

func _focus_first_button() -> void:
	var button = _get_first_button(self)
	
	if button != null:
		button.grab_focus()

func _get_first_button(node: Node) -> Button:
	if node is Button:
		return node
		
	for child in node.get_children():
		if child is Control:
			var button = _get_first_button(child)
			if button != null:
				return button
		
	return null
