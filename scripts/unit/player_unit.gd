extends BaseUnit 
class_name PlayerUnit

var health: BaseActor:
	get:
		return actors.use(&"health")
		
var hunger: BaseActor:
	get:
		return actors.use(&"hunger")

var items: BaseActor:
	get:
		return actors.use(&"items")
		
var life: BaseActor:
	get:
		return actors.use(&"life")

var interact: BaseActor:
	get:
		return actors.use(&"interact")

var win: BaseActor:
	get:
		return actors.use(&"win")

var lose: BaseActor:
	get:
		return actors.use(&"lose")

func _init(alias_: StringName) -> void:
	super._init(alias_, Core.UnitType.PLAYER)
	
	actors = ActorHandler.new(self)
	actors.add_all({
		&"interact": InteractActor.new(self),
		&"items": ItemsActor.new(self),
		&"collision": CollisionActor.new(self),
		&"damage": DamageActor.new(self),
		&"health": HealthActor.new(self),
		&"hunger": HungerActor.new(self),
		&"life": LifeActor.new(self),
		&"lose": LoseActor.new(self),
		&"win": WinActor.new(self),
	})

	actions = ActionHandler.new(self)
