extends Node

var is_paused := false
var current_menu := ""

func pause_game():
	get_tree().paused = true
	is_paused = true

func resume_game():
	get_tree().paused = false
	is_paused = false

func change_scene(path: String):
	resume_game()
	get_tree().change_scene_to_file(path)

func quit_game():
	get_tree().quit()
