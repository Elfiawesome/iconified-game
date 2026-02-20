class_name AttackerBehavior extends Behavior

var damage: int
var attack_range: int

func _init(def: Dictionary = {}) -> void:
	damage = def.get("damage", 1)
	attack_range = def.get("range", 1)

func tick(playspace: Playspace) -> void:
	var target := playspace.find_nearest_enemy_in_range(entity, attack_range)
	if target:
		await playspace.animate_attack(entity, target)
		playspace.event_bus.entity_damaged.emit(target, damage, entity)
