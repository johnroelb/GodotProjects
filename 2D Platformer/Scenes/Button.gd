extends Button


func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	$Start.play()
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://Scenes/MainScene.tscn")
