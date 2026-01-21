extends Node2D
@export var player_animation: AnimatedSprite2D
@onready var player := get_tree().get_first_node_in_group("player")
var battle_units = []


func _ready() -> void:
	player.play("idle_up_right")
	battle_units = player.get_battle_units()
	spawn_battle_units()

func spawn_battle_units():
	for unit in battle_units:
		var robot_data = unit.robot
		var spirit_data = unit.spirit

		var final_stats = {
			"hp": robot_data.hp + spirit_data.hp_mod,
			"speed": robot_data.speed + spirit_data.speed_mod,
			"defense": robot_data.defense,
			"damage_mult": spirit_data.damage_mod,
			"element": spirit_data.element,
			"accuracy": spirit_data.accuracy,
			"special_attacks": spirit_data.special_attacks
		}

		#spawn_robot_visual(robot_data, final_stats)
		print("Battle Unit:", robot_data.name, "+", spirit_data.name)
		print("Final Stats:", final_stats)
