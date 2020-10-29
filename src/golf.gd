extends Node2D

var Card = preload("res://card.tscn")


const COL_WIDTH = 100
const DECK_SIZE = 52
const ROW_HEIGHT = 50
const STOCK_LEFT = 300
const STOCK_TOP = 500
const TABLEAU_LEFT = 190
const TABLEAU_RIGHT = 800
const TABLEAU_SIZE = 35
const TABLEAU_TOP = 130

var _deck = []
var _stock = []

func _ready():
	$Waste.connect("card_clicked", self, "on_waste_clicked")
	setup_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setup_screen():
	_stock.clear()
	$Waste.set_back(16)
	
	if _deck.size() == 0:
		for i in range(1, DECK_SIZE + 1):
			_deck.append(i)
	
	_deck.shuffle()
	
	var x = TABLEAU_LEFT - COL_WIDTH
	var y = TABLEAU_TOP
	var card
	
	for i in range(0, TABLEAU_SIZE):
		x += COL_WIDTH
		if (x > TABLEAU_RIGHT):
			x = TABLEAU_LEFT
			y += ROW_HEIGHT
		var pos = Vector2(x, y)
		card = add_card(_deck[i], pos, false)
		add_child(card)
		
	x = STOCK_LEFT
	y = STOCK_TOP 

	for i in range(TABLEAU_SIZE, DECK_SIZE):
		var pos = Vector2(x, y)
		card = add_card(_deck[i], pos, true)
		add_child(card)
		_stock.push_back(card)


func add_card(idx, pos, isStock: bool):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
#	new_card.z_index = idx
	new_card.position = pos
	new_card.connect("card_clicked", self, 
			"on_stock_clicked" if isStock else "on_tableau_clicked")
	return new_card

	 
func is_match(value1, value2):
	if ((value1 == 1 && value2 == 13) || (value1 == 13 && value2 == 1)):
		return true
	
	var diff = value1 - value2
	var ret = false
	match diff:
		-1:
			ret = true
		1: 
			ret = true
	return ret

func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")

func on_stock_clicked(card):
	var value = card.get_value()
	var suit = card.get_suit()
	print("Stock clicked. value:", value, " suit:", suit)

func on_tableau_clicked(card):
	var value = card.get_value()
	var suit = card.get_suit()
	print("Tableau clicked. value:", value, " suit:", suit)

	var waste_value = $Waste.get_value()
	if is_match(value, waste_value):
		print("It matches")
		
		$Waste.set_cardnum(card.get_cardnum())
		card.move_to($Waste.position, true)



func on_waste_clicked(card):
	print("Move the top card from the stock to waste")
	if _stock.size() > 0:
		var stock_card = _stock.pop_back()
		var idx = stock_card.get_cardnum()
		print("value = ", stock_card.get_value(), " suit=", stock_card.get_suit(),
				" idx=", idx)
		stock_card.move_to($Waste.position, true)
		$Waste.set_cardnum(idx)
	

func _on_New_pressed():
	print("Should start new game")
	pass # Replace with function body.
