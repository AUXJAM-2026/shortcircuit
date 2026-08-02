extends Node2D

var astar := AStarGrid2D.new()
@onready var map_barrier = $Barrier
@onready var map_wire = $Wire
@onready var map_plugs = $Plugs
@onready var map_sockets = $Sockets
@onready var map_charger = $Boost

@onready var map_obstacle = $Obstacle

@export var max_charges := 3
@export var max_wire_length := 5

@export var spawn_cell:= Vector2i(0, 0)

var switches = []

func _ready():
	_build_grid_from_tiles()
	switches = get_tree().get_nodes_in_group("switches") 

func _build_grid_from_tiles() -> void:
	astar = AStarGrid2D.new()

	var used_rect: Rect2i = map_barrier.get_used_rect()
	
	astar.region = used_rect
	astar.cell_size = Vector2i(map_barrier.tile_set.tile_size)   # 16x16 in your case
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for x in used_rect.size.x:
		for y in used_rect.size.y:
			var cell: Vector2i = used_rect.position + Vector2i(x, y)

			var tile_data: TileData = map_barrier.get_cell_tile_data(cell)
			var tile_data_obst: TileData = map_obstacle.get_cell_tile_data(cell)

			if tile_data or tile_data_obst:
				astar.set_point_solid(cell, true)

func is_moveable(cell: Vector2i) -> bool:
	return !astar.is_point_solid(cell)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local = map_barrier.to_local(world_pos)
	return map_barrier.local_to_map(local)

func cell_to_world(cell: Vector2i) -> Vector2:
	var local = map_barrier.map_to_local(cell)
	return map_barrier.to_global(local)

func update_wire(wire_path: Array[Vector2i]) -> void:
	map_wire.clear()
	map_plugs.clear()
	map_wire.set_cells_terrain_path(wire_path, 0, 0)
	if wire_path.size() > 1:
		map_plugs.set_cell(wire_path[0], 1, Vector2i(0, 1))
	return

func is_plugged(wire_path: Array[Vector2i]) -> bool:
	if wire_path.size() > 0:
		var socket_list = map_sockets.get_used_cells()
		return socket_list.has(wire_path[0])
	else:
		return true

func is_on_charger(cell: Vector2i) -> bool:
	var charger_list = map_charger.get_used_cells()
	return charger_list.has(cell)

func get_max_charges() -> int:
	return max_charges

func get_max_wire_length() -> int:
	return max_wire_length

func get_spawn_cell() -> Vector2i:
	return spawn_cell
	
func check_switches(player_cell: Vector2i):
	for switch in switches:
		if switch.switch_pos == player_cell:
			switch.activate()
			_build_grid_from_tiles()
