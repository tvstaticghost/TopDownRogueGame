extends Node2D

@export var speed: float = 1200.0
@onready var line_2d: Line2D = $Line2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var fade_timer: Timer = $FadeTimer

var starting_position: Vector2
var direction: Vector2
var on_screen: bool = true
var despawn_arrow: bool = false
var hit: bool = false

func _ready() -> void:
	starting_position = position

func _physics_process(delta: float) -> void:
	if on_screen and !hit:
		position += direction * speed * delta
		var line_pos = line_2d.get_point_position(line_2d.get_point_count() - 1)
		line_pos.y += 200 
		line_2d.add_point(line_pos)
	else:
		if despawn_arrow == false:
			sprite_2d.queue_free()
			despawn_arrow = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false


func _on_fade_timer_timeout() -> void:
	var random_x = randi() % 30 + 1
	fade_timer.start()
	line_2d.default_color.a -= 0.1
	for point in range(line_2d.get_point_count() - 1):
		var pos = line_2d.get_point_position(point)
		var rand_dir = randi() % 2
		if rand_dir == 0:
			pos.x += random_x
		else:
			pos.x -= random_x
		line_2d.set_point_position(point, pos)
	if line_2d.default_color.a <= 0.02:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	#When arrow hits an area2D (walls etc)
	#Find an arrow hitting wood or stone sound
	if area.is_in_group("HitBox") or area.is_in_group("Tree"):
		return
		
	if area.is_in_group("Enemy"):
		SignalManager.arrow_hit.emit(starting_position)
	hit = true
