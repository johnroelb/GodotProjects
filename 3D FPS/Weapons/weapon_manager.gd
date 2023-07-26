extends Spatial

# All weapons in the game
var all_weapons = {}

# Carrying Weapons
var weapons = {}

# HUD
var hud

var current_weapon # Reference to the current weapon equipped
var current_weapon_slot = "Empty" # The current weapon slot

var changing_weapon = false
var unequipped_weapon = false

var weapon_index = 0 # For switching weapons through mouse wheel


func _ready():
	hud = owner.get_node("HUD")
	get_parent().get_node("Shooting").add_exception(owner) # Adds exception of player to the shooting raycast

	all_weapons = {
		"Unarmed" : preload("res://Weapons/Unarmed/Unarmed.tscn"),
		"Pistol" : preload("res://Weapons/Armed/Pistol/Pistol.tscn"),
		"Rifle" : preload("res://Weapons/Armed/Rifle/Rifle.tscn")
	}

	weapons = {
		"Empty" : $Unarmed,
		"Primary" : $Pistol,
		"Secondary" : $Rifle
	}

	# Initialize references for each weapon
	for w in weapons:
		if weapons[w] != null:
			weapons[w].weapon_manager = self
			weapons[w].player = owner
			weapons[w].ray = get_parent().get_node("Shooting")
			weapons[w].visible = false

	# Set current weapon to unarmed
	current_weapon = weapons["Empty"]
	change_weapon("Empty")

	# Disable process
	set_process(false)


# Process will be called when changing weapons
func _process(delta):
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return

		unequipped_weapon = true

		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()

	if current_weapon.is_equip_finished() == false:
		return

	changing_weapon = false
	set_process(false)


func change_weapon(new_weapon_slot):
	if new_weapon_slot == current_weapon_slot or weapons[new_weapon_slot] == null:
		return

	if current_weapon != null:
		unequipped_weapon = false
		current_weapon.unequip()

	# Update current weapon slot
	current_weapon_slot = new_weapon_slot

	# Update current_weapon to the new weapon
	current_weapon = weapons[current_weapon_slot]

	# Update the ammo info for the new weapon
	current_weapon.update_ammo()

	changing_weapon = true
	update_weapon_index()
	set_process(true)


# Scroll weapon change
func update_weapon_index():
	match current_weapon_slot:
		"Empty":
			weapon_index = 0
		"Primary":
			weapon_index = 1
		"Secondary":
			weapon_index = 2


func next_weapon():
	weapon_index += 1

	if weapon_index >= weapons.size():
		weapon_index = 0

	change_weapon(weapons.keys()[weapon_index])


func previous_weapon():
	weapon_index -= 1

	if weapon_index < 0:
		weapon_index = weapons.size() - 1

	change_weapon(weapons.keys()[weapon_index])


# Firing and Reloading
func fire():
	if not changing_weapon:
		current_weapon.fire()


func fire_stop():
	current_weapon.fire_stop()


func reload():
	if not changing_weapon:
		current_weapon.reload()


# Ammo Pickup
func add_ammo(amount):
	if current_weapon == null or current_weapon.name == "Unarmed":
		return false

	current_weapon.update_ammo("add", amount)
	return true


# Update HUD
func update_hud(weapon_data):
	var weapon_slot = "1"

	match current_weapon_slot:
		"Empty":
			weapon_slot = "1"
		"Primary":
			weapon_slot = "2"
		"Secondary":
			weapon_slot = "3"

	hud.update_weapon_ui(weapon_data, weapon_slot)


func get_current_weapon():
	return current_weapon
