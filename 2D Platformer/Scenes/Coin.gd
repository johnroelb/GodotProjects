extends Area2D

export var value = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_degrees += 90 * delta
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.collect_coin(value)
		queue_free()
	

