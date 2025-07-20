extends UnitActor
class_name DamageActor

var is_in_damage_area: bool = false
var is_in_kill_area: bool = false

# Damage
var area_damage_amount: float = 10.0

var _damage_nodes: Dictionary = {}

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"damage", enabled)
	unit_modes.push_back(Core.UnitMode.NORMAL)
	unit_modes.push_back(Core.UnitMode.CLIMBING)

func ready() -> void:
	super.ready()
		
	var damage_area = unit.get_node_or_null("%Area2DDamage")
	if damage_area != null:
		damage_area.connect(&"body_entered", _on_damage_body_entered)
		damage_area.connect(&"body_exited", _on_damage_body_exited)
		damage_area.connect(&"area_entered", _on_damage_area_entered)
		damage_area.connect(&"area_exited", _on_damage_area_exited)

	var kill_area = unit.get_node_or_null("%Area2DKill")
	if kill_area != null:
		kill_area.connect(&"body_entered", _on_kill_body_entered)
		kill_area.connect(&"body_exited", _on_kill_body_exited)
		kill_area.connect(&"area_entered", _on_kill_area_entered)
		kill_area.connect(&"area_exited", _on_kill_area_exited)
	
# Damage area
func _on_damage_body_entered(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return
		
	if _damage_nodes.has(body_.get_instance_id()):
		return
	
	_damage_nodes[body_.get_instance_id()] = area_damage_amount
	
	is_in_damage_area = true

func _on_damage_body_exited(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return
		
	_damage_nodes.erase(body_.get_instance_id())
	
	if _damage_nodes.is_empty():
		is_in_damage_area = false
	
func _on_damage_area_entered(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return
	
	if _damage_nodes.has(area_.get_instance_id()):
		return
	
	if area_ is Area2DAttack:
		if not area_.can_damage(unit):
			return
			
		_damage_nodes[area_.get_instance_id()] = area_.get_damage_value()

	is_in_damage_area = true

func _on_damage_area_exited(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return
		
	_damage_nodes.erase(area_.get_instance_id())
	
	if _damage_nodes.is_empty():
		is_in_damage_area = false

# Kill area
func _on_kill_body_entered(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return
		
	is_in_kill_area = true

func _on_kill_body_exited(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return
	
	is_in_kill_area = false
	
func _on_kill_area_entered(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return
	
	is_in_kill_area = true

func _on_kill_area_exited(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return
	
	is_in_kill_area = false
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_in_damage_area = false
		is_in_kill_area = false
		_damage_nodes.clear()

func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
		
	if not can_unit_process():
		return
		
	if is_in_damage_area:
		for key in _damage_nodes:
			var value = _damage_nodes[key]
			
			if value is DamageValue:
				if value.movement and not unit.is_moving():
					continue
				
				match value.min_speed:
					Core.UnitSpeed.NORMAL:
						if unit.unit_speed == Core.UnitSpeed.SLOW:
							continue
					Core.UnitSpeed.FAST:
						if unit.unit_speed != Core.UnitSpeed.FAST:
							continue
							
				match value.max_speed:
					Core.UnitSpeed.SLOW:
						if unit.unit_speed != Core.UnitSpeed.SLOW:
							continue
					Core.UnitSpeed.NORMAL:
						if unit.unit_speed == Core.UnitSpeed.FAST:
							continue
				
				# TODO: Damage area alias, and way to specify health actor not to die if 0
				# so that the object doing the damage can handle the kill reason
				damage_unit(value.damage, value.independent)
			else:
				damage_unit(value)
	
	if is_in_kill_area:
		# TODO: Kill area similar to damage area with alias to know how to kill
		kill_unit(&"kill_area")
