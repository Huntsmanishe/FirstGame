extends Node2D

signal no_health ()
signal damage_received ()

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText
@onready var anim = $AnimationPlayer

var player_dmg

@export var max_health = 100

var health = 100:
	set (value):
		health = value
		health_bar.value = health
		if health <= 0:
			health_bar.visible = false
		else:
			health_bar.visible = true

func _ready():
	Signals.connect("player_attack", Callable(self,"_on_damage_received"))
	damage_text.modulate.a = 0
	health_bar.max_value = max_health
	health = max_health
	health_bar.visible = false

func _on_damage_received(player_damage):
	player_dmg = player_damage
	


func _on_hurt_box_area_entered(_area):
	await get_tree().create_timer(0.01).timeout
	health -= player_dmg
	damage_text.text = str(player_dmg)
	anim.stop()
	anim.play("damage_text")
	if health <= 0:
		emit_signal("no_health")
	else:
		emit_signal("damage_received")
