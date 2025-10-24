extends CharacterBody2D

@onready var enemy_visuals: AnimatedSprite2D = $EnemyVisuals
@onready var player
@onready var patrol_timer: Timer = $PatrolTimer

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE}

@export var walking_speed: float = 200.0
@export var running_speed: float = 250.0
@export var enemy_vision_distance: float = 450.0
@export var rotation_speed: float = 8.0 #When moving diagonally, the guy is glitching his ass off

var current_enemy_state: enemy_states
var can_take_action: bool = true
var can_hear_player: bool = false

var has_target: bool = false
var current_target
var current_route
var current_route_index

var is_moving: bool = false

var current_level: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(enemy_visuals.animation)
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print('There is no player in the scene')
		
	current_level = get_tree().get_current_scene().name
	current_enemy_state = enemy_states.PATROL
	
	get_patrol_target()
	
func can_see_player():
	var direction_to_player = position.direction_to(player.position)
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var distance_to_player = position.distance_to(player.position)
	
	if direction_to_player.dot(facing_direction) > 0.5 and distance_to_player < enemy_vision_distance:
		return true
	return false
	
func perform_patrol():
	pass #Fill out logic to get positions and walk to them, remain idle, etc
	
func get_patrol_target():
	var test_target = get_tree().get_first_node_in_group("GroundTileMap").get_random_target()
	if test_target != null:
		has_target = true
		current_target = test_target
		current_route = get_tree().get_first_node_in_group("GroundTileMap").test_call(position, current_target)
		current_route_index = 1
	
#func move_enemy_to_point():
	#var dir = (current_route[current_route_index] - position).normalized()
	#position += dir * walking_speed
	#var target_angle = dir.angle()
	#rotation = lerp_angle(rotation, target_angle, rotation_speed)
	

func move_enemy_to_point(delta):
	var dir = (current_route[current_route_index] - global_position).normalized()
	velocity = dir * walking_speed
	move_and_slide()
	var target_angle = dir.angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	
func check_state(delta):
	match current_enemy_state:
		enemy_states.PATROL:
			if can_see_player():
				current_enemy_state = enemy_states.CHASE
				return
			else:
				if can_hear_player:
					current_enemy_state = enemy_states.INVESTIGATE
					return
			if has_target:
				if position.distance_to(current_route[current_route_index]) > 10:
					move_enemy_to_point(delta)
				else:
					if current_route_index < len(current_route) - 1:
						current_route_index += 1
						print("Going to next route index number %d" % current_route_index)
					else:
						has_target = false
						patrol_timer.wait_time = randf() * 10
						patrol_timer.start()
						print('Reached the destination')
					
			perform_patrol() #Fill out logic to get positions and walk to them, remain idle, etc
		enemy_states.CHASE:
			print('Enemy should be chasing')
		enemy_states.ATTACK:
			print('Enemy should be attacking')
		enemy_states.INVESTIGATE:
			print('Enemy should be investigating')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if can_take_action:
		check_state(delta)
	
	if has_target and enemy_visuals.animation == "idle":
		enemy_visuals.play('walk')
	if not has_target and enemy_visuals.animation == "walk":
		enemy_visuals.play("idle")

func _on_hearing_area_body_entered(body: Node2D) -> void:
	if "Player" in body.get_groups():
		can_hear_player = true


func _on_hearing_area_body_exited(body: Node2D) -> void:
	if "Player" in body.get_groups():
		can_hear_player = false


func _on_patrol_timer_timeout() -> void:
	print('Patrol timer ran out - getting new target!')
	get_patrol_target()
	patrol_timer.stop()
