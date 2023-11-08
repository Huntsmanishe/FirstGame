extends CharacterBody2D

signal health_changed(new_health)

enum{
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK_COMBO,
	BLOCK,
	ROLL,
	DAMAGE,
	DEATH
}

var SPEED = 100.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state = MOVE
var sprint = 1
var combo = false
var max_health = 100
var health 
var damage_basic = 20
var damage_multiplier = 1
var damage_current
@onready var anim = $AnimatedSprite2D
@onready var animPlayer =$AnimationPlayer

func _ready():
	Signals.connect("enemy_attack", Callable(self,"_on_damage_received"))
	health = max_health
func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK_COMBO:
			pass
		BLOCK:
			pass
		ROLL:
			roll_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	damage_current = damage_basic * damage_multiplier
	
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animPlayer.play("Jump")
		
	if velocity.y > 0:
		anim.play("fall")
		
	move_and_slide()


func move_state():
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED * sprint
		if velocity.y == 0:
			if sprint == 1:
				animPlayer.play("Run")
			else:
				animPlayer.play("Sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		$DamageBox.rotation_degrees = 180
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
		$DamageBox.rotation_degrees = 0
		
	if Input.is_action_pressed("Sprint"):
		sprint = 2
	else:
		sprint = 1
	if velocity.x != 0:
		if Input.is_action_just_pressed("Roll"):
			state = ROLL
	if Input.is_action_just_pressed("Attack"):
		velocity.x = 0
		state = ATTACK


func roll_state():
	animPlayer.play("Roll")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = ATTACK2
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	
	state = MOVE
	
func attack2_state():
	damage_multiplier = 0.7
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = MOVE

func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false

func death_state():
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	get_tree().change_scene_to_file("res://menu.tscn")
	
func damage_state():
	velocity.x = 0
	animPlayer.play("Hit")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_received(enemy_damage):
	if state == ROLL:
		enemy_damage = 0
	else:
		state = DAMAGE
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH
	
	emit_signal("health_changed", health)
	

func _on_hit_box_area_entered(area):
	Signals.emit_signal("player_attack", damage_current)
