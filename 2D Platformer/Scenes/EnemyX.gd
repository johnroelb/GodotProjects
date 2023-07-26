extends Area2D
#physics
export var speed: int = 100
export var moveDist: int = 100
export var value = 1
#for Sprites
onready var startX: float = position.x
onready var targetX: float = position.x + moveDist
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

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
	position.x = move_to(position.x, targetX, speed * delta)
	#if we're at out target, move in other direction
	if position.x == targetX:
		if targetX == startX:
			targetX = position.x + moveDist
		else:
			targetX = startX
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.die(value)
