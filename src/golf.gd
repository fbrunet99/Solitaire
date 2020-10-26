extends Node2D

var Card = preload("res://card.tscn")

const DECK_LEFT = 190
const DECK_RIGHT = 800
const DECK_TOP = 130
const COL_WIDTH = 100
const ROW_HEIGHT = 50
const FOUNDATION_SIZE = 35


func _ready():
	setup_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setup_screen():
	var x = DECK_LEFT - COL_WIDTH
	var y = DECK_TOP
	
	for i in range(1, 1 + FOUNDATION_SIZE):
		x += COL_WIDTH
		if (x > DECK_RIGHT):
			x = DECK_LEFT
			y += ROW_HEIGHT
		var pos = Vector2(x, y)
		add_card(i, pos)

func add_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	add_child(new_card)
	 

func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")


func _on_New_pressed():
	print("Should start new game")
	pass # Replace with function body.
