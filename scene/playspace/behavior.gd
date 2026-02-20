class_name Behavior extends RefCounted

var entity: PlayEntity

## Called when entity enters the board — subscribe to events here
func setup(bus: EventBus) -> void:
	pass

## Called when entity leaves the board — unsubscribe here
func teardown(bus: EventBus) -> void:
	pass

## Called each game tick — return actions or act directly
func tick(playspace: Playspace) -> void:
	pass