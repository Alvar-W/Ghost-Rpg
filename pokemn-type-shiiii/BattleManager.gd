extends Node
class_name BattleManager

var player_units: Array[BattleUnit] = []
var enemy_units: Array[BattleUnit] = []
var turn_order: Array[BattleUnit] = []
var current_turn_index := 0

func build_player_party(equipped_robot: Array, equipped_spirit: Array):
	player_units.clear()

	for i in range(3):
		var r = equipped_robot[i]
		var s = equipped_spirit[i]
		if r != null and s != null:
			player_units.append(BattleUnit.new(r, s))

func build_enemy_party(spirit_nodes: Array):
	enemy_units.clear()
	for s in spirit_nodes:
		enemy_units.append(BattleUnit.new(null, s.spirit_data))

func roll_initiative():
	turn_order.clear()

	for u in player_units:
		u.initiative = randf() * u.speed
		turn_order.append(u)

	for u in enemy_units:
		u.initiative = randf() * u.speed
		turn_order.append(u)

	# Sort highest initiative first
	turn_order.sort_custom(func(a, b):
		return a.initiative > b.initiative
	)

	current_turn_index = 0

func get_current_unit() -> BattleUnit:
	return turn_order[current_turn_index]

func next_turn():
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0   # later we can re-roll or handle round end
