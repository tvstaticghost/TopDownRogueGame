extends CharacterBody2D

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE}
enum patrol_type {TIGHT, MAPWIDE, IDLE}

@export var running_speed: float = 125.0
@export var walking_speed: float = 80.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
var player
@onready var nav_timer: Timer = $NavTimer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	navigation_agent_2d.target_position = player.global_position

func _physics_process(delta: float) -> void:
	if !navigation_agent_2d.is_target_reached():
		var nav_point_direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		velocity = nav_point_direction * running_speed
		move_and_slide()
		
func _on_nav_timer_timeout() -> void:
	if navigation_agent_2d.target_position != player.global_position:
		navigation_agent_2d.target_position = player.global_position
	nav_timer.start()
