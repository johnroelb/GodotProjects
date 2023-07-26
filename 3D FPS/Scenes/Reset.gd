extends Area


func _ready():
	pass # Replace with function body.



func _on_Area_body_entered(body):
	get_tree().reload_current_scene()
