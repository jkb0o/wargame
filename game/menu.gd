
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
func _ready():
	ui.buttons.hide()
	ui.progress.hide()
	
	get_node("solo").get_node("label").set_text("solo")
	get_node("multiplayer").get_node("label").set_text("PvP")


func _on_solo_pressed():
	get_tree().change_scene("res://field.tscn")
	ui.buttons.show()
	ui.progress.show()
	net._connect(false)
	


func _on_multiplayer_pressed():
	get_tree().change_scene("res://field.tscn")
	ui.buttons.show()
	ui.progress.show()
	net._connect(true)
