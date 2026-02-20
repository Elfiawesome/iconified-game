extends Node

var entities: Dictionary[StringName, EntityData] = {}

func _ready() -> void:
	_register_all()

func _register_all() -> void:
	var cat := EntityData.new()
	cat.id = &"cat"
	cat.display_name = "Cat"
	cat.icon = preload("res://asset/item/1_1.png")
	cat.behavior_defs = [
		{"type": &"health", "max_hp": 3},
		{"type": &"mover", "speed": 1, "pattern": &"toward_enemy"},
		{"type": &"attacker", "damage": 1, "range": 1},
	]
	entities[cat.id] = cat

	var cactus := EntityData.new()
	cactus.id = &"cactus"
	cactus.display_name = "Cactus"
	cat.icon = preload("res://asset/item/1_4.png")
	cactus.behavior_defs = [
		{"type": &"health", "max_hp": 6},
		{"type": &"blocker"},
		{"type": &"thorns", "damage": 1},
	]
	entities[cactus.id] = cactus