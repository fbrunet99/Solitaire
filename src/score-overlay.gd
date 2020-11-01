extends Node2D


var remain = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear_messages():
	$GameOverMessage.visible = false
	$WinMessage.visible = false


func set_score(new_score):
	Global.score = new_score
	$Score.text = str(Global.score)


func update_score(new_score):
	Global.score += new_score
	$Score.text = str(Global.score)


func set_remain(new_remain):
	remain = new_remain
	$Remain.text = str(remain)


func update_remain(add_remain):
	remain += add_remain
	$Remain.text = str(remain)


func show_win():
	$WinMessage.visible = true


func show_end():
	$GameOverMessage.visible = true
