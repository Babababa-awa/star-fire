class_name NodeLoader

var nodes: Dictionary
var scenes: Dictionary
var _thread: Thread
var _cancel_thread: bool = false
var is_loading: bool = false
var _current_loading_path: String
var _queue: Array = []
var _in_use: Array = []

signal load_started
signal load_stopped

func _init() -> void:
	_thread = Thread.new()

func reset() -> void:
	if _thread.is_started():
		_cancel_thread = true

	for path in nodes:
		for node in nodes[path]:
			Core.game.remove_level_child(node)
	
	nodes.clear()
	
	is_loading = false
	_current_loading_path = ""
	
	_queue = []
	_in_use = []
	
func load_node(path: String, count: int = 1) -> void:
	if is_loading:
		_queue.push_back({
			"path": path,
			"count": count,
		})
		return
		
	is_loading = true
	_current_loading_path = path
	_thread.start(_threaded_load.bind(path, count))
	load_started.emit()

func _is_loading_node(path: String) -> bool:
	if _current_loading_path == path:
		return true
		
	for value in _queue:
		if value.path == path:
			return true
			
	return false
	
func get_node(path: String) -> Node:
	var node = _get_free_node(path)
	
	if node != null:
		_in_use.push_back(node.get_instance_id())
		
		if node is BaseNode2D or node is BaseCharacterBody2D:
			node.restart()
		
		return node
	
	var node_instance
	
	# If the node doesn't exist, just load it
	if scenes.has(path):
		node_instance = await scenes[path].instantiate()
	else:
		node_instance = await load(path).instantiate()
	
	if not nodes.has(path):
		nodes[path] = []
		
	nodes[path].push_back(node_instance)
	
	Core.game.add_level_child(node_instance)
	
	_in_use.push_back(node_instance.get_instance_id())
	
	if node_instance is BaseNode2D or node_instance is BaseCharacterBody2D:
		node_instance.start()
	
	return node_instance
	

func _get_free_node(path: String) -> Node:
	if not nodes.has(path):
		return null
	
	for node in nodes[path]:
		if not _in_use.has(node.get_instance_id()):
			return node
			
	return null
	
func clear_node(node: Node) -> void:
	free_node(node)
	_remove_node(node)
	
func _remove_node(node: Node) -> void:
	var path = node.scene_file_path
	
	if nodes.has(path):
		for index in nodes[path].size():
			if nodes[path][index] == node:
				Core.game.remove_level_child(nodes[path][index])
				nodes[path].remove_at(index)
				break

func free_node(node: Node) -> void:
	if _in_use.has(node.get_instance_id()):
		_in_use.erase(node.get_instance_id())
		node.position = Core.DEAD_ZONE
		
		if node is BaseNode2D or node is BaseCharacterBody2D:
			node.stop()

func free_nodes(nodes_: Array[Node]) -> void:
	for node in nodes_:
		free_node(node)
		
func free_all() -> void:
	for path in nodes:
		for node in nodes[path]:
			node.position = Core.DEAD_ZONE
			if node is BaseNode2D or node is BaseCharacterBody2D:
				node.stop()
	_in_use = []

func _threaded_load(path: String, count: int) -> Dictionary:
	var node = load(path)
	var loaded_nodes = []
	
	for i in count:
		var node_instance = await node.instantiate()
		# Ensure off screen
		node_instance.position = Core.DEAD_ZONE
		loaded_nodes.push_back(node_instance)
	
	_theaded_load_complete.call_deferred()
	
	return {
		"path": path,
		"scene": node,
		"nodes": loaded_nodes
	}

func _theaded_load_complete() -> void:
	var value = _thread.wait_to_finish()
	
	if _cancel_thread:
		_queue = []
		is_loading = false
		_current_loading_path = ""
		load_stopped.emit()
		return

	if not nodes.has(value.path):
		nodes[value.path] = []

	if not scenes.has(value.path):
		scenes[value.path] = value.scene

	for node in value.nodes:
		nodes[value.path].push_back(node)
		Core.game.add_level_child(node)
	
	if _queue.size():
		var queue_value = _queue.pop_front()

		_current_loading_path = queue_value.path
		_thread = Thread.new()
		_thread.start(_threaded_load.bind(queue_value.path, queue_value.count))
	else:
		is_loading = false
		_current_loading_path = ""
		load_stopped.emit()
