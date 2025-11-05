extends Node2D

@onready var root: CharacterBody2D = $".."
@onready var hurt_box_critical: Area2D = $"../HurtBoxCritical"
@onready var hurt_box: CollisionShape2D = $"../HurtBoxCritical/HurtBox"
@onready var hurt_timer: Timer = $"../HurtTimer"
@onready var enemy_visuals: AnimatedSprite2D = $"../EnemyVisuals"

@export var max_health: float = 300.0
var current_health: float
var dead: bool = false

func _ready() -> void:
	current_health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_damage(damage_amount: float):
	current_health -= damage_amount
	print('Enemy took %d damage. Enemy has %d health remaining.' % [damage_amount, current_health])
	
	if current_health <= 0:
		dead = true
		knight_dead()
		print('Enemy is now dead')
	else:
		enemy_visuals.self_modulate = Color(1, 1, 1, 0.5)
		hurt_timer.start()
		
func knight_dead():
	set_deferred("monitoring", false)
	root.die()

func _on_hurt_box_critical_area_entered(area: Area2D) -> void:
	if area.is_in_group("Arrow") and !dead:
		take_damage(25.0)
		print("Critical Hit")


func _on_hurt_box_normal_area_entered(area: Area2D) -> void:
	if area.is_in_group("Arrow") and !dead:
		take_damage(15.0)
		print("Normal Hit")

func _on_hurt_timer_timeout() -> void:
	print('Hurt Timer go off')
	enemy_visuals.self_modulate = Color(1, 1, 1, 1)
	hurt_timer.stop()
