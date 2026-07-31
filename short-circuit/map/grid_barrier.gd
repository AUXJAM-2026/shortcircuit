extends TileMapLayer

var astar := AStarGrid2D.new()

func _build_grid_from_tiles() -> void:
	astar = AStarGrid2D.new()

	var used_rect: Rect2i = get_used_rect()
	astar.region = used_rect
	astar.cell_size = Vector2i(tile_set.tile_size)   # 16x16 in your case
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for x in used_rect.size.x:
		for y in used_rect.size.y:
			var cell: Vector2i = used_rect.position + Vector2i(x, y)

			var tile_data: TileData = get_cell_tile_data(cell)

			if tile_data and tile_data.get_collision_polygons_count(0) >= 0:
				astar.set_point_solid(cell, true)

func is_moveable(cell: Vector2i) -> bool:
	return !astar.is_point_solid(cell)
