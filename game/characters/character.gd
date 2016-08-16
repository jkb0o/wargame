
extends Node2D

const UNIT_ACTION_CD = 10

onready var collision = get_node("collision")
onready var cd_indicator = get_node("cd_indicator")
onready var cd_start = null

var _total_hp = 100
var _hp = _total_hp

var _attack = 10
var _attack_range = 1
var _move_cost	= 1
var _attack_cost = 2

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	collision.connect("input_event", self, "_collision_event")
	set_name(str(get_tile_pos()))
	#print("pos: " + str(get_pos()) + ", tile_pos: " + str(get_tile_pos()) + ", converted pos: " + str(get_parent().map_to_world(get_tile_pos())))
	
func _collision_event(viewport, event, area):
	if event.is_action_released("touch"):
		var path = game.field.select_unit(self)
		
func _start_cd():
	cd_start = OS.get_unix_time()
	cd_indicator._start_cd(cd_start)
	
	game.field.clear_selection()
	ui.buttons.hide()

func get_tile_pos():
	#print("get_tile pos " + str(get_pos()) + " " + str(get_parent().world_to_map(get_pos())))
	return get_parent().world_to_map(get_pos())

func move(pos):
	if not game.field.check_cost_and_reduse(_move_cost):
		return
	set_pos(pos+Vector2(0,1))
	set_name(str(get_tile_pos()))
	#_start_cd()
	game.field._lock_unit()
	game.field.show_attack()
	#print("move to " + get_name())

func attack(unit):
	if not game.field.check_cost_and_reduse(_attack_cost):
		return
	
	unit._hp -= _attack
	
	if (unit._hp <= 0):
		unit.queue_free()

	_start_cd()
	game.field._unlock_unit()