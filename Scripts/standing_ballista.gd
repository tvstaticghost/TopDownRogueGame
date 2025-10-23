extends Node2D

@onready var pivot_point: Node2D = $PivotPoint
@onready var player = get_node("../Player")

var rotation_speed: float = 1.0

func _process(delta: float) -> void:
	var dir = player.position - position
	var target_rotation = atan2(dir.y, dir.x)
	
	pivot_point.rotation = lerp_angle(pivot_point.rotation, target_rotation, rotation_speed * delta)
