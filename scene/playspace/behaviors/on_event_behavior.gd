class_name OnEventBehavior extends Behavior
# generic "react to event" behavior for data-driven flexibility

var event_name: StringName
var action: StringName
var params: Dictionary

func _init(def: Dictionary = {}) -> void:
	event_name = def.get("event", &"")
	action = def.get("action", &"")
	params = def.get("params", {})

func setup(bus: EventBus) -> void:
	# Dynamically connect to any event by name
	if bus.has_signal(event_name):
		bus.connect(event_name, _on_event)

func teardown(bus: EventBus) -> void:
	if bus.has_signal(event_name) and bus.is_connected(event_name, _on_event):
		bus.disconnect(event_name, _on_event)

func _on_event(args: Array = []) -> void:
	match action:
		&"heal_self":
			var health := entity.get_behavior(HealthBehavior) as HealthBehavior
			if health:
				health.current_hp = min(health.current_hp + params.get("amount", 1), health.max_hp)
		&"buff_nearby":
			pass # etc