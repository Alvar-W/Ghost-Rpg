extends Node2D

@export var AreYouSure: Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_load_game_pressed() -> void:
	pass


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_quit_game_pressed() -> void:
	AreYouSure.visible = ! AreYouSure.visible


func _on_confirm_pressed() -> void:
	get_tree().quit()


func _on_cancel_pressed() -> void:
	AreYouSure.visible = ! AreYouSure.visible
