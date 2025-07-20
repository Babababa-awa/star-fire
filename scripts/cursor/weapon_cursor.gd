extends BaseCursor
class_name WeaponCursor

var weapon_type: Global.WeaponType = Global.WeaponType.PISTOL
var current_target: BaseUnit
var current_target_time: float

func _init() -> void:
	super._init(&"weapon")
	
func _ready() -> void:
	super._ready()

	%Area2DTarget.connect("body_entered", _on_target_body_entered)
	%Area2DTarget.connect("body_exited", _on_target_body_exited)
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if not Core.game.is_enabled:
		return
	
	if current_target != null:
		current_target_time += delta

func set_weapon(weapon_type_: Global.WeaponType) -> void:
	weapon_type = weapon_type_
	current_target_time = 0.0
	_update_cursor()
	
func _update_cursor() -> void:
	pass

func _on_target_body_entered(body: Node2D) -> void:
	if Core.is_enemy(body) and can_target(body):
		current_target = body
		current_target_time = 0.0
	else:
		current_target = null
		current_target_time = 0.0

func _on_target_body_exited(body: Node2D) -> void:
	if current_target == body:
		current_target = null
		current_target_time = 0.0

func can_target(node: Node2D) -> bool:
	if not node is BaseUnit:
		return false
		
	if current_target != null and not current_target is ProjectileUnit:
		return false
	
	return true
		
	
