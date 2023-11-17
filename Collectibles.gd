extends Node2D

var coin_preload = preload("res://Collectibles/coin.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("enemy_died", Callable(self, "_on_enemy_died"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_enemy_died (enemy_position):
	coin_spawn(enemy_position)

func coin_spawn (res):
	var coin = coin_preload.instantiate()
	coin.position = res
	get_tree().current_scene.add_child(coin)
