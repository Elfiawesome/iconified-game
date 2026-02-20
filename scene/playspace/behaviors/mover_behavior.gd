class_name MoverBehavior extends Behavior

var speed: int
var pattern: StringName

func _init(def: Dictionary = {}) -> void:
	speed = def.get("speed", 1)
	pattern = def.get("pattern", &"toward_enemy")

func tick(playspace: Playspace) -> void:
	var target_pos := _find_move_target(playspace)
	if target_pos != entity.grid_pos:
		await playspace.move_entity(entity.grid_pos, target_pos)

func _find_move_target(playspace: Playspace) -> Vector2i:
	match pattern:
		&"toward_enemy":
			var nearest := playspace.find_nearest_enemy(entity)
			if nearest:
				return _step_toward(entity.grid_pos, nearest.grid_pos, playspace)
	return entity.grid_pos


func _step_toward(from: Vector2i, to: Vector2i, playspace: Playspace) -> Vector2i:
	# Simple manhattan step — upgrade to A* if needed
	var diff := to - from
	var step := Vector2i.ZERO
	if abs(diff.x) >= abs(diff.y):
		step = Vector2i(sign(diff.x), 0)
	else:
		step = Vector2i(0, sign(diff.y))
	var candidate := from + step
	if playspace.is_tile_open(candidate):
		return candidate
	return from
