class_name StringNameSet

var names: Array[StringName]
var _current: int = 0

signal updated(names_added_: Array[StringName], names_removed_: Array[StringName])

func _init(names_: Array[StringName] = []) -> void:
	names = names_
	
func _iter_init(_arg) -> bool:
	_current = 0
	return (_current < names.size())

func _iter_next(_arg) -> bool:
	_current += 1
	return (_current < names.size())

func _iter_get(_arg) -> StringName:
	return names[_current]
	
func has(name_: StringName) -> bool:
	return names.has(name_)
	
func add(name_: StringName) -> bool:
	if names.has(name_):
		return false
	
	names.push_back(name_)
	updated.emit([name_], [])
	return true

func add_all(names_: Array[StringName]) -> void:
	for name_ in names_:
		add(name_)
	
func remove(name_: StringName) -> bool:
	for i in names.size():
		if names[i] == name_:
			names.remove_at(i)
			updated.emit([], name_)
			return true
			
	return false

func remove_all(names_: Array[StringName]) -> void:
	for i in range(names.size() - 1, -1, -1):
		if names_.has(names[i]):
			names.remove_at(i)
			
func replace(names_: Array[StringName]) -> void:
	if updated.get_connections().is_empty():
		names = names_
		return
	
	var added: Array[StringName] = []
	var removed: Array[StringName] = []
	
	for name in names:
		if not names_.has(name):
			removed.push_back(name)
			
	for name in names_:
		if not names.has(name):
			added.push_back(name)
	
	names = names_
	updated.emit(added, removed)

func clear() -> void:
	names = []
	updated.emit([], names)

func filter(callback_: Callable) -> void:
	var names_ = names.filter(callback_)
	replace(names_)

func order(names_: Array[StringName]) -> void:
	var order_: Array[StringName] = []
	
	for name_ in names_:
		if names.has(name_):
			order_.push_back(name_)

	for name_ in names:
		if not order_.has(name_):
			order_.push_back(name_)
		
	names = order_
