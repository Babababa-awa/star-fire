class_name Help

var notices: Array[StringName] = []

func reset():
	notices = []

func issue_notice(name: StringName) -> bool:
	if notices.has(name):
		return false

	notices.push_back(name)
	return true
