extends Node2D

@export var flight_speed: float = 400.0

var target_pos: Vector2
var current_direction: Vector2
var offset: float = 5.0
var despawning: bool = false

func _ready() -> void:
	print("Instantiated raven")
	SignalManager.spawn_raven.connect(spawn)
	SignalManager.despawn_raven.connect(despawn)

func _physics_process(delta: float) -> void:
	if !despawning:
		if position.distance_to(target_pos) > offset:
			position += current_direction * flight_speed * delta
	else:
		position += current_direction * flight_speed * delta

func spawn(target_position: Vector2):
	target_pos = target_position
	print('Spawn raven at (%f, %f)' % [target_pos.x, target_pos.y])
	current_direction = (target_pos - position).normalized()

func despawn(target_position: Vector2):
	target_pos = target_position
	despawning = true
	print('Despawning raven')

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if despawning:
		SignalManager.raven_able_to_spawn.emit()
		queue_free()
