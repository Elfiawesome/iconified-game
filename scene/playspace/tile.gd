class_name PlayTile extends Node2D

var pos: Vector2i

func _ready() -> void:
	position = pos * 16
