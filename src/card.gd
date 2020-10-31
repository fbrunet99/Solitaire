# card.gd
extends Area2D

var CardInfo = preload("res://card_info.gd").new()

signal card_clicked

var _cur_idx: int setget set_cardnum, get_cardnum
var _face_down: bool setget set_face_down, is_face_down
var _cur_back = 63


func _ready():
	_face_down = false
	if _cur_idx == null:
		_cur_idx = 0


#func _process(delta):
#	pass


func set_face_down(is_down: bool):
	_face_down = is_down
	update_image()


func is_face_down() -> bool:
	return _face_down


# Set this card as a back with no value
func make_placeholder(num: int):
	$CardSprite.frame = num + (2 + CardInfo.DECK_SIZE)
	_cur_idx = -1
	update_image()


func set_cardnum(num: int):
	_cur_idx = num
	update_image()


func get_cardnum() -> int:
	return _cur_idx


func get_value() -> int:
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

func is_on_top() -> bool:
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


func update_image():
	if is_face_down():
		$CardSprite.frame = _cur_back
	else:
		if _cur_idx > 0 and _cur_idx <= CardInfo.DECK_SIZE:
			$CardSprite.frame = _cur_idx



func move_to(new_position, remove):
	position = new_position
	if remove:
		queue_free()


func _on_card_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var onTop = is_on_top()
		if onTop:
			emit_signal("card_clicked", self)

