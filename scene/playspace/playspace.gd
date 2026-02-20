class_name Playspace extends Node2D

const TILE_SCN: PackedScene = preload("res://scene/playspace/tile.tscn")
const ENTITY_SCN: PackedScene = preload("res://scene/playspace/entity.tscn")

@export var board_size: Vector2i = Vector2i(8, 8)  # 8x8 is snappier than 15x15

var tile_size: int = 16
var event_bus: EventBus = EventBus.new()
var tiles: Dictionary[Vector2i, PlayTile] = {}
var entities: Dictionary[Vector2i, PlayEntity] = {}
var void_tiles: Dictionary[Vector2i, float] = {}  # pos → void strength

var current_tick: int = 0
var animation_speed: float = 1.0  # 0.0 = instant, 1.0 = normal, 3.0 = fast
var is_running: bool = false

func _ready() -> void:
	for x in board_size.x:
		for y in board_size.y:
			create_tile(Vector2i(x, y))
	
	
	for i in 5:
		var d := EntityData.new()
		d.icon = load("res://asset/item/1_2.png")
		d.behavior_defs.push_back({"type": "mover", "speed": 1, "pattern": "toward_enemy"})
		#d.behavior_defs.push_back({"type": "attacker", "damage": 2, "range": 1})
		d.behavior_defs.push_back({"type": "health", "max_hp": 999})
		spawn_entity(d, Vector2i(i,0), PlayEntity.Team.PLAYER)
	
	for i in 5:
		var d := EntityData.new()
		d.icon = load("res://asset/item/1_3.png")
		d.behavior_defs.push_back({"type": "mover", "speed": 1, "pattern": "toward_enemy"})
		d.behavior_defs.push_back({"type": "attacker", "damage": 2, "range": 1})
		d.behavior_defs.push_back({"type": "health", "max_hp": 3})
		spawn_entity(d, Vector2i(i,5), PlayEntity.Team.VOID)
	
	run_battle()


# ── Tile Management ──────────────────────────────────

func create_tile(coords: Vector2i) -> void:
	if tiles.has(coords):
		return
	var tile: PlayTile = TILE_SCN.instantiate()
	tile.pos = coords
	tiles[coords] = tile
	$Tiles.add_child(tile)

# ── Entity Management ────────────────────────────────

func spawn_entity(entity_data: EntityData, pos: Vector2i, team: PlayEntity.Team) -> PlayEntity:
	if entities.has(pos):
		return null
	var entity: PlayEntity = ENTITY_SCN.instantiate()
	entities[pos] = entity
	$Entities.add_child(entity)
	entity.setup_from_data(entity_data, pos, team, self)
	event_bus.entity_placed.emit(entity, pos)
	return entity

func kill_entity(entity: PlayEntity) -> void:
	var pos := entity.grid_pos
	entities.erase(pos)
	event_bus.entity_died.emit(entity, pos)
	await animate_death(entity)
	entity.teardown()
	entity.queue_free()
	_check_win_condition()

func move_entity(from: Vector2i, to: Vector2i) -> void:
	if not entities.has(from):
		return
	if entities.has(to):
		return  # Occupied
	var entity := entities[from]
	entities.erase(from)
	entities[to] = entity
	entity.grid_pos = to
	await animate_move(entity, from, to)
	event_bus.entity_moved.emit(entity, from, to)

# ── Queries (used by behaviors) ──────────────────────

func is_tile_open(pos: Vector2i) -> bool:
	return tiles.has(pos) and not entities.has(pos)

func find_nearest_enemy(of: PlayEntity) -> PlayEntity:
	var best: PlayEntity = null
	var best_dist: int = 999999
	for pos in entities:
		var other := entities[pos]
		if other.team == of.team:
			continue
		var dist := _manhattan(of.grid_pos, pos)
		if dist < best_dist:
			best_dist = dist
			best = other
	return best

