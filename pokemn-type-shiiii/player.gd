extends CharacterBody2D

@export var max_speed := 85
@export var acceleration := 850
@export var friction := 850
var last_dir := "up"
@onready var anim := $AnimatedSprite2D
var inventory = []
@export var inventory_ui: Control
@export var slot_count := 60
@export var slot_scene: PackedScene
var selected_item: ItemData = null
var equipped_battle := [null, null, null]
var equipped_robot := [null, null, null]
var selected_slot: Control = null
@export var dropped_item_scene: PackedScene
@export var PauseMenuUI: Control
@export var Opened_Menu: bool = false

func spawn_dropped_item(item: ItemData):
	var drop = dropped_item_scene.instantiate()
	drop.item_data = item
	get_parent().add_child(drop)
	drop.global_position = global_position + get_random_drop_offset()
	drop.update_visual() # <-- FORCE refresh

func get_random_drop_offset() -> Vector2:
	var radius := 12.0
	var angle := randf() * TAU
	return Vector2(cos(angle), sin(angle)) * radius

func _input(event):
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		Opened_Menu = !Opened_Menu
	if event.is_action_pressed("ui_cancel"):
		PauseMenuUI.visible = !PauseMenuUI.visible
		Opened_Menu = !Opened_Menu

func show_item_details(item: ItemData, slot):
	selected_item = item
	selected_slot = slot

	var ui = inventory_ui
	ui.get_node("SelectedIcon").texture = item.icon
	ui.get_node("SelectedName").text = item.name
	ui.get_node("DescriptionLabel").text = item.description

	var equip_btn = ui.get_node("VBoxContainer/EquipButton")
	var consume_btn = ui.get_node("VBoxContainer/ConsumeButton")
	var unequip_btn = ui.get_node("VBoxContainer/UnequipButton")


	# Hide all first
	equip_btn.visible = false
	consume_btn.visible = false
	unequip_btn.visible = false

	if slot.slot_type == "inventory":
		if item.item_type == "battle_item" or item.item_type == "robot":
			equip_btn.visible = true
		elif item.item_type == "consumable":
			consume_btn.visible = true

	elif slot.slot_type == "battle" or slot.slot_type == "robot":
		unequip_btn.visible = true



func _on_inventory_slot_clicked(item: ItemData, slot):
	selected_item = item
	print("Selected:", item.name)
	show_right_panel()
	show_item_details(item, slot)

func create_inventory_slots():
	var grid = inventory_ui.get_node("ScrollContainer/GridContainer")
	for c in grid.get_children():
		c.queue_free()
	grid.columns = 5
	for i in range(slot_count):
		var slot = slot_scene.instantiate()
		slot.slot_clicked.connect(_on_inventory_slot_clicked)
		grid.add_child(slot)

func hide_right_panel():
	inventory_ui.get_node("SelectedIcon").visible = false
	inventory_ui.get_node("SelectedName").visible = false
	inventory_ui.get_node("DescriptionLabel").visible = false
	inventory_ui.get_node("VBoxContainer").visible = false
	
func show_right_panel():
	inventory_ui.get_node("SelectedIcon").visible = true
	inventory_ui.get_node("SelectedName").visible = true
	inventory_ui.get_node("DescriptionLabel").visible = true
	inventory_ui.get_node("VBoxContainer").visible = true


func _ready():
	add_to_group("player")
	#get_tree().get_root().print_tree_pretty()
	create_inventory_slots()
	for i in range(1, 10):
		var slot = inventory_ui.get_node("Slot" + str(i))
		slot.slot_clicked.connect(_on_inventory_slot_clicked)
	hide_right_panel()

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	if not Opened_Menu:
		if Input.is_key_pressed(KEY_D):
			input_dir.x += 1
		if Input.is_key_pressed(KEY_A):
			input_dir.x -= 1
		if Input.is_key_pressed(KEY_S):
			input_dir.y += 1
		if Input.is_key_pressed(KEY_W):
			input_dir.y -= 1

		if input_dir != Vector2.ZERO:
			if input_dir.y > 0:
				if input_dir.x < 0:
					last_dir = "down_left"
				elif input_dir.x > 0:
					last_dir = "down_right"
				else:
					last_dir = "down"
			elif input_dir.y < 0:
				if input_dir.x < 0:
					last_dir = "up_left"
				elif input_dir.x > 0:
					last_dir = "up_right"
				else:
					last_dir = "up"
			elif input_dir.x < 0:
				last_dir = "left"
			else:
				last_dir = "right"

	if input_dir == Vector2.ZERO:
		anim.play("idle_" + last_dir)
	else:
		anim.play("idle_" + last_dir)

	input_dir = input_dir.normalized()

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

