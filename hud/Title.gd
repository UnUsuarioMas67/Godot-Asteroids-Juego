extends CanvasLayer

var high_score = 0


func _ready():
	$Control/HighScore.text = str(high_score)


func update_score(value: int):
	high_score = value
	$Control/HighScore.text = str(high_score)
