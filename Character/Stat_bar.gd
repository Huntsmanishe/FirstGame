extends CanvasLayer

signal no_stamina()

@onready var health_bar = $HealthBar
@onready var stamina_bar = $Stamina
@onready var poisons = $Poisons

var stamina_cost
var attack_cost = 15
var roll_cost = 20
var sprint_cost = 0.5

var poisons_count = 5

var max_stamina = 100
var stamina:
	set(value):
		stamina = clamp(value, 0, max_stamina)
		if stamina < 1:
			emit_signal("no_stamina")
var max_health = 100
var health:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health

func _ready():
	poisons.text = "Healing potions: " + str(poisons_count)
	health = max_health
	stamina = max_stamina
	stamina_bar.max_value = stamina
	health_bar.max_value = health
	health_bar.value = health
	
func _process(delta):
	stamina_bar.value = stamina
	if stamina < 100:
		stamina += 10 * delta
		
func stamina_consuption():
	stamina -= stamina_cost

func heal():
	if poisons_count != 0:
		poisons_count -= 1
		health += 25
		poisons.text = "Healing potions: " + str(poisons_count) 
		
