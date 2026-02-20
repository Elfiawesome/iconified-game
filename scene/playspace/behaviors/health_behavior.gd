class_name HealthBehavior extends Behavior

var max_hp: int
var current_hp: int

func _init(def: Dictionary = {}) -> void:
	max_hp = def.get("max_hp", 1)
	current_hp = max_hp

func setup(bus: EventBus) -> void:
	bus.entity_damaged.connect(_on_entity_damaged)

func teardown(bus: EventBus) -> void:
	bus.entity_damaged.disconnect(_on_entity_damaged)

func _on_entity_damaged(target: PlayEntity, amount: int, _source: PlayEntity) -> void:
	if target != entity:
		return
	current_hp -= amount
	if current_hp <= 0:
		entity.playspace.kill_entity(entity)