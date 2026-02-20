class_name EventBus extends RefCounted

# Tick lifecycle
signal tick_started(tick_number: int)
signal tick_ended(tick_number: int)

# Entity events
signal entity_placed(entity: PlayEntity, pos: Vector2i)
signal entity_moved(entity: PlayEntity, from_pos: Vector2i, to_pos: Vector2i)
signal entity_damaged(target: PlayEntity, amount: int, source: PlayEntity)
signal entity_healed(target: PlayEntity, amount: int, source: PlayEntity)
signal entity_died(entity: PlayEntity, pos: Vector2i)

# Void events
signal void_spread(pos: Vector2i, strength: float)
signal void_cleared(pos: Vector2i)
signal void_threshold_reached()   # board is X% void

# Stage events
signal stage_won()
signal stage_lost()
