extends UnitActor
class_name RoamPlatformerActor

var is_roaming: bool:
	get:
		return _is_roaming()
	set(value):
		# Will get updated from events stil
		is_in_roam_area = value

var is_in_roam_area: bool = false

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"roam", enabled_)

func ready() -> void:
	super.ready()
	
	var roam_area = unit.get_node_or_null("%Area2DRoam")
	if roam_area != null:
		roam_area.connect(&"body_entered", _on_roam_body_entered)
		roam_area.connect(&"body_exited", _on_roam_body_exited)

func _on_roam_body_entered(_body: Node2D) -> void:
	is_in_roam_area = true

func _on_roam_body_exited(_body: Node2D) -> void:
	is_in_roam_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_roaming = false

func _is_roaming() -> bool:
	if not is_in_roam_area:
		return false
	
	var climb_actor = unit.get_actor_or_null(&"climb")
	var fall_actor = unit.get_actor_or_null(&"fall")
	
	if climb_actor != null and climb_actor.is_climbing:
		return false
	
	if fall_actor != null and fall_actor.is_in_air:
		return false
	
	return true
