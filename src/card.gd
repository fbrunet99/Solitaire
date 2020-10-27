# card.gd
extends Area2D

var CardInfo = preload("res://card_info.gd").new()

signal card_clicked

var cur_idx = 0

func _ready():
	pass # Replace with function body.


#func _process(delta):
#	pass


func set_back():
	$CardSprite.frame = 58


func set_cardnum(num):
	cur_idx = num
	if num > 0 and num <= 52:
		$CardSprite.frame = num-1


func get_value():
	var ret
	ret = cur_idx % 13

#	print("getting value div= ", cur_idx / 13, " mod=", ret)
	return ret


func get_suit():
	var ret
	
	if cur_idx < 13:
		ret = CardInfo.Suits.CLUBS
	elif cur_idx < 26:
		ret = CardInfo.Suits.DIAMONDS
	elif cur_idx < 39:
		ret = CardInfo.Suits.SPADES
	elif cur_idx < 52:
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


func _on_card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var value = get_value()
		var suit = get_suit()
		var onTop = is_on_top()
		if onTop:
			print("Card:", value, " suit:", suit)
			emit_signal("card_clicked", value, suit)
	
