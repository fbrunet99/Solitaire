extends Node2D


var score = 0
var remain = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_score(new_score):
	score = new_score
	$Score.text = str(score)


func update_score(new_score):
	score += new_score
	$Score.text = str(score)


func set_remain(new_remain):
	remain = new_remain
	$Remain.text = str(remain)

func update_remain(add_remain):
	remain += add_remain
	$Remain.text = str(remain)

