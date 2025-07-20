extends BaseUnit
class_name EnemyUnit

var health: BaseActor:
	get:
		return actors.use(&"health")
		
var life: BaseActor:
	get:
		return actors.use(&"life")

func _init(alias_: StringName) -> void:
	super._init(alias_, Core.UnitType.ENEMY)
	
	actors = ActorHandler.new(self)
	actors.add_all({
		&"collision": CollisionActor.new(self),
		&"damage": DamageActor.new(self),
		&"health": HealthActor.new(self),
		&"life": LifeActor.new(self),
	})
	
	actions = ActionHandler.new(self)
	
	health.damage_cooldown_delta = 0.5
