extends Node2D

@onready var rotate_timer: Timer = $RotateTimer
@onready var pivot_point: Node2D = $PivotPoint

var current_rotation: float = 0.0
var target_rotation: float
var rotation_amount = 2.0
var rotation_speed: float = 0.3
var rotating: bool = false

func _physics_process(delta: float) -> void:
	if rotating:
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		if absf(angle_difference(rotation, target_rotation)) < 0.01:
			rotation = target_rotation
			rotating = false
			
func _on_rotate_timer_timeout() -> void:
	rotating = true
	current_rotation = rotation
	target_rotation = current_rotation + rotation_amount
	
