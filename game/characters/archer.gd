
extends "character.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var _last_hp_up = 0
var _up_delay = 10
var _up_amount = 40


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	_total_hp = 300
	_hp = _total_hp
	_attack = 60
	_attack_range = 5
	_type = "archer"
	

	set_process(true)
	
func _process(delta):
	return
	var n = get_tile_pos()
	var cell_name = game.field.get_tile_name(n)
	
	if not cell_name.begins_with("Sprite-8"):
		return
	
	var now = OS.get_unix_time()
	
	if now >= _last_hp_up + _up_delay:
		if _hp + _up_amount > _total_hp:
			_hp = _total_hp
		else:
			_hp += _up_amount
			_last_hp_up = now
	


