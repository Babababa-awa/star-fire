extends BaseUnit
class_name ItemUnit

var item_type: Core.ItemType
var item_meta: Dictionary
var item_scene: SceneValue

var _tile_set_coords: Vector2i = Vector2i.ZERO

func _init(
	alias_: StringName, 
	item_type_: Core.ItemType = Core.ItemType.NONE,
	item_meta_: Dictionary = {},
	item_scene_: SceneValue = null
) -> void:
	super._init(alias_, Core.UnitType.ITEM)
	
	# TODO: Process this information like set functions on ready
	item_type = item_type_
	item_meta = item_meta_
	item_scene = item_scene_
	
	self.visibility_changed.connect(_on_visibility_changed)
	
func _on_visibility_changed() -> void:
	if visible:
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = false
	else:
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = true
	
func set_item_type(item_type_: Core.ItemType) -> void:
	item_type = item_type_
	
func set_item_meta(meta_: Dictionary) -> void:
	item_meta = meta_
	
func set_item_scene(scene_: SceneValue) -> void:
	item_scene = scene_
	
	if scene_ == null:
		return
	
	if scene_.is_scale:
		scale = scene_.scale
		
	if scene_.is_tile_set_coords:
		set_tile_set_coords(scene_.tile_set_coords)
	
func get_item_value() -> ItemValue:
	return ItemValue.new(alias, item_type, item_meta, item_scene)

func set_item_value(item_value_: ItemValue) -> void:
	alias = item_value_.alias
	set_item_type(item_value_.type)
	set_item_meta(item_value_.meta)
	set_item_scene(item_value_.scene)
	
func set_tile_set_coords(tile_set_coords_: Vector2i) -> void:
	_tile_set_coords = tile_set_coords_
	
	var item_tile_map_layer = get_node_or_null("%Item")
	if item_tile_map_layer is TileMapLayer:
		if item_tile_map_layer.tile_set:
			item_tile_map_layer.set_cell(Vector2i(0, 0), item_tile_map_layer.tile_set.get_source_id(0), tile_set_coords_)
		else:
			push_warning("Item TileMapLayer does not have a TileSet set. (" + alias + ")")
