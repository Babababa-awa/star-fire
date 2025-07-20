extends PlatformerArea

func _init() -> void:
	super._init(&"grass")

func start() -> void:
	Core.nodes.load_node("res://scenes/unit/item/wire.tscn", 200)
	
	while Core.nodes.is_loading:
		await get_tree().process_frame
	
	await super.start()
