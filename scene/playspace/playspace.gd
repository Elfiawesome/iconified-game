class_name Playspace extends Node2D

const TILE = preload("res://scene/playspace/tile.tscn")
const ENTITY = preload("res://scene/playspace/entity.tscn")

var event_bus: EventBus = EventBus.new()
var tiles: Dictionary[Vector2i, PlayTile] = {}
var entities: Dictionary[Vector2i, PlayEntity] = {}

func _ready() -> void:
	for x in 15:
		for y in 15:
			create_tile(Vector2i(x, y))

func create_tile(coords: Vector2i) -> void:
	if tiles.has(coords): return
	var tile: PlayTile = TILE.instantiate()
	tile.pos = coords
	tiles[coords] = tile
	$Tiles.add_child(tile)

func remove_tile(coords: Vector2i) -> void:
	if !tiles.has(coords): return
	var tile := tiles[coords]
	$Tiles.remove_child(tile)

func move_entity(pos_1: Vector2i, pos_2: Vector2i) -> void:
	pass

func game_tick(playspace: Playspace) -> void:
	for pos in entities:
		var entity := entities[pos]
		entity.game_tick(playspace)
