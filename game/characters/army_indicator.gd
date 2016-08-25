
extends Node2D

func _ready():
	set_process(true)

func _process(delta):
	update()
	

func _draw():
	var color = "15E415"
	var parent = get_parent()
	var army = parent._army_id
	
	if army == str(1):
		color = "14D2E3"
	if army == str(2):
		color = "E3D214"
	
	draw_circle(Vector2(0,-5), 20, Color(color))
	#draw_rect(Rect2(Vector2(0,0), Vector2(60.0*perc, 7)), Color(color))
