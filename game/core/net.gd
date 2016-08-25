extends Node

const HOST = "91.225.238.186"
var client = StreamPeerTCP.new()
var server_replied = true

var _delta = null

const TIMEOUT = 3

var timeout_counter = 0
var connect_attemps_counter = 0

func _ready():
	set_process(true)
	pass
	
func _send(msg):
	client.put_utf8_string(msg)
	
func _process(delta):
	_delta = delta
	if not client.is_connected() :
		return
		
	elif client.is_connected() and client.get_available_bytes()>0:
		var r = client.get_utf8_string(client.get_available_bytes())
		_dispatch(r)

func _connect(is_pvp):
	var port = null
	if is_pvp:
		port = 50000
	else:
		port = 40000
	
	if timeout_counter == 0 :
		connect_attemps_counter += 1
		print("Connecting to ",HOST,":",port," (",connect_attemps_counter,")")
		client.connect(HOST,port)
	else:
		timeout_counter += _delta
		if timeout_counter >= TIMEOUT :
			timeout_counter = 0

func _dispatch(msg):
	var arry = msg.split(".")
	var action = arry[0]
	print (msg)
	var param1
	var param2
	var param3
	var param4
	if action == "info":
		param1 = arry[1]
	if action == "move":
		param1 = arry[1]
		param2 = arry[2]
		param3 = arry[3]
	if action == "attack":
		param1 = arry[1]
		param2 = arry[2]
		param3 = arry[3]
	if action == "start_game":
		param1 = arry[1]
		param2 = arry[2]
		param3 = arry[3]
	
	call(action, param1, param2, param3)
	
func info(param1, param2, param3):
	print ("Info: ", param1)

func move(param1, param2, param3):
	var unit = null
	for u in game.field.get_tree().get_nodes_in_group("unit"):
		if param1 == u._id:
			unit = u
			break
	
	if unit:
		unit._move(Vector2(param2, param3))

func start_game(param1, param2, param3):
	game.field._init_units(param1, param2, param3)
	
func attack(param1, param2, param3):
	var unit = null
	for u in game.field.get_tree().get_nodes_in_group("unit"):
		if param2 == u._id:
			unit = u
			break
	
	if unit:
		unit._hp -= int(param3)
		if unit._hp < 0:
			unit.queue_free()
		#print("2222 --- ", unit._hp)