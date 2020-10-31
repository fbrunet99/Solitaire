extends Object
class_name CardState

var Card = preload("res://card.tscn")
var CardIno = preload("res://card_info.gd")

var _card
var _position
var _card_type
var _old_cardnum: int

func _init(new_card, new_pos, new_type, old_num):
	_card = new_card
	_position = new_pos
	_card_type = new_type
	_old_cardnum = old_num


func get_card():
	return _card


func get_position():
	return _position


func get_type():
	return _card_type


func get_oldnum():
	return _old_cardnum

