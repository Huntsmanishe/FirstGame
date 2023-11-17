extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(randi_range(-50,50), -150),0.3)
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = 0
		
	move_and_slide()

func _on_area_2d_body_entered(_body):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2(0, -150),0.3)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
	await get_tree().create_timer(0.5).timeout
	queue_free()
