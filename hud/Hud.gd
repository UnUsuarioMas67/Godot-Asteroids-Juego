extends CanvasLayer

var score := 0
var lives := 0
var high_score := 0


func _ready():
	$Score/ScoreLabel.text = str(score)


func update_score(new_value: int):
	score = new_value
	$Score/ScoreLabel.text = str(score)


func update_high_score(new_value: int):
	high_score = new_value
	$Title/HighScore.text = "High Score: " + str(high_score)


func update_lives(new_value: int):
	lives = new_value
	$Score/Lives.text = ""

	for _i in range(lives):
		$Score/Lives.text += "*"


func switch_mode():
	if $Title.visible:
		$Title.hide()
		$Score.show()
	else:
		$Title.show()
		$Score.hide()
