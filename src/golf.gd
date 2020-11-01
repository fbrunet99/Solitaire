extends Node2D

var Card = preload("res://card.tscn")
var CardState = preload("res://card_state.gd")

const COL_WIDTH = 110
const DECK_SIZE = 52
const ROW_HEIGHT = 50
const STOCK_LEFT = 800
const STOCK_TOP = 500
const TABLEAU_LEFT = 190
const TABLEAU_RIGHT = 800
const TABLEAU_SIZE = 35
const TABLEAU_TOP = 100
const DISCARD_LEFT = 1150

var _deck = []
var _stock = []
var _tableau = []
var _undo = []

func _ready():
	randomize()
	var _err = $Stock.connect("card_clicked", self, "on_stock_clicked")
	var pos = Vector2(300, 0)
	var card


	# Create a deck that can be reused across multiple games
	if _deck.size() == 0:
		for i in range(1, DECK_SIZE + 1):
			card = create_card(i, pos)
			add_child(card)
			_deck.append(card)
	
	start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_game():
	$ScoreOverlay.clear_messages()
	deal_cards()


# Shuffle the deck and move the cards to the tableau and stock
func deal_cards():
	_stock.clear()
	_tableau.clear()
	$Stock.make_placeholder(9)
	$Stock.visible = false
	$Current.visible = false
	
	disconnect_deck_signals()
	
	_deck.shuffle()
	for i in range(0, _deck.size()):
		_deck[i].position = $Stock.position
	
	var x = TABLEAU_LEFT - COL_WIDTH
	var y = TABLEAU_TOP

	var card
	for i in range(0, TABLEAU_SIZE):
		x += COL_WIDTH
		if (x > TABLEAU_RIGHT):
			x = TABLEAU_LEFT
			y += ROW_HEIGHT
		card = _deck[i]
		_tableau.append(card)
		card.set_face_down(false)
		card.z_index = i
		card.connect("card_clicked", self, "on_tableau_clicked")
		$ShuffleTween.interpolate_property(card,
			"position", card.position,
			Vector2(x,y), 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
		$ShuffleTween.start()
		yield(get_tree().create_timer(0.02), "timeout")


	x = STOCK_LEFT
	y = STOCK_TOP 

	for i in range(TABLEAU_SIZE, DECK_SIZE):
		card = _deck[i]
		card.set_face_down(true)
		card.connect("card_clicked", self, "on_stock_clicked")
		card.position = $Stock.position # Vector2(x, y)
		card.z_index = i
		_stock.push_back(card)
	
	$ScoreOverlay.update_score(-DECK_SIZE)
	$ScoreOverlay.set_remain(DECK_SIZE - TABLEAU_SIZE)
	$Current.visible = false
	$Current.set_cardnum(-1)


# Go back to the main menu
# todo: give are-you-sure dialog if there are any moves
func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")


# If possible get another card from the stock
func on_stock_clicked(_card):
	if _stock.size() > 0:
		var stock_card = _stock.pop_back()
		store_move(stock_card, CardInfo.TYPE_STOCK, $Current.get_cardnum())
		$ScoreOverlay.update_remain(-1)
		$StockTween.interpolate_property(stock_card,
			"position", stock_card.position,
			$Current.position, 0.3, Tween.TRANS_BACK, Tween.EASE_IN)
		stock_card.set_face_down(false)
		$StockTween.start()
		

	if _stock.size() == 0:
		$Stock.visible = false


func _on_StockTween_tween_completed(card, _key):
	
	$Current.set_cardnum(card.get_cardnum())
	$Current.visible = true
	remove_card(card)
	detect_end()

# Remove a card from the tableau if it can be done
func on_tableau_clicked(card):
	var value = card.get_value()
#	var suit = card.get_suit()

	var current_value = $Current.get_value()
	if is_match(value, current_value):
		store_move(card, CardInfo.TYPE_TABLEAU, $Current.get_cardnum())
		$TableauTween.interpolate_property(card,
			"position", card.position,
			$Current.position, 0.3, Tween.TRANS_QUINT, Tween.EASE_IN)
		$TableauTween.start()


func _on_TableauTween_tween_completed(card, _key):
	$Current.set_cardnum(card.get_cardnum())
	remove_card(card)
	_tableau.erase(card)
	$ScoreOverlay.update_score(5)
	detect_end()


# Return true if the values given are a golf match
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


# Detect if the game should be ended win or lose
func detect_end():
	if _tableau.size() <= 0:
		$ScoreOverlay.show_win()

	if _stock.size() <= 0:
		if !any_moves():
			$ScoreOverlay.show_end()


# Return true if there are any moves available
func any_moves():
	var cards = get_selectable_cards()
	var cardValue
	var stockValue = $Current.get_value()
	
	for i in range(0, cards.size()):
		cardValue = cards[i].get_value()
		if is_match(stockValue, cardValue):
			return true

	return false


# Return all the tableau cards that can be selected
func get_selectable_cards():
	var card
	var cards = []

	for i in range(0, _tableau.size()):
		card = _tableau[i]
		if card.is_on_top():
			cards.append(card)
	
	return cards


# Create a new card instance
func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	return new_card


func remove_card(card):
	card.position = Vector2(DISCARD_LEFT, 100)
#	card.z_index = 200


# Clean up any signals in the deck. This is needed because a specific card may be on
# tableau one game and stock the next. 
func disconnect_deck_signals():
	var card
	var _err
	var connections
	for i in range(0, _deck.size()):
		card = _deck[i]
		connections = card.get_signal_connection_list("card_clicked")
		
		for j in range(0, connections.size()):
			var connection = connections[j]
			_err = card.disconnect(connection["signal"], 
					self, connection["method"])


func store_move(card, card_type, old_num):
	var card_state = CardState.new(card, card.position, card_type, old_num)
	_undo.push_back(card_state)
	print("store value:", card.get_value(), " old:", old_num)
	

func _on_New_pressed():
	start_game()


func _on_undo_pressed():
	if _undo.size() > 0:
		var popped = _undo.pop_back()
		var card = popped.get_card()
		if popped.get_type() == CardInfo.TYPE_STOCK:
#			$Stock.set_cardnum(card.get_cardnum())
			_stock.push_back(card)
			card.position = $Stock.position
			card.set_face_down(true)
			$Current.set_cardnum(popped.get_oldnum())
			$ScoreOverlay.update_remain(1)
			$ScoreOverlay.clear_messages()
			$Stock.visible = true
		else:
			_tableau.push_back(card)
			$Current.set_cardnum(popped.get_oldnum())
			card.position = popped.get_position()
			$ScoreOverlay.update_score(-5)
			$ScoreOverlay.clear_messages()
			


