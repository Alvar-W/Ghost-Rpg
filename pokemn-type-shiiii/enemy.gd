@tool
extends Area2D

@export var spirit_data: SpiritData
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	update_visual()

func update_visual():
	if not spirit_data or not spirit_data.sprite_frames:
		return

	anim.sprite_frames = spirit_data.sprite_frames
	anim.play("idle")

	var tex := anim.sprite_frames.get_frame_texture("idle", anim.frame)
	if tex and collision.shape is RectangleShape2D:
		collision.shape.size = tex.get_size() * anim.scale



func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_first_node_in_group("player")
		player.add_item(spirit_data)
		queue_free()
