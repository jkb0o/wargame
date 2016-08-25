
extends Node2D

const UNIT_ACTION_CD = 10

onready var collision = get_node("collision")
onready var cd_indicator = get_node("cd_indicator")
onready var cd_start = null

var _total_hp = 100
var _hp = _total_hp

var _direction = null

var _attack = 40
var _attack_range = 1
var _move_cost	= 1
var _attack_cost = 2

var _id = null
var _army_id = null

onready var animator = get_node("animator")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	collision.connect("input_event", self, "_collision_event")
	set_name(str(get_tile_pos()))
	
func _collision_event(viewport, event, area):
	if event.is_action_released("touch"):
		var path = game.field.select_unit(self)
		
func _start_cd():
	cd_start = OS.get_unix_time()
	cd_indicator._start_cd(cd_start)
	
	game.field.clear_selection()
	ui.buttons.hide()

func get_tile_pos():
	return get_parent().world_to_map(get_pos())

func move(pos):
	if not game.field.check_cost_and_reduse(_move_cost):
		return
	
	var v	 = _getVector(pos)
	v += "_idle"
	animator.play(v)
	set_pos(pos+Vector2(0,1))
	set_name(str(get_tile_pos()))
	game.field._lock_unit()
	game.field.show_attack()
	var name = get_name()
	var msg = "move." + str(_id) + "." + str(get_tile_pos()[0]) + "." + str(get_tile_pos()[1])
	
	net._send(msg)

func _move(pos):
	var layer = get_parent()
	pos = layer.map_to_world(pos) + layer.get_cell_size()*0.5 + Vector2(0,1)
	set_pos(pos)
	set_name(str(get_tile_pos()))
	
	
func attack(unit):
	if not game.field.check_cost_and_reduse(_attack_cost):
		return
	
	var v	 = _getVector(unit.get_pos())
	var anim1 = v + "_attack"
	var anim2 = v + "_idle"
	animator.play(anim1)
	animator.animation_set_next(anim1, anim2)
	print (anim1, "-->", anim2)
	var msg = "attack." + str(_id) + "." + str(unit._id) + "." + str(_attack)
	net._send(msg)
	
	if (unit._hp <= 0):
		unit.queue_free()

	_start_cd()
	game.field._unlock_unit()

func _getVector(to):
	var from = get_pos()
	var rl = null
	var tb = null
	
	print (from , "goto", to)
	
	if to[0] - from[0] > 1:
		rl = "right"
	elif to[0] - from[0] < -1:
		rl = "left"
	else:
		rl = ""
	
	if to[1] - from[1] > 1:
		tb = "bottom"
	elif to[1] - from[1] < -1:
		tb = "top"
	else:
		tb = ""
	
	var anim = tb
	if rl != "":
		if tb:
			anim += "_"
		anim += rl
		
	#anim += "_idle"
	
	#print (anim)
	return anim
	#animator.play(anim)