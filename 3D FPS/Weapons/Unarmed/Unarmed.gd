extends Weapon

# Unarmed properties
export var ammo_in_mag: int = 0
export var extra_ammo: int = 0

# Override methods if needed

func fire():
	# Implement the firing logic for the unarmed weapon
	pass

func fire_stop():
	# Implement the logic to stop firing for the unarmed weapon
	pass

func reload():
	# Implement the reloading logic for the unarmed weapon
	pass

func is_equip_finished():
	# Implement the equip finished logic for the unarmed weapon
	return true

func is_unequip_finished():
	# Implement the unequip finished logic for the unarmed weapon
	return true
