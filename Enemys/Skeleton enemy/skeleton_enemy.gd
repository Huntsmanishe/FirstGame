extends CharacterBody2D

enum{
	IDLE,
	ATTACK,
	CHASE,
	DEATH,
	DAMAGE,
}
var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DEATH:
				death_state()
			DAMAGE:
				damage_state()

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var SPEED = 25.0
@onready var anim = $AnimatedSprite2D
@onready var animMob = $AnimationPlayer
var alive = true
var attacking = false
var damage = 20

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()

	if alive == true:
		if attacking:
			# Если атака активирована, прекратите движение.
			velocity.x = 0
			animMob.play("Attack")
		elif chase == true:
			velocity.x = direction.x * SPEED
			animMob.play("Walk")
		else:
			velocity.x = 0
			animMob.play("Idle")
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif direction.x > 0:
			$AnimatedSprite2D.flip_h = false
	move_and_slide()

func _on_detector_body_entered(_body):
	chase = true

func _on_area_2d_body_exited(_body):
	chase = false

func _on_attack_zone_body_entered(_body):
	state = ATTACK
	
func idle_state():
	animMob.play("Idle")
	await get_tree().create_timer(1).timeout
	$Attack/AttackZone/CollisionShape2D.disabled = false
	
func attack_state():
	if not attacking:
		if alive == true:
			attacking = true
			animMob.play("Attack")
			await animMob.animation_finished
			attacking = false
			$Attack/AttackZone/CollisionShape2D.disabled = true
			
			state = IDLE

func damage_state():
	velocity.x = 0
	animMob.play("Hit")
	await animMob.animation_finished
	state = IDLE
	
func death_state():
#	Signals.emit_signal("enemy_died", position)
	alive = false
	velocity.x = 0
	animMob.play("Death")
	await animMob.animation_finished
	queue_free()

func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage)
	
func _on_mobe_health_no_health():
	state = DEATH
	
func _on_mobe_health_damage_received():
	state = IDLE
	state = DAMAGE
