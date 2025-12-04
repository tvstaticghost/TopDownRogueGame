extends Node2D

@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D
# Called when the node enters the scene tree for the first time.

signal nav_ready(bounds: Rect2)

func _ready():
	print("ready")
	emit_signal("nav_ready", get_nav_bounds())

func get_nav_bounds():
	print("returning map bounds")
	print(navigation_region_2d.get_bounds())
	return navigation_region_2d.get_bounds()
