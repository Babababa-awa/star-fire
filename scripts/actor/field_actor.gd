extends UnitActor
class_name FieldActor

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"field", enabled)

func ready() -> void:
	super.ready()
	
	var field_ = unit.get_node_or_null("%Field")
	if field_ is FieldController:
		field_.field_entered.connect(_on_field_entered)
		field_.field_exited.connect(_on_field_exited)

func _on_field_entered(field_value_: FieldValue) -> void:
	match field_value_.type:
		Core.FieldType.MOVE:
			match field_value_.direction_x:
				Core.UnitDirection.LEFT:
					move_x(-1.0)
				Core.UnitDirection.RIGHT:
					move_x(1.0)
				_:
					move_x(0.0)
		
			match field_value_.direction_y:
				Core.UnitDirection.UP:
					move_x(-1.0)
				Core.UnitDirection.DOWN:
					move_x(1.0)
				_:
					move_x(0.0)
		Core.FieldType.SPEED:
			match field_value_.speed:
				Core.UnitSpeed.SLOW:
					speed_slow()
				Core.UnitSpeed.FAST:
					speed_fast()
				_:
					speed_normal()
	
func _on_field_exited(_field_value_: FieldValue) -> void:
	pass

func speed_slow() -> void:
	pass
	
func speed_normal() -> void:
	pass
	
func speed_fast() -> void:
	pass
	
func move_x(_intensity: float) -> void:
	pass
	
func move_y(_intensity: float) -> void:
	pass

func move_left() -> void:
	move_y(0.0)
	move_x(-1.0)
	
func move_right() -> void:
	move_y(0.0)
	move_x(1.0)
	
func move_up() -> void:
	move_x(0.0)
	move_y(-1.0)
	
func move_down() -> void:
	move_x(0.0)
	move_y(1.0)

func move_stop() -> void:
	move_x(0)
	move_y(0)
