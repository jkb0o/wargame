
extends Node2D

onready var collision = get_node("collision")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	collision.connect("input_event", self, "_collision_event")
	set_name(str(get_tile_pos()))
	print("pos: " + str(get_pos()) + ", tile_pos: " + str(get_tile_pos()) + ", converted pos: " + str(get_parent().map_to_world(get_tile_pos())))
	
	
func _collision_event(viewport, event, area):
	if event.is_action_released("touch"):
		var path = game.field.select_unit(self)
		
func get_tile_pos():
	print("get_tile pos " + str(get_pos()) + " " + str(get_parent().world_to_map(get_pos())))
	return get_parent().world_to_map(get_pos())

func move(pos):
	set_pos(pos+Vector2(0,1))
	set_name(str(get_tile_pos()))
	print("move to " + get_name())
	
func attack(unit):
	unit.queue_free()