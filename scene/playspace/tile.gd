class_name PlayTile extends Node2D

var pos: Vector2i

func _ready() -> void:
	position = pos * 16

var void_strength: float = 0.0:
	set(value):
		void_strength = value
		if void_strength > 0.0:
			modulate = Color(0.6, 0.2, 0.8, 1.0).lerp(Color.WHITE, 1.0 - clampf(void_strength, 0.0, 1.0))
		else:
			modulate = Color.WHITE
