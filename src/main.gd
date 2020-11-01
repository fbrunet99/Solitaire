extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_golf_pressed():
	var _ret = get_tree().change_scene("res://golf.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_pyramid_pressed():
	var _ret = get_tree().change_scene("res://pyramid.tscn")
