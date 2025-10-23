extends Node2D

@onready var enemy_visuals: AnimatedSprite2D = $EnemyVisuals
@onready var player

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE}

@export var walking_speed: float = 2.0
@export var running_speed: float = 10.0
@export var enemy_vision_distance: float = 450.0

var current_enemy_state: enemy_states
var can_take_action: bool = true
var can_hear_player: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print('There is no player in the scene')
	
	current_enemy_state = enemy_states.PATROL
	
func can_see_player():
	var direction_to_player = position.direction_to(player.position)
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var distance_to_player = position.distance_to(player.position)
	
	if direction_to_player.dot(facing_direction) > 0.5 and distance_to_player < enemy_vision_distance:
		return true
	return false
	
func perform_patrol():
	pass #Fill out logic to get positions and walk to them, remain idle, etc
	
func check_state():
	match current_enemy_state:
		enemy_states.PATROL:
			if can_see_player():
				current_enemy_state = enemy_states.CHASE
				return
			else:
				if can_hear_player:
					current_enemy_state = enemy_states.INVESTIGATE
					return
			perform_patrol() #Fill out logic to get positions and walk to them, remain idle, etc
		enemy_states.CHASE:
			print('Enemy should be chasing')
		enemy_states.ATTACK:
			print('Enemy should be attacking')
		enemy_states.INVESTIGATE:
			print('Enemy should be investigating')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player == null:
		return
	
	if can_take_action:
		check_state()
	


func _on_hearing_area_body_entered(body: Node2D) -> void:
	if "Player" in body.get_groups():
		can_hear_player = true


func _on_hearing_area_body_exited(body: Node2D) -> void:
	if "Player" in body.get_groups():
		can_hear_player = false
