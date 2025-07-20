extends Node

var game: BaseGame = null
var game_difficulty: Core.GameDifficulty = Core.GameDifficulty.NORMAL

var nodes: NodeLoader
var camera: Camera2D
var level: BaseLevel
var player: PlayerUnit
var items: ItemLoader
var level_select: LevelSelectLoader
var cursor: BaseCursor
var hud: BaseNode2D
var audio: Audio
var help: Help
var speech: Speech
var states: Dictionary
var settings: Settings
var save: Save

# Settings
var locale: String = "en"

var mouse_speed: float = 1.0
var joystick_speed_slow: float = 1.0
var joystick_speed_fast: float = 1.0
var last_joypad_device: int = 0

const MENU_LEVEL = &"menu"
const START_LEVEL = &"level_1"

const TILE_SIZE = 256
const PHYSICS_TILE_SIZE = 128
const FIELD_TILE_SIZE = 16

const DEAD_ZONE: Vector2 = Vector2(-2048, -2048)

const ENABLE_MOUSE_CAPTURE: bool = true
const MOUSE_CURSOR_SIZE: int = 32

const GLOBAL_MODES = []

const MENU_CAMERA_ZOOM: float = 0.5
const MENU_CAMERA_TARGET_OFFSET: Vector2 = Vector2(16 * TILE_SIZE, -TILE_SIZE * 7.5)
#const MENU_CAMERA_TARGET_OFFSET: Vector2 = Vector2(16 * TILE_SIZE, -TILE_SIZE )

const LEVEL_CAMERA_ZOOM: float = 0.65
const LEVEL_CAMERA_TARGET_OFFSET: Vector2 = Vector2(0, -TILE_SIZE / 2)

const MIN_AUDIO_PITCH: float = 0.9
const MAX_AUDIO_PITCH: float = 1.11

const ENABLE_GAME_DIFFICULTY: bool = false
const ENABLE_LEVEL_SELECT: bool = true
const ENABLE_LEVEL_SKIP: bool = true
const ENABLE_LEVEL_NEXT: bool = true
const ENABLE_PLAY_AGAIN: bool = true

# Minimum amount of time for killables to wait after death before being hidden and disabled
const MIN_COLLISION_WAIT_DELTA: float = 0.1

# Used to move unit a slight amount to change collision state
const MIN_COLLISION_OFFSET: float = 0.01

const UNIT_PHYSICS: Core.UnitPhysics = Core.UnitPhysics.PLATFORM

const ENEMY_GROUPS: Array[StringName] = [&"enemy", &"mutual_enemy"]
const FRIEND_GROUPS: Array[StringName] = [&"friend", &"mutual_friend"]
const MUTUAL_ENEMY_GROUPS: Array[StringName] = [&"mutual_enemy"]
const MUTUAL_FRIEND_GROUPS: Array[StringName] = [&"mutual_friend"]

const FIELD_COLLISION_LAYER: int = 25
const FIELD_MOVE_COLLISION_LAYER: int = 26
const FIELD_SPEED_COLLISION_LAYER: int = 27

const FIELD_TILE_SET_PHYSICS_LAYER: int = 0
const FIELD_MOVE_TILE_SET_PHYSICS_LAYER: int = 1
const FIELD_SPEED_TILE_SET_PHYSICS_LAYER: int = 2

const EXIT_DELAY: float = 0.8

enum DoorType {
	AREA,
	ROOM,
}

enum InputType {
	NONE,
	MOUSE,
	KEYBOARD,
	JOYPAD,
}

enum ResetType {
	START,
	RESTART,
	REFRESH,
}

enum LevelMode {
	GAME,
	MENU
}

enum LevelType {
	PLATFORMER,
}

enum UIType {
	GAME,
	LOADER,
	MENU,
}

enum GameDifficulty {
	EASY,
	NORMAL,
	HARD,
}

enum AudioType {
	MASTER,
	MUSIC,
	SFX,
	AMBIENCE,
}

enum DataType {
	AREA,
	OBJECT,
	ITEM,
	LEVEL,
}

enum LockType {
	NONE,
	KEY,
	PASSCODE,
	TERMINAL,
	OBSTRUCTION,
}

enum LockMode {
	LOCK_ONLY,
	UNLOCK_ONLY,
	MANUAL,
	AUTO,
}

enum LockState {
	NONE,
	LOCKED,
	UNLOCKED,
	BYPASSED,
}

enum UnitType {
	ENEMY,
	FRIEND,
	ITEM,
	NEUTRAL,
	OBJECT,
	PLAYER,
	PROJECTILE,
	VEHICLE,
	WEAPON,
}

enum ItemType {
	NONE,
	ACCESSORY,
	ARMOR,
	ARMOR_HEALTH,
	COMPONENT,
	FOOD,
	HEALTH,
	HEALTH_FOOD,
	KEY,
	KNIFE,
	LOCK_PICK,
	REPAIR,
	SHIELD,
	TOOL,
}

