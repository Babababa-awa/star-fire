extends BaseUnit
class_name ProjectileUnit

var is_dead: bool = false
var death_cooldown_delta = 0.0
var death_cooldown: CooldownTimer
var death_handled: bool = false

var is_colliding: bool = false

# Wait a bit of time before testing for collision to ensure checking at new position
var _current_collide_delta: float = 0.0
var COLLIDE_DELTA = 0.125

var projectile_type: Core.ProjectileType
var lifespan_delta: float
var _current_lifespan: float

var hide_on_complete_death = false

func _init(
	alias_: StringName, 
	projectile_type_: Core.ProjectileType,
	lifespan_delta_: float,
) -> void:
	super._init(alias_, Core.UnitType.PROJECTILE)
	
	projectile_type = projectile_type_
	lifespan_delta = lifespan_delta_
	
	death_cooldown_delta = max(Core.MIN_COLLISION_WAIT_DELTA, death_cooldown_delta)
	
	death_cooldown = CooldownTimer.new(death_cooldown_delta)
	death_cooldown.add_step(&"hide", Core.MIN_COLLISION_WAIT_DELTA)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	is_dead = false
	death_handled = false
	
	_current_lifespan = 0.0
	
	death_cooldown.reset()

func _ready() -> void:
	%Area2DDamage.connect("body_entered", _on_damage_body_entered)

func _on_damage_body_entered(body: Node2D) -> void:
	if not is_running():
		return

	if not is_enabled:
		return
	
	if Core.is_enemies(self, body):
		is_dead = true

func _process(delta: float) -> void:
	super._process(delta)
	
	if not is_running():
		return
	
	if is_enabled:
		_current_lifespan += delta
		if _current_lifespan > lifespan_delta:
			is_dead = true
		
	_handle_death(delta)
	
func _physics_process(delta: float) -> void:
	if not is_running():
		return
	
	if not is_enabled:
		return
	
	if _current_collide_delta > COLLIDE_DELTA:
		is_colliding = get_slide_collision_count() > 0
		if is_colliding:
			is_dead = true
	else:
		_current_collide_delta += delta

func _handle_death(delta) -> void:
	if not is_dead or death_handled:
		return

	death_cooldown.process(delta)
	
	if death_cooldown.start():
		is_enabled = false
		_start_death()
	elif death_cooldown.is_on_step(&"hide"):
		if not hide_on_complete_death:
			modes.add(&"hide")
	elif death_cooldown.is_complete:
		death_handled = true
		death_cooldown.stop()
		_complete_death()

func _start_death() -> void:
	pass
	
func _complete_death() -> void:
	if hide_on_complete_death:
		modes.add(&"hide")

	Core.nodes.free_node(self)

func start() -> void:
	super.start()
	Core.clear_groups(self)
	_current_collide_delta = 0.0
	is_enabled = true
	is_colliding = false
	
func stop() -> void:
	super.stop()
	velocity = Vector2.ZERO
