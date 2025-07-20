extends FieldActor
class_name FieldPlatformerActor

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		pass

func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
	
	if not can_unit_process():
		return

	# Only follow field if player not in control
	# TODO: Some sort of toggle, to continue after no inputs from user
	# and then stop again once inputs happen
	if can_unit_input():
		return

func speed_slow() -> void:
	unit.actions.release(unit.move.action_move_fast)
	unit.actions.press(unit.move.action_move_slow)
	
func speed_normal() -> void:
	unit.actions.release(unit.move.action_move_slow)
	unit.actions.release(unit.move.action_move_fast)
	
func speed_fast() -> void:
	unit.actions.release(unit.move.action_move_slow)
	unit.actions.press(unit.move.action_move_fast)

func move_x(intensity_: float) -> void:
	if is_unit_climbing():
		if intensity_ < 0:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.press(unit.climb.action_climb_up)
		elif intensity_ > 0:
			unit.actions.release(unit.climb.action_climb_up)
			unit.actions.press(unit.climb.action_climb_down)
		else:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.release(unit.climb.action_climb_up)
	else:
		if intensity_ < 0:
			unit.actions.release(unit.move.action_move_right)
			unit.actions.press(unit.move.action_move_left)
		elif intensity_ > 0:
			unit.actions.release(unit.move.action_move_left)
			unit.actions.press(unit.move.action_move_right)
		else:
			unit.actions.release(unit.move.action_move_left)
			unit.actions.release(unit.move.action_move_right)
		
func move_y(intensity_: float) -> void:
	if is_unit_climbing():
		if intensity_ < 0:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.press(unit.climb.action_climb_up)
		elif intensity_ > 0:
			unit.actions.release(unit.climb.action_climb_up)
			unit.actions.press(unit.climb.action_climb_down)
		else:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.release(unit.climb.action_climb_up)
	else:
		if intensity_ < 0:
			unit.actions.release(unit.move.action_move_down)
			unit.actions.press(unit.move.action_move_up)
		elif intensity_ > 0:
			unit.actions.release(unit.move.action_move_up)
			unit.actions.press(unit.move.action_move_down)
		else:
			unit.actions.release(unit.move.action_move_down)
			unit.actions.release(unit.move.action_move_up)