enum ItemCollisionMode {
	PLAYER,
	TILE,
}

enum ItemMode {
	SINGLE, # Single item in area
	MULTIPLE, # Multiple items in area
}

# Lock the unit in a specific state
enum UnitMode {
	NONE,
	NORMAL,
	CLIMBING,
}

enum UnitMovement {
	IDLE,
	MOVING,
	CLIMBING,
	JUMPING,
	FALLING,
}

enum UnitPhysics {
	PLATFORM,
	PLANE,
}

enum UnitSpeed {
	NORMAL,
	SLOW,
	FAST,
}

enum UnitStance {
	NORMAL,
	CROUCH,
	PRONE,
}

enum UnitDirection {
	NONE,
	LEFT,
	LEFT_UP,
	LEFT_DOWN,
	RIGHT,
	RIGHT_UP,
	RIGHT_DOWN,
	UP,
	UP_LEFT,
	UP_RIGHT,
	DOWN,
	DOWN_LEFT,
	DOWN_RIGHT,
}

const PLAY_DIRECTIONS: Dictionary = {
	UnitDirection.NONE: [&"idle"],
	UnitDirection.LEFT: [&"left", &"x", &"xy"],
	UnitDirection.RIGHT: [&"right", &"x", &"xy"],
	UnitDirection.UP: [&"up", &"y", &"xy"],
	UnitDirection.DOWN: [&"down", &"y", &"xy"],
	UnitDirection.UP_LEFT: [&"up_left", &"xy", &"up", &"y", &"left", &"x"],
	UnitDirection.UP_RIGHT: [&"up_right", &"xy", &"up", &"y", &"right", &"x"],
	UnitDirection.DOWN_LEFT: [&"down_left", &"xy", &"down", &"y", &"left", &"x"],
	UnitDirection.DOWN_RIGHT: [&"down_right", &"xy", &"down", &"y", &"right", &"x"],
	UnitDirection.LEFT_UP: [&"left_up", &"xy", &"left", &"x", &"up", &"y"],
	UnitDirection.LEFT_DOWN: [&"left_down", &"xy", &"left", &"x", &"down", &"y"],
	UnitDirection.RIGHT_UP: [&"right_up", &"xy", &"right", &"x", &"up", &"y"],
	UnitDirection.RIGHT_DOWN: [&"right_down", &"xy", &"right", &"x", &"down", &"y"],
}

enum PlatformerBehavior {
	NONE,
	CLIMB,
	CROUCH,
	FALL,
	JUMP,
	MOVE,
}

enum WeaponType {
	MELEE,
	PROJECTILE,
}

enum ProjectileType {
	NONE,
	BULLET,
	EXPLOSION,
	ROCKET,
}

enum Edge {
	NONE,
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}

enum ActorState {
	NONE,
	IDLE,
	START,
	STOP,
	UPDATE,
}

enum Error {
	ACTOR_RESTRICTION,
	GAME_RESTRICTION,
	UNHANDLED,
	UNIT_RESTRICTION,
}

enum SpeechStyle {
	TALK,
	THINK,
}

enum SpeechSize {
	SMALL,
	MEDIUM,
	LARGE
}

enum Alignment {
	TOP_LEFT,
	TOP_RIGHT,
	TOP_CENTER,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	CENTER_LEFT,
	CENTER_RIGHT,
	CENTER_CENTER,
}

enum Orientation {
	HORIZONTAL,
	VERTICAL,
	#DIAGONAL
}

enum CollisionMode {
	NONE,
	DAMAGE,
	KILL,
}

enum FieldType {
	NONE,
	FIELD,
	MOVE,
	SPEED,
}

enum DamageType {
	NONE,
}

enum AttackType {
	NONE,
	WEAPON,
}

func apply_difficulty_modifier(value: int, inverse: bool = false, safe: bool = false) -> int:
	if inverse:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value *= 2
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value /= 2
	else:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value /= 2
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value *= 2

	if value == 0:
		value = 1

	if safe and value >= 100:
		value = 99

	return value

func apply_difficulty_modifier_float(value: float, inverse: bool = false, safe: bool = false) -> float:
	if inverse:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value *= 2.0
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value /= 2.0
	else:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value /= 2.0
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value *= 2.0

	if value == 0:
		value = 1.0

	if safe and value >= 100.0:
		value = 99.0

	return value

func is_friends(node1: Node2D, node2: Node2D) -> bool:
	return !is_enemies(node1, node2)

