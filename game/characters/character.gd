
extends Node2D

onready var collision = get_node("collision")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	collision.connect("input_event", self, "_collision_event")
	set_name(str(get_tile_pos()))
	
func _collision_event(viewport, event, area):
	if event.is_action_released("touch"):
		var path = game.field.show_path(self)
		
func get_tile_pos():
	return get_parent().world_to_map(get_global_pos())

func move(pos):
	set_pos(pos)
	set_name(str(get_tile_pos()))