extends Node
class_name CardTable

var Card = preload("res://card.tscn")
var CardState = preload("res://card_state.gd")

const DISCARD_LEFT = 1150

var _deck = []
var _undo = []
var _stock = []
var _tableau = []

# Create a new card instance
func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	return new_card


func remove_card(card):
	card.position = Vector2(DISCARD_LEFT, 100)


func store_move(card, card_type, old_num):
	var card_state = CardState.new(card, card.position, card_type, old_num)
	_undo.push_back(card_state)
	print("store value:", card.get_value(), " old:", old_num)


# Return all the tableau cards that can be selected
func get_selectable_cards():
	var card
	var cards = []

	for i in range(0, _tableau.size()):
		card = _tableau[i]
		if card.is_on_top():
			cards.append(card)
	
	return cards


# Clean up any signals in the deck. This is needed because a specific card may be on
# tableau one game and stock the next. 
func disconnect_deck_signals():
	var card
	var _err
	var connections
	for i in range(0, _deck.size()):
		card = _deck[i]
		disconnect_card_signals(card)


# Remove all signals from the card
func disconnect_card_signals(card):
	var _err
	var connections = card.get_signal_connection_list("card_clicked")
	for j in range(0, connections.size()):
		var connection = connections[j]
		_err = card.disconnect(connection["signal"], 
				self, connection["method"])