func is_enemies(node1: Node2D, node2: Node2D) -> bool:
	if node1 == node2:
		return false

	for group in Core.MUTUAL_ENEMY_GROUPS:
		if node1.is_in_group(group) and node2.is_in_group(group):
			return true

	for group in Core.MUTUAL_FRIEND_GROUPS:
		if node1.is_in_group(group) and node2.is_in_group(group):
			return false

	var node1_enemy: bool = false
	var node2_enemy: bool = false
	var node1_friend: bool = false
	var node2_friend: bool = false

	for group in Core.ENEMY_GROUPS:
		if node1.is_in_group(group):
			node1_enemy = true

		if node2.is_in_group(group):
			node2_enemy = true

	for group in Core.FRIEND_GROUPS:
		if node1.is_in_group(group):
			node1_friend = true

		if node2.is_in_group(group):
			node2_friend = true

	if node1_enemy and node2_friend:
		return true

	if node2_enemy and node1_friend:
		return true

	return false

func is_friend(node: Node2D) -> bool:
	for group in Core.FRIEND_GROUPS:
		if node.is_in_group(group):
			return true

	return false

func is_enemy(node: Node2D) -> bool:
	for group in Core.ENEMY_GROUPS:
		if node.is_in_group(group):
			return true

	return false

func clear_groups(node: Node2D) -> void:
	var groups = node.get_groups()

	for group in groups:
		node.remove_from_group(group)

func select_random(array: Array, count: int) -> Array:
	count = min(count, array.size())

	var shuffled = array.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)

func dictionary_contains(superset: Dictionary, subset: Dictionary) -> bool:
	for key in subset:
		if not superset.has(key):
			return false

		var value_subset = subset[key]
		var value_superset = superset[key]

		if value_subset is Dictionary and value_superset is Dictionary:
			if not dictionary_contains(value_subset, value_superset):
				return false
		elif value_subset != value_superset:
			return false

	return true

func get_closest_vector2(from: Vector2, to1: Vector2, to2: Vector2) -> Vector2:
	return to1 if to1.distance_squared_to(from) < to2.distance_squared_to(from) else to2

func format_time(time: int) -> String:
	var total_seconds = int(floor(time / 1000.0))
	var hours = int(floor(total_seconds / 3600.0))
	var minutes = int(floor((total_seconds % 3600) / 60.0))
	var seconds = total_seconds % 60
	return "%d:%02d:%02d" % [hours, minutes, seconds]

func get_align_offset(rect_: Rect2, alignment_: Core.Alignment) -> Vector2:
	match alignment_:
		Core.Alignment.TOP_LEFT:
			return -rect_.position

		Core.Alignment.TOP_RIGHT:
			return -rect_.position - Vector2(rect_.size.x, 0)

		Core.Alignment.TOP_CENTER:
			return -rect_.position - Vector2(rect_.size.x / 2, 0)

		Core.Alignment.BOTTOM_LEFT:
			return -rect_.position - Vector2(0, rect_.size.y)

		Core.Alignment.BOTTOM_RIGHT:
			return -rect_.position - rect_.size

		Core.Alignment.BOTTOM_CENTER:
			return -rect_.position - Vector2(rect_.size.x / 2, rect_.size.y)

		Core.Alignment.CENTER_LEFT:
			return -rect_.position - Vector2(0, rect_.size.y / 2)

		Core.Alignment.CENTER_RIGHT:
			return -rect_.position - Vector2(rect_.size.x, rect_.size.y / 2)

		Core.Alignment.CENTER_CENTER:
			return -rect_.position - (rect_.size / 2)

	return Vector2.ZERO

func get_collision_rect(collision_object_: CollisionObject2D) -> Rect2:
	var total_rect_: Rect2 = Rect2()

	for owner_id_ in collision_object_.get_shape_owners():
		var shape_count_: int = collision_object_.shape_owner_get_shape_count(owner_id_)

		for i in shape_count_:
			var shape_: Shape2D = collision_object_.shape_owner_get_shape(owner_id_, i)
			var transform_: Transform2D = collision_object_.shape_owner_get_transform(owner_id_)
			var shape_rect_: Rect2 = Core._get_shape_bounding_rect(shape_, transform_.origin)

			if total_rect_.has_area():
				total_rect_ = total_rect_.expand(shape_rect_.position)
				total_rect_ = total_rect_.expand(shape_rect_.end)
			else:
				total_rect_.position = shape_rect_.position
				total_rect_.size = shape_rect_.size

	return total_rect_

func get_global_collision_rect(collision_object_: CollisionObject2D) -> Rect2:
	var total_rect_: Rect2 = Rect2()

	for owner_id_ in collision_object_.get_shape_owners():
		var shape_count_: int = collision_object_.shape_owner_get_shape_count(owner_id_)

		for i in shape_count_:
			var shape_: Shape2D = collision_object_.shape_owner_get_shape(owner_id_, i)
			var local_transform_: Transform2D = collision_object_.shape_owner_get_transform(owner_id_)
			var global_transform_: Transform2D = collision_object_.global_transform * local_transform_
			var shape_rect_: Rect2 = Core._get_shape_bounding_rect(shape_, global_transform_.origin)

			total_rect_ = total_rect_.expand(shape_rect_.position)
			total_rect_ = total_rect_.expand(shape_rect_.end)

	return total_rect_

