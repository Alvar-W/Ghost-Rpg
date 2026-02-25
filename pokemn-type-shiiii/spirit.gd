extends CharacterBody2D

@export var spirit_data: SpiritData
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var aggro_scan: Area2D = $AggroScan


@export var max_speed := 200
@export var accel := 2000
@export var friction := 1000
@export var wander_radius := 500
@export var stop_chance := 0.005
var wobble_time := 0.0
@export var wobble_strength := 12.0
@export var wobble_speed := 6.0
@export var detect_radius := 200.0
@export var chase_speed := 260.0
var player: CharacterBody2D
var is_chasing := false
var origin_pos: Vector2
var target_pos: Vector2
var is_stopped := false

func _ready():
	add_to_group("spirit")
	player = get_tree().get_first_node_in_group("player")
	var mat := particles.process_material.duplicate(true)
	particles.process_material = mat
	aggro_scan.monitoring = true
	aggro_scan.monitorable = true
	origin_pos = global_position
	pick_new_target()
	update_visual()

func _process(delta):
	wobble_time += delta * wobble_speed
	
	# Direction-based perpendicular wobble
	if velocity.length() > 0.1:
		var dir = velocity.normalized()
		var perp = Vector2(-dir.y, dir.x)
		var wobble = sin(wobble_time) * wobble_strength
		particles.position = perp * wobble
	else:
		particles.position = Vector2.ZERO

func _physics_process(delta):
	# Make sure we always have the player
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Update gradient (visual only)
	var mat: ParticleProcessMaterial = particles.process_material
	if mat.color_ramp:
		var grad: Gradient = mat.color_ramp.gradient
		if grad:
			grad.set_color(0, Color.WHITE)
			grad.set_color(1, spirit_data.glow_color)
			grad.set_color(2, Color(spirit_data.glow_color.r, spirit_data.glow_color.g, spirit_data.glow_color.b, 0.0))

	# ---- CHASE PLAYER ----
	if player:
		var dist := global_position.distance_to(player.global_position)
		if dist < detect_radius:
			var dir := (player.global_position - global_position).normalized()
			var desired_vel := dir * chase_speed
			velocity = velocity.move_toward(desired_vel, accel * delta)
			move_and_slide()
			return   # IMPORTANT: skip wandering while chasing

	# ---- WANDER ----
	if not is_stopped and randf() < stop_chance:
		is_stopped = true
	elif is_stopped and randf() < stop_chance * 2.0:
		is_stopped = false
		pick_new_target()

	if is_stopped:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		var desired_dir = target_pos - global_position
		if desired_dir.length() < 5:
			pick_new_target()
		else:
			var desired_vel = desired_dir.normalized() * max_speed
			velocity = velocity.move_toward(desired_vel, accel * delta)

	move_and_slide()



func pick_new_target():
	target_pos = origin_pos + Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

func update_visual():
	if collision.shape is RectangleShape2D:
		collision.shape.size = Vector2(24, 24)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var player = get_tree().get_first_node_in_group("player")
		player.add_item(spirit_data)
		queue_free()

func start_group_combat():
	await get_tree().physics_frame

	var bodies = aggro_scan.get_overlapping_bodies()
	print("AggroScan overlaps:", bodies)

	var nearby_spirits: Array = []
	for b in bodies:
		print("Found:", b, " groups:", b.get_groups())
		if b.is_in_group("spirit") and b != self:
			nearby_spirits.append(b)

	nearby_spirits.append(self)
	print("Enemy spirits joining:", nearby_spirits.size())

	var player = get_tree().get_first_node_in_group("player")
	var bm = get_node("/root/Battlemanager")
	bm.build_player_party(player.equipped_robot, player.equipped_spirit)
	bm.build_enemy_party(nearby_spirits)
	bm.roll_initiative()
	get_tree().change_scene_to_file("res://Battle.tscn")
