
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
const NEAREST_CELLS = [
	Vector2(1,0),
	Vector2(0,1),
	Vector2(-1,1),
	Vector2(-1,0),
	Vector2(-1,-1),
	Vector2(0, -1)
]
const selection_scene = preload("selection.tscn")
var current_selection = []

func _ready():
	game.field = self
	
func clear_selection():
	for node in current_selection:
		node.queue_free()
	current_selection.clear()
func show_path(unit):
	clear_selection()
	var layer = unit.get_parent()
	for cell in get_possible_moves(unit):
		var s = selection_scene.instance()
		layer.add_child(s)
		s.set_global_pos(layer.map_to_world(cell))
		s.connect("selected", unit, "move", [s.get_pos()])
		s.connect("selected", self, "clear_selection")
		current_selection.append(s)
	
func get_nearest_cells(pos):
	var res = Vector2Array()
	for nc in NEAREST_CELLS:
		if int(pos.y) % 2 == 0 || nc.y == 0:
			res.push_back(pos+nc)
		else:
			res.push_back(pos+nc+Vector2(1,0))
	return res
	
func get_tile_name(pos):
	var name = null
	for layer in get_children():
		if layer.is_hidden():
			continue
		var cell = layer.get_cellv(pos)
		if cell >= 0:
			name = layer.get_tileset().tile_get_name(cell)
	return name
	
func get_possible_moves(unit):
	var max_cost = 3
	var start = PFNode.new()
	start.pos = unit.get_tile_pos()
	var open = {start.key:start}
	var opena = [start.key]
	var close = {}
	while opena.size():
		var current_key = opena[0]
		var current = open[current_key]
		opena.pop_front()
		open.erase(current_key)
		if current.path_cost() > max_cost:
			continue
		close[current_key] = current
		
		for pos in get_nearest_cells(current.pos):
			var key = str(pos)
			if close.has(key):
				continue
			if open.has(key):
				continue
			if unit.get_parent().has_node(key):
				continue
			print("check tile " + get_tile_name(pos))
			if get_tile_name(pos).begins_with("water"):
				continue
			var pnode = PFNode.new()
			pnode.pos = pos
			pnode.cost = 1
			pnode.prev = current
			open[pnode.key] = pnode
			opena.append(pnode.key)
	var result = Vector2Array()
	for key in close:
		if key == start.key:
			continue
		result.append(close[key].pos)
	return result
			


class PFNode:
	extends Reference
	var prev
	var pos
	var cost = 0
	var key setget set_key, get_key
	func get_key():
		return str(pos)
	func set_key(value):
		pass
	
	func path_cost():
		if prev:
			return cost + prev.path_cost()
		else:
			return cost
	