func _get_shape_bounding_rect(shape_: Shape2D, offset_: Vector2) -> Rect2:
	if shape_ is RectangleShape2D:
		var extents_: Vector2 = shape_.size / 2
		var position_: Vector2 = offset_ - extents_

		return Rect2(position_, shape_.size)

	if shape_ is CapsuleShape2D:
		var radius_: float = shape_.radius
		var height_: float = shape_.height

		var position_: Vector2 = offset_ - Vector2(radius_, height_ / 2)
		var size_: Vector2 = Vector2(radius_ * 2, height_)

		return Rect2(position_, size_)

	if shape_ is CircleShape2D:
		var radius_: float = shape_.radius

		var position_: Vector2 = offset_ - Vector2(radius_, radius_)
		var size_: Vector2 = Vector2(radius_ * 2, radius_ * 2)

		return Rect2(position_, size_)

	# Default for unknown shapes
	return Rect2(offset_, Vector2.ZERO)

func is_adjacent_rect(from_rect_: Rect2, to_rect_: Rect2, edge_: Core.Edge) -> bool:
	if from_rect_.size == Vector2.ZERO or to_rect_.size == Vector2.ZERO:
		return false

	#if edge_ == Core.Edge.NONE:
		#if from_rect_.intersects(to_rect_):
			#return true

	var from_rect_top: float = from_rect_.position.y
	var from_rect_bottom: float = from_rect_.position.y + from_rect_.size.y
	var from_rect_left: float = from_rect_.position.x
	var from_rect_right: float = from_rect_.position.x + from_rect_.size.x

	var to_rect_top: float = to_rect_.position.y
	var to_rect_bottom: float = to_rect_.position.y + to_rect_.size.y
	var to_rect_left: float = to_rect_.position.x
	var to_rect_right: float = to_rect_.position.x + to_rect_.size.x

	if edge_ == Core.Edge.NONE:
		if is_equal_approx(from_rect_top, to_rect_bottom):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.TOP)

		if is_equal_approx(from_rect_bottom, to_rect_top):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.BOTTOM)

		if is_equal_approx(from_rect_left, to_rect_right):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.LEFT)

		if is_equal_approx(from_rect_right, to_rect_left):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.RIGHT)

		return false

	if edge_ == Core.Edge.TOP or edge_ == Core.Edge.BOTTOM:
		if edge_ == Core.Edge.TOP and not is_equal_approx(from_rect_top, to_rect_bottom):
			return false

		if edge_ == Core.Edge.BOTTOM and not is_equal_approx(from_rect_bottom, to_rect_top):
			return false

		if is_equal_approx(from_rect_left, to_rect_left):
			return true

		if is_equal_approx(from_rect_right, to_rect_right):
			return true

		if from_rect_left < to_rect_left and from_rect_right > to_rect_right:
			return true

		if from_rect_left > to_rect_left and from_rect_right < to_rect_right:
			return true

		return false

	if edge_ == Core.Edge.LEFT or edge_ == Core.Edge.RIGHT:
		if edge_ == Core.Edge.LEFT and not is_equal_approx(from_rect_left, to_rect_right):
			return false

		if edge_ == Core.Edge.RIGHT and not is_equal_approx(from_rect_right, to_rect_left):
			return false

		if is_equal_approx(from_rect_top, to_rect_top):
			return true

		if is_equal_approx(from_rect_bottom, to_rect_bottom):
			return true

		if from_rect_top < to_rect_top and from_rect_bottom > to_rect_bottom:
			return true

		if from_rect_top > to_rect_top and from_rect_bottom < to_rect_bottom:
			return true

	return false

# Function to add a prefix to the texture path
func add_suffix_to_path(path_: StringName, suffix_: StringName) -> StringName:
	var file_name: String = path_.get_file()
	var extension: String = path_.get_extension()

	if extension == "":
		file_name = file_name + "_" + suffix_
	else:
		# - 1 for the period
		file_name = file_name.substr(0, file_name.length() - extension.length() - 1) + \
			"_" + suffix_ + \
			"." + extension

	return path_.get_base_dir() + "/" + file_name

func get_root_unit(node_: Node2D) -> BaseUnit:
	var parent: Node = node_.get_parent()

	if parent is BaseCharacterBody2D or parent is BaseNode2D:
		var root_parent = get_root_unit(parent)

		if root_parent != null:
			return root_parent

		if parent is BaseUnit:
			return parent

	return null
