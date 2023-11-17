extends Node

@onready var pouse_menu = $"../CanvasLayer/PouseMenu"

var game_paused: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
	
	if game_paused == true:
		get_tree().paused = true
		pouse_menu.show()
	else:
		get_tree().paused = false
		pouse_menu.hide()


func _on_resume_pressed():
	game_paused = !game_paused
	
func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
