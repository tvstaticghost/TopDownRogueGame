extends CharacterBody2D

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE}
enum patrol_type {TIGHT, MAPWIDE, IDLE}

var current_enemy_state: enemy_states
@export var enemy_patrol_type: patrol_type

@export var running_speed: float = 125.0
@export var walking_speed: float = 80.0
@export var enemy_vision_distance: float = 100.0

@onready var enemy_visuals: AnimatedSprite2D = $EnemyVisuals
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var nav_timer: Timer = $NavTimer

var player: CharacterBody2D

var can_take_action: bool = true
var has_target: bool = false
var running: bool = false
var can_move: bool = true
var attacking: bool = false
var can_hear_player: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	current_enemy_state = enemy_states.CHASE
	set_animation("idle")

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	
	if can_take_action:
		check_state()
		
func set_animation(animation: String):
	enemy_visuals.play(animation)
		
func can_see_player():
	var direction_to_player = position.direction_to(player.position)
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var distance_to_player = position.distance_to(player.position)
	
	if direction_to_player.dot(facing_direction) > 0.5 and distance_to_player < enemy_vision_distance:
		return true
	return false
	
func get_random_position():
	if enemy_patrol_type == patrol_type.TIGHT:
		print()
	elif enemy_patrol_type == patrol_type.MAPWIDE:
		print()
	else:
		return
		
func perform_patrol():
	if can_see_player():
		current_enemy_state = enemy_states.CHASE
		return
	else:
		if can_hear_player: #This is jank as fuck
			current_enemy_state = enemy_states.INVESTIGATE
			return
	if !has_target:
		navigation_agent_2d.target_position = player.global_position
	
func chase_player():
	if !can_move:
		return
	
	if enemy_visuals.animation != "run":
		set_animation("run")
		
	if nav_timer.is_stopped():
		nav_timer.start()
	
	navigation_agent_2d.target_position = player.global_position
	if !navigation_agent_2d.is_target_reached() and not navigation_agent_2d.is_navigation_finished():
		var nav_point_direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		velocity = nav_point_direction * running_speed
		move_and_slide()
		
		if !has_target:
			has_target = true
	
	if navigation_agent_2d.is_navigation_finished():
		current_enemy_state = enemy_states.ATTACK
		
func perform_attack():
	if !attacking:
		if navigation_agent_2d.is_navigation_finished():
			attacking = true
			can_move = false
			enemy_visuals.play("slash")
		else:
			current_enemy_state = enemy_states.CHASE

func check_state():
	match current_enemy_state:
		enemy_states.PATROL:
			perform_patrol()
		enemy_states.CHASE:
			chase_player()
		enemy_states.ATTACK:
			perform_attack()
		enemy_states.INVESTIGATE:
			print('Enemy should be investigating')
		
func _on_nav_timer_timeout() -> void:
	if navigation_agent_2d.target_position != player.global_position:
		navigation_agent_2d.target_position = player.global_position
	nav_timer.start()


func _on_enemy_visuals_animation_finished() -> void:
	can_move = true
	attacking = false
