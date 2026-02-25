extends Node2D

@onready var player_slots = $CanvasLayer/Panel/PlayerSlots.get_children()
@onready var enemy_slots = $CanvasLayer/Panel/EnemySlots.get_children()

func _ready():
	var bm = get_node("/root/Battlemanager")

	# Player units
	for i in range(player_slots.size()):
		if i < bm.player_units.size():
			fill_slot(player_slots[i], bm.player_units[i])
		else:
			clear_slot(player_slots[i])

	# Enemy units (only first one for now)
	for i in range(enemy_slots.size()):
		if i < bm.enemy_units.size():
			fill_enemy_slot(enemy_slots[i], bm.enemy_units[i])
		else:
			clear_slot(enemy_slots[i])


func fill_slot(slot: VBoxContainer, unit: BattleUnit):
	var name_label: Label = slot.get_node("Label")
	var hp_bar: ProgressBar = slot.get_node("ProgressBar")
	var icon: TextureRect = slot.get_node("TextureRect")

	name_label.text = unit.spirit.name

	hp_bar.max_value = unit.max_hp
	hp_bar.value = unit.current_hp
	hp_bar.show_percentage = false
	hp_bar.visible = true

	setup_hp_bar(hp_bar, unit.max_hp, unit.current_hp)

	icon.texture = unit.spirit.icon
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED



func fill_enemy_slot(slot: VBoxContainer, unit: BattleUnit):
	var name_label: Label = slot.get_node("Label")
	var hp_bar: ProgressBar = slot.get_node("ProgressBar")
	var icon: TextureRect = slot.get_node("TextureRect")

	name_label.text = unit.spirit.name

	hp_bar.max_value = unit.max_hp
	hp_bar.value = unit.current_hp
	hp_bar.show_percentage = false
	hp_bar.visible = true

	setup_hp_bar(hp_bar, unit.max_hp, unit.current_hp)

	icon.texture = unit.spirit.icon
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func clear_slot(slot: VBoxContainer):
	slot.get_node("Label").text = ""
	slot.get_node("ProgressBar").visible = false
	slot.get_node("TextureRect").texture = null


func setup_hp_bar(hp_bar: ProgressBar, max_hp: int, current_hp: int):
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_bar.show_percentage = false
	hp_bar.visible = true
	hp_bar.custom_minimum_size = Vector2(100, 15) # width, height


	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.1, 0.9, 0.1)
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	fill.content_margin_top = 0
	fill.content_margin_bottom = 0

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.15, 0.15, 0.15)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	bg.content_margin_top = 0
	bg.content_margin_bottom = 0


	hp_bar.add_theme_stylebox_override("fill", fill)
	hp_bar.add_theme_stylebox_override("background", bg)
