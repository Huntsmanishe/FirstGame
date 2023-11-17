extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$HitBox/CollisionShape2D.disabled = true
