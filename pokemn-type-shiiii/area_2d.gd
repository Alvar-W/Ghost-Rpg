extends Area2D

@export var item_data: ItemData   # <-- make it exported
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	update_visual()

func update_visual():
	if not item_data:
		return
	sprite.texture = item_data.icon
	if collision.shape is RectangleShape2D:
		collision.shape.size = sprite.texture.get_size()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_first_node_in_group("player")
		player.add_item(item_data)
		queue_free()

#testiasiaa gitin takia
