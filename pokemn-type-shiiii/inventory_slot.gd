extends Control

@export var slot_type: String = "inventory" 
# possible values later: "inventory", "battle", "robot"

var item_data: ItemData = null
signal slot_clicked(item, slot)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item_data != null:
			emit_signal("slot_clicked", item_data, self)
