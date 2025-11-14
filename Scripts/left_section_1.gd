extends Node2D

@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D
# Called when the node enters the scene tree for the first time.

func get_nav_bounds():
	return navigation_region_2d.get_bounds()
