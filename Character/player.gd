extends CharacterBody2D

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
var damage_basic = 20
var damage_multiplier = 1
var damage_current
var recovery = false
var heal_recov = false

@onready var anim = $AnimatedSprite2D
@onready var animPlayer =$AnimationPlayer
@onready var stats = $Stats

func _ready():
	Signals.connect("enemy_attack", Callable(self,"_on_damage_received"))

func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
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
	if Input.is_action_just_pressed("Jump") and is_on_floor() and state != ROLL:
		velocity.y = JUMP_VELOCITY
		animPlayer.play("Jump")
		
	if velocity.y > 0 and not is_on_floor():
		animPlayer.play("Fall")
		
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
		
	if Input.is_action_pressed("Sprint") and recovery == false:
		stats.stamina_cost = stats.sprint_cost
		if stats.stamina_cost < stats.stamina and velocity.x != 0:
			stats.stamina -= stats.sprint_cost
			sprint = 1.6
	else:
		sprint = 1
	if velocity.x != 0:
		if Input.is_action_just_pressed("Roll") and recovery == false and is_on_floor():
			stats.stamina_cost = stats.roll_cost
			if stats.stamina_cost < stats.stamina:
				state = ROLL
	if Input.is_action_just_pressed("Attack") and recovery == false:
		stats.stamina_cost = stats.attack_cost
		if stats.stamina_cost < stats.stamina:
			velocity.x = 0
			state = ATTACK
	
	if Input.is_action_just_pressed("Heal") and heal_recov == false and stats.poisons_count:
		stats.heal()
		heal_recov = true
		await get_tree().create_timer(15).timeout
		heal_recov = false


func roll_state():
	if $AnimatedSprite2D.flip_h == true:
		velocity.x -= 3
	else:
		velocity.x += 3
	animPlayer.play("Roll")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("Attack") and combo == true and stats.stamina_cost < stats.stamina:
		state = ATTACK2
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	
	state = MOVE
	
func attack2_state():
	damage_multiplier = 1.7
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
	animPlayer.play("Hit")
	await animPlayer.animation_finished
	state = MOVE

func _on_damage_received(enemy_damage):
	if state == ROLL:
		enemy_damage = 0
	else:
		state = DAMAGE
		damage_anim()
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH
	
	

func _on_hit_box_area_entered(_area):
	Signals.emit_signal("player_attack", damage_current)



func _on_stats_no_stamina():
	recovery = true
	await get_tree().create_timer(3).timeout
	recovery = false

func damage_anim():
	velocity.x = 0
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.1)
