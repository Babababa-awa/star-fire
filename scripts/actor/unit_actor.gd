extends BaseActor
class_name UnitActor

var unit: BaseUnit

var unit_modes: Array[Core.UnitMode] = []

func _init(
	unit_: BaseUnit, 
	alias_: StringName,
	enabled_: bool = true
) -> void:
	super._init(alias_, enabled_)
	
	unit = unit_
	
func get_actions() -> Array[StringName]:
	return []
	
func move_process(_delta: float) -> void:
	pass
	
func can_unit_process() -> bool:
	if not unit.is_enabled:
		return false

	if not unit_modes.is_empty() and not unit_modes.has(unit.unit_mode):
		return false

	return true

func can_unit_input() -> bool:
	if unit.actions == null:
		return false
	
	# TODO: Replace this temporary solution of preventing character input on menu
	# such that an interactive level menu could be created
	if Core.level != null and Core.level.level_mode == Core.LevelMode.MENU:
		return false
	
	if is_unit_killed():
		return false
		
	return true

func is_unit_killed() -> bool:
	var life_actor = unit.get_actor_or_null(&"life")
	
	if life_actor == null:
		return false
	
	return life_actor.is_killed
	
func kill_unit(reason_: StringName = &"") -> void:
	var life_actor = unit.get_actor_or_null(&"life")
	
	if life_actor == null:
		return
	
	life_actor.kill(reason_)
	
func revive_unit() -> void:
	var life_actor = unit.get_actor_or_null(&"life")
	
	if life_actor == null:
		return
	
	life_actor.revive()
	
func damage_unit(damage: float, independent: bool = false) -> void:
	var health_actor = unit.get_actor_or_null(&"health")
	
	if health_actor == null:
		return
	
	health_actor.damage(damage, independent)
	
func set_unit_health(health: float) -> void:
	var health_actor = unit.get_actor_or_null(&"health")
	
	if health_actor == null:
		return
	
	health_actor.health = health

func is_unit_climbing() -> bool:
	var climb_actor = unit.get_actor_or_null(&"climb")

	if climb_actor == null:
		return false

	return climb_actor.is_climbing

func is_unit_crouching() -> bool:
	var crouch_actor = unit.get_actor_or_null(&"crouch")

	if crouch_actor == null:
		return false

	return crouch_actor.is_crouching

func is_unit_jumping() -> bool:
	var jump_actor = unit.get_actor_or_null(&"jump")

	if jump_actor == null:
		return false

	return jump_actor.is_jumping

func is_unit_in_air() -> bool:
	var fall_actor = unit.get_actor_or_null(&"fall")
	
	if fall_actor == null:
		return false
		
	return fall_actor.is_in_air

func is_unit_rising() -> bool:
	var fall_actor = unit.get_actor_or_null(&"fall")
	
	if fall_actor == null:
		return false
		
	return fall_actor.is_rising

func is_unit_falling() -> bool:
	var fall_actor = unit.get_actor_or_null(&"fall")

	if fall_actor == null:
		return false

	return fall_actor.is_falling

func is_unit_interacting() -> bool:
	var interact_actor = unit.get_actor_or_null(&"interact")

	if interact_actor == null:
		return false

	return interact_actor.is_interacting

func lose(reason_: StringName = &"") -> void:
	var lose_actor_ = unit.get_actor_or_null(&"lose")
	
	if lose_actor_ != null:
		lose_actor_.lose(reason_)

func win(reason_: StringName = &"") -> void:
	var win_actor_ = unit.get_actor_or_null(&"win")
	
	if win_actor_ != null:
		win_actor_.win(reason_)
