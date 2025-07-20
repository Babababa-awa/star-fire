extends PlayerUnit
class_name PlayerPlatformerUnit

var crouch: BaseActor:
	get:
		return actors.use(&"crouch")
		
var jump: BaseActor:
	get:
		return actors.use(&"jump")
		
var climb: BaseActor:
	get:
		return actors.use(&"climb")
	
var fall: BaseActor:
	get:
		return actors.use(&"fall")

var weapons: BaseActor:
	get:
		return actors.use(&"weapons")
		
var move: BaseActor:
	get:
		return actors.use(&"move")
		
var roam: BaseActor:
	get:
		return actors.use(&"roam")
		
func _init(alias_: StringName) -> void:
	super._init(alias_)
	
	actors.add_all({
		&"crouch": CrouchPlatformerActor.new(self),
		&"jump": JumpPlatformerActor.new(self),
		&"climb": ClimbPlatformerActor.new(self),
		&"fall": FallPlatformerActor.new(self),
		&"roam": RoamPlatformerActor.new(self),
		&"weapons": WeaponsActor.new(self),
		&"move": MovePlatformerActor.new(self),
	})
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
			
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		if unit_physics == Core.UnitPhysics.PLANE:
			roam.is_in_roam_area = true


func set_unit_physics(unit_physics_: Core.UnitPhysics) -> void:
	super.set_unit_physics(unit_physics_)
	
	roam.is_in_roam_area = (unit_physics_ == Core.UnitPhysics.PLANE)
