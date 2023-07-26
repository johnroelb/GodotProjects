extends Area

export(int) var ammo = 10

onready var timer = $Timer  # Assuming you named the Timer node "RespawnTimer"
var canCollide = true

func _on_AmmoPickup_body_entered(body):
	if canCollide and body.name == "Player":
		var result = body.weapon_manager.add_ammo(ammo)
		
		if result:
			hide()  # hide the object
			canCollide = false  # disable collision
			timer.start()  # start the timer

func _on_Timer_timeout():
	show()  # show the object again
	canCollide = true  # enable collision
