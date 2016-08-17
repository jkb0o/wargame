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
    print(client.is_connected(), client.get_available_bytes())
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
                timeout_counter = 0 # we would like to try to connect again
    elif client.is_connected() and client.get_available_bytes()>0 :
        print(22222)
        #var r = client.get_data(client.get_available_bytes())
        var r = client.get_utf8_string(client.get_available_bytes())
        #server_replied = true
        
        print("Connected", r)
    pass