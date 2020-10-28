extends Node2D

var Card = preload("res://card.tscn")


const COL_WIDTH = 100
const DECK_SIZE = 52
const FOUNDATION_TOP = 400
const FOUNDATION_LEFT = 300
const ROW_HEIGHT = 50
const STOCK_LEFT = 300
const STOCK_TOP = 500
const TABLEAU_LEFT = 190
const TABLEAU_RIGHT = 800
const TABLEAU_SIZE = 35
const TABLEAU_TOP = 130


func _ready():
	$Waste.connect("card_clicked", self, "on_waste_clicked")
	setup_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setup_screen():
	$Waste.set_back(16)
	
	var x = TABLEAU_LEFT - COL_WIDTH
	var y = TABLEAU_TOP
	
	for i in range(1, 1 + TABLEAU_SIZE):
		x += COL_WIDTH
		if (x > TABLEAU_RIGHT):
			x = TABLEAU_LEFT
			y += ROW_HEIGHT
		var pos = Vector2(x, y)
		add_card(i, pos, false)
		
	x = STOCK_LEFT
	y = STOCK_TOP 

	for i in range(1 + TABLEAU_SIZE, 1 + DECK_SIZE):
		var pos = Vector2(x, y)
		add_card(i, pos, true)


func add_card(idx, pos, isFoundation: bool):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.z_index = idx
	new_card.position = pos
	new_card.connect("card_clicked", self, 
			"on_foundation_clicked" if isFoundation else "on_tableau_clicked")
	add_child(new_card)
	 

func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")

func on_foundation_clicked(value, suit):
	print("Foundation clicked. value:", value, " suit:", suit)

func on_tableau_clicked(value, suit):
	print("Tableau clicked. value:", value, " suit:", suit)

func on_waste_clicked(_value, _suit):
	print("Move the top card from the foundation to waste")

func _on_New_pressed():
	print("Should start new game")
	pass # Replace with function body.
