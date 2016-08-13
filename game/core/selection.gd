
extends Area2D

signal selected
# member variables here, example:
# var a=2
# var b="textvar"

func _input_event(viewport, event, shape_idx):
	if event.is_action_released("touch"):
		emit_signal("selected")


