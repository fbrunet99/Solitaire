extends Node2D

var CardInfo = preload("res://card_info.gd").new()


func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func set_back():
	$CardSprite.frame = 58


func set_cardnum(num):
	if num > 0 and num <= 52:
		$CardSprite.frame = num-1
