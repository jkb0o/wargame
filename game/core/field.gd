
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
const ONE_STAMINA_PER_PERIOD = 2
const selection_scene = preload("selection.tscn")

var last_stamina_added
var current_selection = []
var unit = false

func _ready():
	game.field = self
	
	last_stamina_added = OS.get_unix_time()
	
	set_process(true)

func _process(delta):
	var now = OS.get_unix_time()
	
	if last_stamina_added + ONE_STAMINA_PER_PERIOD <= now:
		ui.progress.set_value(ui.progress.get_value() + ui.progress.get_step())
		last_stamina_added = now

func _lock_unit():
	game._locked_by_unit = true
	var btns = ui.buttons.get_children()
	btns[0].set_hidden(true)
	btns[1].set_hidden(false)
	btns[2].set_hidden(true)
	btns[3].set_hidden(false)
	
func _unlock_unit():
	game._locked_by_unit = false
	var btns = ui.buttons.get_children()
	btns[0].set_hidden(false)
	btns[1].set_hidden(false)
	btns[2].set_hidden(false)
	btns[3].set_hidden(true)

func get_stamina():
	return ui.progress.get_value()
	
func reduse_stamina(amount):
	ui.progress.set_value(get_stamina() - amount)
	
func check_cost_and_reduse(cost):
	if (cost > get_stamina()):
		return false
	else:
		reduse_stamina(cost)
		return true

func clear_selection():
	for node in current_selection:
		node.queue_free()
	current_selection.clear()

func select_unit(unit):
	ui.connect("action_changed", self, "_change_action")
	if game._locked_by_unit or unit.cd_start:
		return
	
	self.unit = unit
	ui.buttons.show()
	show_move()
	
func _change_action(action):
	call("show_" + action)

func show_drop():
	_unlock_unit()
	unit._start_cd()

func show_move():
	clear_selection()
	var layer = unit.get_parent()
	for cell in get_possible_moves(unit):
	#for cell in get_nearest_cells(unit.get_tile_pos()):
		#print("adding " + str(cell) + " " + str(unit.get_tile_pos()))
		var s = selection_scene.instance()
		layer.add_child(s)
		s.set_pos(layer.map_to_world(cell) + layer.get_cell_size()*0.5 + Vector2(0,1))
		s.connect("selected", unit, "move", [s.get_pos()])
		s.connect("selected", self, "clear_selection")
		current_selection.append(s)
		
func show_attack():
	clear_selection()
	var max_range = 1.2 * unit._attack_range
	var attacks = []
	var layer = unit.get_parent()
	for u in get_tree().get_nodes_in_group("unit"):
		if u == unit:
			continue
		if u.get_tile_pos().distance_to(unit.get_tile_pos()) <= max_range:
			attacks.append(u.get_tile_pos())
			var s = selection_scene.instance()
			layer.add_child(s)
			s.get_node("sprite").set_modulate(Color("dd2222"))
			s.set_opacity(0.4)
			s.set_pos(layer.map_to_world(u.get_tile_pos()) + layer.get_cell_size()*0.5 + Vector2(0,1))
			s.connect("selected", unit, "attack", [u])
			s.connect("selected", self, "clear_selection")
			current_selection.append(s)



func show_special():
	clear_selection()
	
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
		var cell = layer.get_cell(pos.x, pos.y)
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
			var name = get_tile_name(pos)
			if !name:
				continue
			if name.begins_with("water"):
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
	
