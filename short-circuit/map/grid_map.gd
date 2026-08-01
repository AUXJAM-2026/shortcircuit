extends Node2D

var astar := AStarGrid2D.new()
@onready var map_barrier = $Barrier

func _ready():
	_build_grid_from_tiles()

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

			if tile_data and tile_data.get_collision_polygons_count(0) >= 0:
				astar.set_point_solid(cell, true)

func is_moveable(cell: Vector2i) -> bool:
	return !astar.is_point_solid(cell)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local = map_barrier.to_local(world_pos)
	return map_barrier.local_to_map(local)

func cell_to_world(cell: Vector2i) -> Vector2:
	var local = map_barrier.map_to_local(cell)
	return map_barrier.to_global(local)
