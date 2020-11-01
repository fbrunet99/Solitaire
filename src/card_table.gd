extends Node
class_name CardTable

var Card = preload("res://card.tscn")
var CardState = preload("res://card_state.gd")

var _deck = []

# Create a new card instance
func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	return new_card
	

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

