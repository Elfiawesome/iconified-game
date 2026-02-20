class_name BehaviorFactory extends RefCounted

static func create(def: Dictionary) -> Behavior:
	var type: StringName = def.get("type", &"")
	match type:
		&"health":		return HealthBehavior.new(def)
		&"mover":		return MoverBehavior.new(def)
		&"attacker":	return AttackerBehavior.new(def)
		#&"blocker":		return BlockerBehavior.new(def)
		&"thorns":		return ThornsBehavior.new(def)
		&"void_aura":	return VoidAuraBehavior.new(def)
		#&"healer":		return HealerBehavior.new(def)
		#&"spawner":		return SpawnerBehavior.new(def)
		&"on_event":	return OnEventBehavior.new(def)
	push_warning("Unknown behavior type: %s" % type)
	return null
