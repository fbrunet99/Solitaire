extends CardTable

const COL_WIDTH = 100
const DECK_SIZE = 52
const ROW_HEIGHT = 50
const TABLEAU_LEFT = 400
const TABLEAU_SIZE = 28
const TABLEAU_TOP = 90
const CARD_SCALE = Vector2(0.5, 0.5)

var _stock = []
var _tableau = []
var _undo = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
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
	deal_cards()


func deal_cards():
	_stock.clear()
	_tableau.clear()
	disconnect_deck_signals()

	var card
	var x = TABLEAU_LEFT
	var y = TABLEAU_TOP
	var row_item = 1
	var row_max = 1
	
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



# Create a new card instance
func create_card(idx, pos):
	var new_card = Card.instance()
	new_card.set_cardnum(idx)
	new_card.position = pos
	return new_card


func _on_Main_pressed():
	var _ret = get_tree().change_scene("res://main.tscn")


func _on_New_pressed():
	pass # Replace with function body.
