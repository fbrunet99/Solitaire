extends Node2D

var Card = preload("res://card.tscn")

const COL_WIDTH = 100
const DECK_SIZE = 52
const ROW_HEIGHT = 50
const STOCK_LEFT = 1900
const STOCK_TOP = 500
const TABLEAU_LEFT = 190
const TABLEAU_RIGHT = 800
const TABLEAU_SIZE = 35
const TABLEAU_TOP = 130

var _deck = []
var _stock = []

func _ready():
	$Stock.connect("card_clicked", self, "on_stock_clicked")
	var pos = Vector2(300, 0)
	var card


	if _deck.size() == 0:
		for i in range(1, DECK_SIZE + 1):
			card = create_card(i, pos)
			add_child(card)
			_deck.append(card)
	
	setup_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setup_screen():
	_stock.clear()
	$Stock.set_back(3)
	
	var card
	_deck.shuffle()
	
	var x = TABLEAU_LEFT - COL_WIDTH
	var y = TABLEAU_TOP
	
	for i in range(0, TABLEAU_SIZE):
		x += COL_WIDTH
		if (x > TABLEAU_RIGHT):
			x = TABLEAU_LEFT
			y += ROW_HEIGHT
		card = _deck[i]
		card.z_index = i
		card.connect("card_clicked", self, "on_tableau_clicked")
		card.position = Vector2(x, y)
		
	x = STOCK_LEFT
	y = STOCK_TOP 

	for i in range(TABLEAU_SIZE, DECK_SIZE):
		card = _deck[i]
		card.connect("card_clicked", self, "on_stock_clicked")
		card.position = Vector2(x, y)
		card.z_index = i
		add_child(card)
		_stock.push_back(card)
	
	$ScoreOverlay.update_score(-DECK_SIZE)
	$ScoreOverlay.set_remain(DECK_SIZE - TABLEAU_SIZE)
	$Current.visible = false


func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
#	new_card.z_index = idx
	new_card.position = pos
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

func on_stock2_clicked(card):
	var value = card.get_value()
	var suit = card.get_suit()
	print("Stock clicked. value:", value, " suit:", suit)

func on_tableau_clicked(card):
	var value = card.get_value()
	var suit = card.get_suit()
	print("Tableau clicked. value:", value, " suit:", suit)

	var current_value = $Current.get_value()
	if is_match(value, current_value):
		print("It matches")
		
		$Current.set_cardnum(card.get_cardnum())
		remove_card(card)
		$ScoreOverlay.update_score(5)


func on_stock_clicked(card):
	$Current.visible = true
	print("Move the top card from the stock to current")
	if _stock.size() > 0:
		var stock_card = _stock.pop_back()
		var idx = stock_card.get_cardnum()
		print("value = ", stock_card.get_value(), " suit=", stock_card.get_suit(),
				" idx=", idx)
		remove_card(stock_card)
		$Current.set_cardnum(idx)
		$ScoreOverlay.update_remain(-1)
	
func remove_card(card):
	card.position = Vector2(STOCK_LEFT, STOCK_TOP)
	card.z_index = 200

func _on_New_pressed():
	print("Should start new game")
	setup_screen()
	pass # Replace with function body.
