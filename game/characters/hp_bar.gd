
extends Node2D

func _ready():
	set_process(true)

func _process(delta):
	update()
	

func _draw():
	var color = "15E415"
	var parent = get_parent()
	var perc = float(parent._hp)/float(parent._total_hp)
	
	if perc < 0.75:
		color = "CBE314"
	if perc < 0.5:
		color = "E3A814"
	if perc < 0.25:
		color = "E31B14"
	
	draw_rect(Rect2(Vector2(0,0), Vector2(60.0*perc, 7)), Color(color))
