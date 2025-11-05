extends Node2D
@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var in_game_menu: Control = $CanvasLayer/InGameMenu

signal nav_ready(bounds: Rect2)

var max_brightness: float = 1.0
var min_brightness: float = 0.7
var current_brightness: float = 1.0
@export var fade_speed: float = 2.0

var need_to_darken: bool = false
var need_to_brighten: bool = false

func _ready():
	emit_signal("nav_ready", get_nav_bounds())
	SignalManager.spawn_raven.connect(darken_map)
	SignalManager.despawn_raven.connect(brighten_map)

func get_nav_bounds():
	return navigation_region_2d.get_bounds()
	
func _process(delta: float) -> void:
	if need_to_darken:
		current_brightness = lerp(current_brightness, min_brightness, delta * fade_speed)
		world_environment.environment.adjustment_brightness = current_brightness
		if abs(current_brightness - min_brightness) < 0.01:
			need_to_darken = false
			
	elif need_to_brighten:
		current_brightness = lerp(current_brightness, max_brightness, delta * fade_speed)
		world_environment.environment.adjustment_brightness = current_brightness
		if abs(max_brightness - current_brightness) < 0.01:
			need_to_brighten = false

func darken_map(_target_pos: Vector2):
	print("Need to darken map")
	need_to_darken = true

func brighten_map(_target_pos: Vector2):
	print('Need to brighten map')
	need_to_brighten = true
