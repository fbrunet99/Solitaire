# card.gd
extends Area2D

var CardInfo = preload("res://card_info.gd").new()

signal card_clicked

var _cur_idx setget set_cardnum, get_cardnum


func _ready():
	if _cur_idx == null:
		_cur_idx = 0
	pass # Replace with function body.


#func _process(delta):
#	pass


func set_back(num):
	$CardSprite.frame = num + CardInfo.DECK_SIZE



func set_cardnum(num):
	_cur_idx = num
	if num > 0 and num <= CardInfo.DECK_SIZE:
		$CardSprite.frame = num


func get_cardnum():
	return _cur_idx


func get_value():
	var ret
	if _cur_idx < 1 + CardInfo.SUIT_SIZE:
		ret = _cur_idx
	elif _cur_idx < 1 + (2 * CardInfo.SUIT_SIZE):
		ret = _cur_idx - CardInfo.SUIT_SIZE
	elif _cur_idx < 1 + (3 * CardInfo.SUIT_SIZE):
		ret = _cur_idx - (2 * CardInfo.SUIT_SIZE)
	elif _cur_idx < 1 + (4 * CardInfo.SUIT_SIZE):
		ret = _cur_idx - (3 * CardInfo.SUIT_SIZE)

#	print("getting value div= ", cur_idx / 13, " mod=", ret)
	return ret


func get_suit():
	var ret = 0
	
	if _cur_idx <  1 + CardInfo.SUIT_SIZE:
		ret = CardInfo.Suits.CLUBS
	elif _cur_idx < 1 + (2 * CardInfo.SUIT_SIZE):
		ret = CardInfo.Suits.DIAMONDS
	elif _cur_idx < 1 + (3 * CardInfo.SUIT_SIZE):
		ret = CardInfo.Suits.SPADES
	elif _cur_idx < 1 + (4 * CardInfo.SUIT_SIZE):
		ret = CardInfo.Suits.HEARTS

	return ret

func is_on_top():
	var onTop = true
	var others = get_overlapping_areas()

	if others != null && others.size() > 0:
		onTop = false
		var maxZ = 0
		for i in range(0, others.size()):
			var item = others[i]
			maxZ = max(maxZ, item.z_index)
#			if cardInfo != null:
#				print("overlapping value = %s z=%s" %[cardInfo.value, item.z_index])
#			else:
#				print("overlapping item is not a Card")

		if z_index >= maxZ:
			onTop = true

	return onTop

func move_to(new_position, remove):
	position = new_position
	if remove:
		queue_free()

func _on_card_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var value = get_value()
		var suit = get_suit()
		var onTop = is_on_top()
		if onTop:
			emit_signal("card_clicked", self)
	
