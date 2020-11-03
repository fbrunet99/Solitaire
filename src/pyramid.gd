extends CardTable

const COL_WIDTH = 100
const DECK_SIZE = 52
const ROW_HEIGHT = 50
const TABLEAU_LEFT = 400
const TABLEAU_SIZE = 28
const TABLEAU_TOP = 90
const CARD_SCALE = Vector2(0.5, 0.5)

var _cur_foundation

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var _err = $Stock.connect("card_clicked", self, "on_stock_clicked")	
	var pos = $Stock.position

	var card
	if _deck.size() == 0:
		for i in range(1, DECK_SIZE + 1):
			card = create_card(i, pos)
			add_child(card)
			_deck.append(card)
			card.scale = CARD_SCALE

	_deck.shuffle()
	for i in range(0, _deck.size()):
		_deck[i].position = $Stock.position
	
	start_game()


func start_game():
	$ScoreOverlay.clear_messages()
	$Foundation1.visible = false
	$Foundation2.visible = false
	$Foundation3.visible = false
	deal_cards(false)


# Shuffle the deck and move the cards to the tableau and stock
func deal_cards(restart):
	_stock.clear()
	_tableau.clear()
	disconnect_deck_signals()

	var card
	var x = TABLEAU_LEFT
	var y = TABLEAU_TOP
	var row_item = 1
	var row_max = 1

	if !restart:
		_deck.shuffle()

	for i in range(0, _deck.size()):
		_deck[i].position = $Stock.position


	for i in range(0, TABLEAU_SIZE):
		if row_item > row_max:
			x = TABLEAU_LEFT - (COL_WIDTH/2 * row_max)
			row_item = 1
			row_max += 1
			y += ROW_HEIGHT

		row_item += 1
		
		card = _deck[i]
		_tableau.append(card)
		card.set_face_down(false)
		card.z_index = i
		card.connect("card_clicked", self, "on_tableau_clicked")
		$ShuffleTween.interpolate_property(card,
			"position", card.position,
			Vector2(x,y), 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
		$ShuffleTween.start()
		
		x += COL_WIDTH
		yield(get_tree().create_timer(0.02), "timeout")

	x = $Stock.position.x
	y = $Stock.position.y
	for i in range(TABLEAU_SIZE, DECK_SIZE):
		$ScoreOverlay.update_remain(1)
		card = _deck[i]
		card.set_face_down(true)
		card.connect("card_clicked", self, "on_stock_clicked")
		card.position = Vector2(x, y)
		card.z_index = i
		_stock.push_back(card)

	$ScoreOverlay.update_score(-DECK_SIZE)
	$ScoreOverlay.set_remain(DECK_SIZE - TABLEAU_SIZE)


# Return true if the values given are a golf match
func is_match(value1, value2):
	return value1 + value2 == 13


# Create a new card instance
func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	return new_card


func on_stock_clicked(_card):
	move_stock($Foundation1)
	move_stock($Foundation2)
	move_stock($Foundation3)


func move_stock(foundation):
	var stock_card

	if _stock.size() > 0:
		stock_card = _stock.pop_back()
		$StockTween.interpolate_property(stock_card,
			"position", stock_card.position,
			foundation.position, 0.3, Tween.TRANS_BACK, Tween.EASE_IN)
		stock_card.set_face_down(false)
		$StockTween.start()
		$ScoreOverlay.update_remain(-1)


# Remove a card from the tableau if it can be done
func on_tableau_clicked(card):
	var value = card.get_value()
#	var suit = card.get_suit()

	var current_value = card.get_value()
	if is_match(current_value, 0):
		store_move(card, CardInfo.TYPE_TABLEAU, card.get_cardnum())
		$TableauTween.interpolate_property(card,
			"position", card.position,
			Vector2(-100, 0), 0.3, Tween.TRANS_QUINT, Tween.EASE_IN)
		$TableauTween.start()
		$ScoreOverlay.update_score(5)
	else:
		var available = gather_available_cards(card)
		for i in range(0, available.size()):
			var other = available[i]
			if is_match(card.get_value(), other.get_value()):
				remove_card(card)
				remove_card(other)
				print("match found")


	if _stock.size() == 0:
		$Stock.visible = false


func _on_StockTween_tween_completed(card, key):
	if card.position == $Foundation1.position:
		$Foundation1.set_cardnum(card.get_cardnum())
		$Foundation1.visible = true
	elif card.position == $Foundation2.position:
		$Foundation2.set_cardnum(card.get_cardnum())
		$Foundation2.visible = true
	else:
		$Foundation3.set_cardnum(card.get_cardnum())
		$Foundation3.visible = true
		
#	remove_card(card)
#	detect_end()


func _on_foundation1_clicked(card):
	move_foundation(card)

func _on_foundation2_clicked(card):
	move_foundation(card)

func _on_foundation3_clicked(card):
	move_foundation(card)


func move_foundation(card):
	var current_value = card.get_value()
	if is_match(current_value, 0):
		store_move(card, CardInfo.TYPE_STOCK, card.get_cardnum())
		$FoundationTween.interpolate_property(card,
			"position", card.position,
			Vector2(-100, 0), 1.3, Tween.TRANS_QUINT, Tween.EASE_IN)
		$FoundationTween.start()
		$ScoreOverlay.update_score(5)


# Get all the cards that can be matched excluding the given card
func gather_available_cards(card):
	var available_cards = get_selectable_cards()
	available_cards.append($Foundation1)
	available_cards.append($Foundation2)
	available_cards.append($Foundation3)
	
	available_cards.erase(card)
	
	return available_cards



func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")


func _on_New_pressed():
	start_game()

