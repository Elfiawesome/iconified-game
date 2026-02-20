class_name PlayEntity extends Node2D

enum Team { PLAYER, VOID, NEUTRAL }

var data: EntityData
var grid_pos: Vector2i
var team: Team = Team.PLAYER
var behaviors: Array[Behavior] = []
var playspace: Playspace

func setup_from_data(entity_data: EntityData, pos: Vector2i, t: Team, ps: Playspace) -> void:
	data = entity_data
	grid_pos = pos
	team = t
	playspace = ps
	position = Vector2(pos) * ps.tile_size

	# Set icon
	$Sprite2D.texture = data.icon

	# Create behaviors
	for def in data.behavior_defs:
		var behavior := BehaviorFactory.create(def)
		if behavior:
			behavior.entity = self
			behaviors.append(behavior)
			behavior.setup(ps.event_bus)

func teardown() -> void:
	for behavior in behaviors:
		behavior.teardown(playspace.event_bus)
	behaviors.clear()

func game_tick(ps: Playspace) -> void:
	for behavior in behaviors:
		if not is_inside_tree():
			break  # Entity died mid-tick
		await behavior.tick(ps)

func get_behavior(type: Variant) -> Behavior:
	for b in behaviors:
		if is_instance_of(b, type):
			return b
	return null

func die() -> void:
	playspace.kill_entity(self)