func update_inventory_ui(filter_category: String):
	var grid = inventory_ui.get_node("ScrollContainer/GridContainer")

	for slot in grid.get_children():
		slot.get_node("Icon").texture = null
		slot.item_data = null

	var index := 0
	for item in inventory:
		if filter_category == "all" or item.category == filter_category:
			if index < grid.get_child_count():
				var slot = grid.get_child(index)
				slot.get_node("Icon").texture = item.icon
				slot.item_data = item
				index += 1

func sort_inventory_by_tag():
	inventory.sort_custom(func(a, b):
		return a.sort_tag < b.sort_tag
	)
	update_inventory_ui("all")

func add_item(data: ItemData):
	inventory.append(data)
	update_inventory_ui("all")
	
func remove_from_inventory(item: ItemData):
	inventory.erase(item)
	update_inventory_ui("all")

	
func equip_to_battle_slot(item: ItemData):
	for i in range(3):
		if equipped_battle[i] == null:
			equipped_battle[i] = item

			var slot = inventory_ui.get_node("Slot" + str(i + 7))
			slot.item_data = item
			slot.get_node("Icon").texture = item.icon

			remove_from_inventory(item)
			hide_right_panel()
			return

func equip_to_robot_slot(item: ItemData):
	for i in range(3):
		if equipped_robot[i] == null:
			equipped_robot[i] = item

			var slot = inventory_ui.get_node("Slot" + str(i + 4))
			slot.item_data = item
			slot.get_node("Icon").texture = item.icon

			remove_from_inventory(item)
			hide_right_panel()
			return
	
	print("No free robot slots")


func _on_tab_all_pressed() -> void:
	update_inventory_ui("all")

func _on_tab_robot_parts_pressed() -> void:
	update_inventory_ui("robot_parts")


func _on_tab_scrolls_pressed() -> void:
	update_inventory_ui("scrolls")


func _on_item_sort_pressed() -> void:
	sort_inventory_by_tag()


func _on_equip_button_pressed() -> void:
	if not selected_item:
		return

	if selected_item.item_type == "battle_item":
		equip_to_battle_slot(selected_item)
	elif selected_item.item_type == "robot":
		equip_to_robot_slot(selected_item)
	hide_right_panel()



func _on_consume_button_pressed() -> void:
	if selected_item and selected_item.item_type == "consumable":
		print("Consumed:", selected_item.name)
		inventory.erase(selected_item)
		update_inventory_ui("all")
	hide_right_panel()



func _on_drop_button_pressed() -> void:
	if not selected_item:
		return
	
	# If coming from an equipped slot
	if selected_slot and (selected_slot.slot_type == "battle" or selected_slot.slot_type == "robot"):
		# Clear from correct array
		if selected_slot.slot_type == "battle":
			for i in range(equipped_battle.size()):
				if equipped_battle[i] == selected_item:
					equipped_battle[i] = null
		elif selected_slot.slot_type == "robot":
			for i in range(equipped_robot.size()):
				if equipped_robot[i] == selected_item:
					equipped_robot[i] = null
		
		# Clear the slot visuals
		selected_slot.item_data = null
		selected_slot.get_node("Icon").texture = null
	
	else:
		# From normal inventory
		inventory.erase(selected_item)
		update_inventory_ui("all")
	
	# Spawn in world
	spawn_dropped_item(selected_item)
	hide_right_panel()




func _on_destroy_button_pressed() -> void:
	if selected_item:
		print("Destroyed:", selected_item.name)
		inventory.erase(selected_item)
		update_inventory_ui("all")
	hide_right_panel()


func _on_unequip_button_pressed() -> void:
	if not selected_item or not selected_slot:
		return

	# Figure out which equipped array & index this slot belongs to
	var slot_name := selected_slot.name   # "Slot4", "Slot7", etc
	var slot_index := int(slot_name.replace("Slot", "")) - 1

	if selected_slot.slot_type == "robot":
		# Robot slots are Slot4,5,6 → indexes 0,1,2
		equipped_robot[slot_index - 3] = null
	elif selected_slot.slot_type == "battle":
		# Battle slots are Slot7,8,9 → indexes 0,1,2
		equipped_battle[slot_index - 6] = null

	# Clear the slot visually
	selected_slot.item_data = null
	selected_slot.get_node("Icon").texture = null

	# Put back in inventory
	inventory.append(selected_item)
	update_inventory_ui("all")

	hide_right_panel()


func _on_continue_button_pressed() -> void:
	PauseMenuUI.visible = !PauseMenuUI.visible
	Opened_Menu = !Opened_Menu


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_save_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_game_button_pressed() -> void:
	pass # Replace with function body.
