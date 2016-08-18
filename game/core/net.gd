extends Node

const PORT = 50000
const HOST = "91.225.238.186"
var client = StreamPeerTCP.new()
var server_replied = true

const TIMEOUT = 3

var timeout_counter = 0
var connect_attemps_counter = 0

func _ready():
	set_process(true)
	pass
	
func _send(msg):
	client.put_utf8_string(msg)
	
func _process(delta):
	if not client.is_connected() :
		if timeout_counter == 0 :
			connect_attemps_counter += 1
			print("Connecting to ",HOST,":",PORT," (",connect_attemps_counter,")")
			client.connect(HOST,PORT)
		else:
			timeout_counter += delta
			if timeout_counter >= TIMEOUT :
				timeout_counter = 0
	elif client.is_connected() and client.get_available_bytes()>0:
		var r = client.get_utf8_string(client.get_available_bytes())
		_dispatch(r)

func _dispatch(msg):
	var arry = msg.split(".")
	var action = arry[0]
	
	var param1
	var param2
	var param3
	if action == "info":
		param1 = arry[1]
	if action == "move":
		param1 = 0
		param2 = 0
	if action == "start_game":
		param1 = arry[1]
		param2 = arry[2]
	
	call(action, param1, param2)
	
func info(param1, param2):
	print ("Info: ", param1)

func move(param1, param2):
	pass
	
func start_game(param1, param2):
	game.field._init_units(param1, param2)