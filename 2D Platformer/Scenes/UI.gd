extends Control

onready var scoreText = get_node("ScoreText")
onready var Lives = get_node("Lives")

func lives(lives):
	Lives.text = str(lives)
func set_score_text(score):
	scoreText.text = str(score)
func _ready():
	scoreText.text = "0"
	Lives.text = "3"
