
extends Node2D

var _cd_start_time = 0
var _angle_from = 0

func _ready():
	set_process(true)
	pass

func _process(delta):
	var now = OS.get_unix_time()
	
	if now >= _cd_start_time + get_parent().UNIT_ACTION_CD:
		set_hidden(true)
		get_parent().cd_start = null
	else:
		set_hidden(false)
		_angle_from = 360.0 - ((_cd_start_time + get_parent().UNIT_ACTION_CD - now)/10.0 * 360.0)
	
	update()
	
func _start_cd(start_time):
	_cd_start_time = start_time

func draw_circle_arc_poly( center, radius, angle_from, angle_to, color ):
	var nb_points = 32
	var points_arc = Vector2Array()
	points_arc.push_back(center)
	var colors = ColorArray([color])
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
	draw_polygon(points_arc, colors)

func _draw():
	var center = Vector2(0,0)
	var radius = 40
	var angle_from = _angle_from
	var angle_to = 360
	#var color = Color("14D2E3")
	var color = Color("000000")
	
	draw_circle_arc_poly( center, radius, angle_from, angle_to, color )

