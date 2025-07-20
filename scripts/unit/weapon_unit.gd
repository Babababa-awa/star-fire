extends BaseUnit
class_name WeaponUnit

var attacks: Array[WeaponAttack]

var signal_can_attack: bool = false

signal attack_error(weapon_: WeaponUnit, attack_: AttackValue, error_: Core.Error)
signal attack_before(weapon_: WeaponUnit, attack_: AttackValue)
signal attack_after(weapon_: WeaponUnit, attack_: AttackValue)
signal attack_complete(weapon_: WeaponUnit, attack_: AttackValue)

func _init(alias_: StringName, attacks_: Array[WeaponAttack]) -> void:
	super._init(alias_, Core.UnitType.WEAPON)

	attacks = attacks_
	
func get_weapon_attack_from_alias(attack_alias_: StringName) -> WeaponAttack:
	for attack_ in attacks:
		if attack_.alias == attack_alias_:
			return attack_
			
	return null
	
func attack(meta_: Dictionary = {}) -> void:
	_attack_from_weapon_attack(attacks[0], meta_)
	
func attack_from_alias(attack_alias_: StringName, meta_: Dictionary = {}) -> void:
	for attack_ in attacks:
		if attack_.alias == attack_alias_:
			_attack_from_weapon_attack(attack_, meta_)
			return
			
	assert(false, "Attack not found. (" + attack_alias_ + ")")
	
func attack_from_index(attack_index_: int, meta_: Dictionary = {}) -> void:
	assert(
		attack_index_ > 0 and attack_index_ <= attacks.size(), 
		"Invalid attack index. (" + alias + ", " + str(attack_index_) + ")"
	)
	
	_attack_from_weapon_attack(attacks[attack_index_ -1], meta_)
	
func attack_from_attack_value(attack_value_: AttackValue, meta_: Dictionary = {}) -> void:
	assert(attack_value_.type == Core.AttackType.WEAPON, "Attack is not a weapon attack.")
	
	if attack_value_.meta.has("weapon_attack_alias"):
		attack_from_alias(attack_value_.meta.weapon_attack_alias, meta_)
	else:
		attack(meta_)

func _attack_from_weapon_attack(_weapon_attack: WeaponAttack, _meta: Dictionary = {}) -> void:
	pass
