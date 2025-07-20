extends Node

#enum WeaponType {
	#MACHINE_GUN,
	#PISTOL,
	#ROCKET_LAUNCHER,
	#SHOTGUN,
#}

#func get_weapon(weapon_type: Global.WeaponType) -> BaseWeapon:
	#match weapon_type:
		#Global.WeaponType.PISTOL:
			#return PistolWeapon.new()
		#Global.WeaponType.MACHINE_GUN:
			#return MachineGunWeapon.new()
		#Global.WeaponType.SHOTGUN:
			#return ShotgunWeapon.new()
		#Global.WeaponType.ROCKET_LAUNCHER:
			#return RocketLauncherWeapon.new()
			#
	#return null

#func get_projectile_type_from_weapon_type(weapon_type: Global.WeaponType) -> Global.ProjectileType:
	#match weapon_type:
		#Global.WeaponType.PISTOL:
			#return Global.ProjectileType.BULLET
		#Global.WeaponType.MACHINE_GUN:
			#return Global.ProjectileType.BULLET
		#Global.WeaponType.SHOTGUN:
			#return Global.ProjectileType.BULLET
		#Global.WeaponType.ROCKET_LAUNCHER:
			#return Global.ProjectileType.ROCKET
			#
	#return Global.ProjectileType.NONE
