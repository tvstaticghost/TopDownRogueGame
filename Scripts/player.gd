extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_legs: AnimatedSprite2D = $PlayerLegs
@export var player_movement_speed: float = 250
@export var player_crouched_movement_speed: float = 150
@onready var camera_2d: Camera2D = $Camera2D
@onready var arrow_firing_point: Marker2D = $AnimatedSprite2D/ArrowFiringPoint
@onready var standard_arrow = preload("res://Scenes/standard_arrow.tscn")
@onready var raven_scene = preload("res://Scenes/raven.tscn")
@onready var raven_landing_spot: Marker2D = $AnimatedSprite2D/RavenLandingSpot
@onready var in_game_menu: Control = $"../CanvasLayer/InGameMenu"

@onready var hurt_timer: Timer = $HurtTimer
var current_color = Color(1, 1, 1, 1)

@onready var fire_arrow_player: AudioStreamPlayer = $FireArrow
@onready var bow_draw_player: AudioStreamPlayer = $BowDrawPlayer
@onready var draw_timer: Timer = $DrawTimer

@onready var pivot_point: Node2D = $PivotPoint
@onready var raven_spawn_point: Marker2D = $PivotPoint/RavenSpawnPoint

enum direction {NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST}

var current_direction = direction.NORTH

var transitioning: bool = false
var crouched: bool = false
var walking: bool = false
var can_crouch: bool = true
var can_walk: bool = true
var can_aim: bool = true
var aiming: bool = false
var firing_arrow: bool = false
var can_aim_rotate: bool = false
var ravening: bool = false
var raven_spawned: bool = false

@onready var movement_direction: Vector2 = Vector2.ZERO
@onready var player_look_direction

var target_rotation: float = 0.0
@export var rotation_speed: float = 8.0

var previously_aiming: bool = false

var current_rotation = 0.0
var current_rotation_set: bool = false

func _ready() -> void:
	crouched = false
	can_walk = true
	animated_sprite_2d.play("idle")
	SignalManager.raven_able_to_spawn.connect(raven_available)
	SignalManager.player_hit.connect(trigger_hurt_color)
	
func raven_available():
	raven_spawned = false
	
func trigger_hurt_color(_damage):
	animated_sprite_2d.self_modulate = Color(1, 0, 0, 1)
	hurt_timer.start()
	
func toggle_crouch():
	crouched = !crouched
	can_crouch = false
	movement_direction = Vector2.ZERO
	transitioning = true
	
	if crouched:
		animated_sprite_2d.play("stand_to_crouch")
	else:
		animated_sprite_2d.play("crouch_to_stand")
			
func rotate_player():
	match current_direction:
		direction.NORTH: target_rotation = deg_to_rad(0)
		direction.SOUTH: target_rotation = deg_to_rad(180)
		direction.EAST:  target_rotation = deg_to_rad(90)
		direction.WEST:  target_rotation = deg_to_rad(270)
		direction.NORTHEAST: target_rotation = deg_to_rad(45)
		direction.NORTHWEST: target_rotation = deg_to_rad(315)
		direction.SOUTHEAST: target_rotation = deg_to_rad(135)
		direction.SOUTHWEST: target_rotation = deg_to_rad(225)
		
func assign_direction(input_direction: Vector2):
	if input_direction.x == -1.0:
		current_direction = direction.WEST
	elif input_direction.x == 1.0:
		current_direction = direction.EAST
	elif input_direction.x < 0 and input_direction.x > -1 and input_direction.y < 0 and input_direction.y > -1:
		current_direction = direction.NORTHWEST
	elif input_direction.x > 0 and input_direction.x < 1 and input_direction.y < 0 and input_direction.y > -1:
		current_direction = direction.NORTHEAST
	elif input_direction.y == -1.0:
		current_direction = direction.NORTH
	elif input_direction.y == 1.0:
		current_direction = direction.SOUTH
	elif input_direction.x > 0 and input_direction.x < 1 and input_direction.y > 0 and input_direction.y < 1:
		current_direction = direction.SOUTHEAST
	elif input_direction.x < 0 and input_direction.x > -1 and input_direction.y > 0 and input_direction.y < 1:
		current_direction = direction.SOUTHWEST
		
	rotate_player()
		
func get_input():
	if transitioning or aiming:
		return
		
	player_look_direction = (get_global_mouse_position() - position).normalized()
	
	var input_direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if !crouched:
		velocity = input_direction * player_movement_speed
	else:
		velocity = input_direction * player_crouched_movement_speed
	
	assign_direction(input_direction)
	
	if ravening and velocity == Vector2.ZERO:
		return
	
	if velocity != Vector2.ZERO:
		if ravening:
			ravening = false
			send_raven_away()
			
		if !crouched:
			animated_sprite_2d.play("walk")
		else:
			animated_sprite_2d.play("crouch_walk")
		walking = true
	elif !transitioning:
		if crouched:
			animated_sprite_2d.play("crouch_idle")
		else:
			animated_sprite_2d.play("idle")
		walking = false
		
