extends Node2D

var map_data: Dictionary[Vector2i, Dictionary] = {}
var _animating_tile_count: int = 0

func _ready() -> void:
	var tiles_to_spawn: Array[Vector2i] = []
	for x in 20:
		for y in 20:
			tiles_to_spawn.append(Vector2i(x, y))
	
	spawn_tiles_animated(tiles_to_spawn)

func _draw() -> void:
	for grid_pos in map_data:
		var tile := map_data[grid_pos]
		
		var draw_pos: Vector2 = (Vector2(grid_pos) * TextureManager.CELL_SIZE) + tile["visual_offset"]
		
		var color := Color(1, 1, 1, tile["alpha"])
		
		draw_texture(TextureManager.TILES[tile["id"]], draw_pos, color)

func _process(_delta: float) -> void:
	if _animating_tile_count > 0:
		queue_redraw()
		print("redraw")

func spawn_tiles_animated(coords: Array[Vector2i]) -> void:
	var stagger_delay := 0.01
	
	for i in coords.size():
		var grid_pos := coords[i]
		
		map_data[grid_pos] = {
			"id": "1", 
			"visual_offset": Vector2(0,0),
			"alpha": 0.0
		}
		
		_animate_single_tile_entry(grid_pos, i * stagger_delay)

func _animate_single_tile_entry(grid_pos: Vector2i, start_delay: float) -> void:
	var tween := create_tween()
	
	_animating_tile_count += 1
	
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_method(
		func(val: Vector2)->void: map_data[grid_pos]["visual_offset"] = val,
		Vector2(randi_range(-4,4), 32),
		Vector2.ZERO,
		0.4
	).set_delay(start_delay)
	
	tween.tween_method(
		func(val: Vector2)->void: map_data[grid_pos]["visual_scale"] = val,
		Vector2.ZERO,
		Vector2(1,1),
		0.4
	).set_delay(start_delay)
	
	tween.tween_method(
		func(val: float)->void: map_data[grid_pos]["alpha"] = val,
		0.0,
		1.0,
		0.3
	).set_delay(start_delay)
	
	tween.set_parallel(false)
	tween.tween_callback(func()->void:
		_animating_tile_count -= 1
		# One final redraw to ensure pixel perfection after tween ends
		queue_redraw() 
	)
