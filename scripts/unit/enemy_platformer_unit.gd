extends EnemyUnit
class_name EnemyPlatformerUnit
	
var field: BaseActor:
	get:
		return actors.use(&"field")
		
var climb: BaseActor:
	get:
		return actors.use(&"climb")
		
var fall: BaseActor:
	get:
		return actors.use(&"fall")

var move: BaseActor:
	get:
		return actors.use(&"move")
	
func _init(alias_: StringName) -> void:
	super._init(alias_)
	
	actors.add_all({
		&"field": FieldPlatformerActor.new(self),
		&"climb": ClimbPlatformerActor.new(self),
		&"fall": FallPlatformerActor.new(self),
		&"weapons": WeaponsActor.new(self),
		&"move": MovePlatformerActor.new(self),
	})
	
	