func aim_rotate():
	if !can_aim_rotate:
		return
		
	# Rotate torso to face mouse
	animated_sprite_2d.look_at(get_global_mouse_position())
	animated_sprite_2d.rotation += PI / 2

	# Snap legs to the nearest 15° of the torso
	var torso_deg = fposmod(animated_sprite_2d.rotation_degrees, 360)
	var snapped_deg = round(torso_deg / 20.0) * 20.0
	player_legs.rotation_degrees = snapped_deg
	
	var aim_angle = fposmod(animated_sprite_2d.rotation_degrees + 360.0, 360.0)
	
	if aim_angle >= 337.5 or aim_angle < 22.5:
		current_direction = direction.NORTH
	elif aim_angle < 67.5:
		current_direction = direction.NORTHEAST
	elif aim_angle < 112.5:
		current_direction = direction.EAST
	elif aim_angle < 157.5:
		current_direction = direction.SOUTHEAST
	elif aim_angle < 202.5:
		current_direction = direction.SOUTH
	elif aim_angle < 247.5:
		current_direction = direction.SOUTHWEST
	elif aim_angle < 292.5:
		current_direction = direction.WEST
	else:
		current_direction = direction.NORTHWEST
		
	rotate_player()

func _process(_delta: float) -> void:
	if transitioning:
		return
		
	if Input.is_action_just_pressed("raven"):
		if ravening:
			ravening = false
			send_raven_away()
			return
		if !raven_spawned:
			print('Ravening')
			animated_sprite_2d.play("arm_up")
			ravening = true
			transitioning = true
			
			if !raven_spawned:
				summon_raven()
			
			SignalManager.spawn_raven.emit(raven_landing_spot.global_position)
		
	if Input.is_action_just_released("crouch"):
		if can_crouch:
			can_walk = false
			toggle_crouch()
	
	if Input.is_action_pressed("aim"):
		if ravening:
			ravening = false
			send_raven_away()
			
		if !aiming:
			draw_timer.start()
			animated_sprite_2d.play("draw")
		previously_aiming = true
		aiming = true
		can_crouch = false
		can_walk = false
	else:
		aiming= false
		can_crouch = true
		can_walk = true
		if !aiming and previously_aiming:
			player_legs.visible = false
			animated_sprite_2d.play("crouch_shoot")
			fire_arrow()
			transitioning = true
			firing_arrow = true
			
	if aiming:
		if not current_rotation_set:
			current_rotation = animated_sprite_2d.rotation_degrees
			current_rotation_set = true
		current_rotation = animated_sprite_2d.rotation_degrees
		aim_rotate()
	
func _physics_process(delta: float) -> void:
	movement_direction = Vector2.ZERO
	animated_sprite_2d.rotation = lerp_angle(animated_sprite_2d.rotation, target_rotation, rotation_speed * delta)
	player_legs.rotation = lerp_angle(player_legs.rotation, target_rotation, rotation_speed * delta)
	
	if can_walk and !transitioning and !aiming:
		get_input()
		move_and_slide()

func fire_arrow():
	fire_arrow_player.play()
	can_aim_rotate = false
	var arrow = standard_arrow.instantiate()
	arrow.position = arrow_firing_point.global_position
	arrow.rotation = animated_sprite_2d.rotation
	arrow.direction = Vector2(cos(arrow.rotation - PI/2), sin(arrow.rotation - PI/2)).normalized()
	get_tree().current_scene.add_child(arrow)
	
func summon_raven():
	raven_spawned = true
	var raven = raven_scene.instantiate()
	var random_rotation = randf_range(0, 360.0)
	pivot_point.rotation_degrees = random_rotation
	raven.global_position = raven_spawn_point.global_position
	get_tree().current_scene.add_child(raven)
	
func send_raven_away():
	var random_rotation = randf_range(0, 360.0)
	pivot_point.rotation_degrees = random_rotation
	SignalManager.despawn_raven.emit(raven_spawn_point.global_position)

func _on_animated_sprite_2d_animation_finished() -> void:
	transitioning = false
	can_crouch = true
	can_walk = true
	previously_aiming = false
	
	if ravening:
		print('Raven Stance')
		return
	
	if crouched and !aiming:
		animated_sprite_2d.play("crouch_idle")
	elif !crouched and !aiming:
		animated_sprite_2d.play("idle")
	elif aiming:
		animated_sprite_2d.play("aim")
		player_legs.visible = true
		can_aim_rotate = true
		
	if firing_arrow:
		firing_arrow = false
		current_rotation_set = false


func _on_draw_timer_timeout() -> void:
	bow_draw_player.play()
	draw_timer.stop()


func _on_hurt_timer_timeout() -> void:
	print('Hurt Timer goes off')
	animated_sprite_2d.self_modulate = current_color
	hurt_timer.stop()
