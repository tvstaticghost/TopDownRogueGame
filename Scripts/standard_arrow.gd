#extends Node2D
#
#@export var speed: float = 1200.0
#var direction: Vector2
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#direction = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)).normalized()
#
#
#func _physics_process(delta: float) -> void:
	#position += direction * speed * delta
# arrow.gd
extends Node2D

@export var speed: float = 1200.0
var direction: Vector2

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
