extends Area2D
#physics
export var speed: int = 100
export var moveDist: int = 100
export var value = 1
#for Sprites
onready var startY: float = position.y
onready var targetY: float = position.y + moveDist

func move_to(current, to, step):
	var new = current
	
	#moving forward to positive
	if new < to:
		new += step
		
		if new > to:
			new = to
	#moving backwards to negative
	else:
		new -= step
		if new < to:
			new = to
	return new
func _ready():
	pass # Replace with function body.
func _process(delta):
	rotation_degrees += 360 * delta
func _physics_process(delta):
	#move to the targetX position
	position.y = move_to(position.y, targetY, speed * delta)
	#if we're at out target, move in other direction
	if position.y == targetY:
		if targetY == startY:
			targetY = position.y + moveDist
		else:
			targetY = startY
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.die(value)
		
