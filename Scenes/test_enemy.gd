extends Node2D

@onready var enemy_visuals: AnimatedSprite2D = $EnemyVisuals
@onready var player

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE}

@export var walking_speed: float = 2.0
@export var running_speed: float = 10.0

var current_enemy_state: enemy_states
var can_take_action: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		print('There is no player in the scene')
	
	current_enemy_state = enemy_states.PATROL
	
	
func check_state():
	match current_enemy_state:
		enemy_states.PATROL:
			print('Enemy should be patrolling')
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
	
