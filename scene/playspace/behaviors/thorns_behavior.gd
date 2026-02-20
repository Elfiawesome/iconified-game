class_name ThornsBehavior extends Behavior

var damage: int

func _init(def: Dictionary = {}) -> void:
	damage = def.get("damage", 1)

func setup(bus: EventBus) -> void:
	bus.entity_damaged.connect(_on_entity_damaged)

func teardown(bus: EventBus) -> void:
	bus.entity_damaged.disconnect(_on_entity_damaged)

func _on_entity_damaged(target: PlayEntity, _amount: int, source: PlayEntity) -> void:
	if target != entity:
		return
	if source:
		# Retaliate!
		entity.playspace.event_bus.entity_damaged.emit(source, damage, entity)