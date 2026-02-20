class_name VoidAuraBehavior extends Behavior

var radius: int
var strength: float

func _init(def: Dictionary = {}) -> void:
	radius = def.get("radius", 2)
	strength = def.get("strength", 1.0)
