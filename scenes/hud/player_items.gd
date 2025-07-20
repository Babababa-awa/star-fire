extends BaseNode2D

@export var show_title_label: bool = true:
	set(value):
		show_title_label = value
		if get_node_or_null("%HudLabelTitle") != null:
			%HudLabelTitle.visible = value

@export var show_slot_labels: bool = true

@export var item_size: Vector2 = Vector2(128.0, 128.0)
@export var item_scale: Vector2 = Vector2(1.0, 1.0)
@export var label_offset: Vector2 = Vector2(0.0, 0.0)
@export var item_label_offset: Vector2 = Vector2(0.0, 0.0)

@onready var hud_items: Array[BaseNode2D] = [
	%HudItem1,
	%HudItem2,
	%HudItem3,
	%HudItem4,
	%HudItem5,
	%HudItem6,
	%HudItem7,
	%HudItem8,
]

func _ready() -> void:
	%HudLabelTitle.visible = show_title_label

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	_update()

func _update() -> void:
	if Core.player == null:
		visible = false
		return

	var slots_: int = get_slots()

	var items_actor = Core.player.get_actor_or_null(&"items")
	if items_actor == null or not items_actor is ItemsActor:
		visible = false
		return
		
	
	%HudLabelName.visible = false
	
	if slots_ == 1:
		%HudItem1.show_slot_label = false
	else:	
		%HudItem1.show_slot_label = show_slot_labels
	
	for i in hud_items.size():
		if i >= slots_:
			hud_items[i].visible = false
			continue
		
		if i != 0 or slots_ != 1:
			hud_items[i].show_slot_label = show_slot_labels
			
		hud_items[i].position.y = -item_size.y
		hud_items[i].position.x = i * item_size.x
			
		var item_value_ = items_actor.get_item(i)
		
		if item_value_ != null:
			if i == items_actor.selected_slot:
				%HudLabelName.visible = true
				%HudLabelName.text = "ITEM:" + item_value_.alias
			
			hud_items[i].item = item_value_
			
			hud_items[i].visible = true
		else:
			hud_items[i].item = null
		
		if i == items_actor.selected_slot:
			hud_items[i].selected = true
		else:
			hud_items[i].selected = false	
		
	if show_title_label:
		%HudLabelTitle.position.y = label_offset.x
		%HudLabelTitle.position.y = -item_size.y + label_offset.y - %HudLabelTitle.size.y
		
		# 2 is a fuzz value for border / shadow / etc
		%HudLabelName.position.x = slots_ * item_size.x - label_offset.x - %HudLabelName.size.x - 2
		%HudLabelName.position.y = -item_size.y + label_offset.y - %HudLabelName.size.y
		%HudLabelName.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		%HudLabelName.position.x = label_offset.x
		%HudLabelName.position.y = -item_size.y + label_offset.y - %HudLabelName.size.y
		%HudLabelName.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func get_slots() -> int:
	if Core.player == null:
		return 1
	
	var items_actor = Core.player.get_actor_or_null(&"items")
	if items_actor == null or not items_actor is ItemsActor:
		return 1
	
	return min(hud_items.size(), items_actor.slots)
	
func get_rect() -> Rect2:
	return Rect2(Vector2.ZERO, item_size * Vector2(get_slots(), 1))