func find_nearest_enemy_in_range(of: PlayEntity, attack_range: int) -> PlayEntity:
	var best: PlayEntity = null
	var best_dist: int = 999999
	for pos in entities:
		var other := entities[pos]
		if other.team == of.team:
			continue
		var dist := _manhattan(of.grid_pos, pos)
		if dist <= attack_range and dist < best_dist:
			best_dist = dist
			best = other
	return best

func get_entities_in_radius(center: Vector2i, radius: int) -> Array[PlayEntity]:
	var result: Array[PlayEntity] = []
	for pos in entities:
		if _manhattan(center, pos) <= radius:
			result.append(entities[pos])
	return result

func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

# ── Game Tick ────────────────────────────────────────

func run_battle() -> void:
	is_running = true
	while is_running:
		await process_tick()
		if _check_win_condition():
			break
	is_running = false

func process_tick() -> void:
	current_tick += 1
	event_bus.tick_started.emit(current_tick)

	# Process in position order (top-left to bottom-right) for determinism
	var ordered_positions: Array[Vector2i] = entities.keys()
	ordered_positions.sort()

	for pos in ordered_positions:
		if not entities.has(pos):
			continue  # Entity may have died this tick
		var entity := entities[pos]
		await entity.game_tick(self)

	_spread_void()
	event_bus.tick_ended.emit(current_tick)

func _check_win_condition() -> bool:
	var void_count: int = 0
	var player_count: int = 0
	for pos in entities:
		match entities[pos].team:
			PlayEntity.Team.VOID: void_count += 1
			PlayEntity.Team.PLAYER: player_count += 1

	if void_count == 0:
		event_bus.stage_won.emit()
		is_running = false
		return true

	if player_count == 0:
		event_bus.stage_lost.emit()
		is_running = false
		return true

	return false

# ── Void ─────────────────────────────────────────────

func _spread_void() -> void:
	# Void entities emit void to nearby tiles
	for pos in entities:
		var entity := entities[pos]
		var void_aura := entity.get_behavior(VoidAuraBehavior)
		if void_aura:
			for dx in range(-void_aura.radius, void_aura.radius + 1):
				for dy in range(-void_aura.radius, void_aura.radius + 1):
					var vpos := pos + Vector2i(dx, dy)
					if tiles.has(vpos):
						void_tiles[vpos] = void_aura.strength
						event_bus.void_spread.emit(vpos, void_aura.strength)

	# Damage player entities standing on void tiles
	for pos in void_tiles:
		if entities.has(pos):
			var entity := entities[pos]
			if entity.team == PlayEntity.Team.PLAYER:
				event_bus.entity_damaged.emit(entity, 1, null)

# ── Animation ────────────────────────────────────────

func animate_move(entity: PlayEntity, from: Vector2i, to: Vector2i) -> void:
	var target_pos := Vector2(to) * tile_size
	if animation_speed <= 0.0:
		entity.position = target_pos
		return
	var tween := create_tween()
	tween.tween_property(entity, "position", target_pos, 0.25 / animation_speed)
	await tween.finished

func animate_attack(attacker: PlayEntity, target: PlayEntity) -> void:
	if animation_speed <= 0.0:
		return
	var original := attacker.position
	var lunge_pos := original + (target.position - original).normalized() * 4.0
	var tween := create_tween()
	tween.tween_property(attacker, "position", lunge_pos, 0.1 / animation_speed)
	tween.tween_property(attacker, "position", original, 0.1 / animation_speed)
	# Flash target
	tween.parallel().tween_property(target, "modulate", Color.RED, 0.1 / animation_speed)
	tween.tween_property(target, "modulate", Color.WHITE, 0.1 / animation_speed)
	await tween.finished

func animate_death(entity: PlayEntity) -> void:
	if animation_speed <= 0.0:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(entity, "modulate:a", 0.0, 0.3 / animation_speed)
	tween.tween_property(entity, "scale", Vector2.ZERO, 0.3 / animation_speed)
	await tween.finished
