extends Node2D
@onready var tile_map_layer: TileMapLayer = $DirtLayer
@onready var grass_layer: TileMapLayer = $GrassLayer

const BIG_ROCK = preload("res://Scenes/big_rock.tscn")
const BIG_ROCK_2 = preload("res://Scenes/big_rock_2.tscn")
const ROCK_CLUSTER = preload("res://Scenes/rock_cluster.tscn")
const ROCK_CLUSTER_2 = preload("res://Scenes/rock_cluster_2.tscn")
const ROCK_CLUSTER_3 = preload("res://Scenes/rock_cluster_3.tscn")

var cluster_list = [ROCK_CLUSTER, ROCK_CLUSTER_2, ROCK_CLUSTER_3]
#enum patrol_type {TIGHT, MAPWIDE, IDLE}
#var tight_patrol_range = 10

#const TILE_SIZE = 16
#const TURNS_TO_MOVE: int = 2 #Maybe adjust
#var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()

@onready var level = $".."
@onready var ground_tile_map = $"."

var rng = RandomNumberGenerator.new()
@export var noise_scalar: float = 0.1

func generate_rocks():
	var cells = tile_map_layer.get_used_cells()
	
	for cell in cells:
		var world_pos = tile_map_layer.map_to_local(cell)
		if rng.randi() % 100 + 1 == 7:
			var cluster_choice = cluster_list[rng.randi() % len(cluster_list)]
			var rock = cluster_choice.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			rock.position = world_pos
			level.add_child.call_deferred(rock)
			
#func test_call(source_pos:Vector2, target_pos: Vector2):
	#var path_to_target = pathfinding_grid.get_point_path(source_pos / TILE_SIZE, target_pos / TILE_SIZE)
	#return path_to_target
	
#func get_random_target(patrol_mode, current_pos): #OHH I can add a parameter for different patrol behavior like a tight patrol, map-wide patrol, just basically idle, etc
	#if patrol_mode == patrol_type.MAPWIDE:
		#var random_cell = tile_map_layer.get_used_cells().pick_random()
		#var world_pos = tile_map_layer.map_to_local(random_cell)
		#return world_pos
	#elif patrol_mode == patrol_type.TIGHT:
		#var current_tile = tile_map_layer.local_to_map(current_pos)
		#var x_min = current_tile.x - tight_patrol_range
		#var y_min = current_tile.y - tight_patrol_range
		#var x_max = current_tile.x + tight_patrol_range
		#var y_max = current_tile.y + tight_patrol_range
		#
		#if x_min < tile_map_layer.get_used_cells()[0][0]:
			#x_min = tile_map_layer.get_used_cells()[0][0]
		#if x_max > tile_map_layer.get_used_cells()[-1][0]:
			#x_max = tile_map_layer.get_used_cells()[-1][0]
		#if y_min < tile_map_layer.get_used_cells()[0][1]:
			#y_min = tile_map_layer.get_used_cells()[0][1]
		#if y_max > tile_map_layer.get_used_cells()[-1][1]:
			#y_max = tile_map_layer.get_used_cells()[-1][1]
		#
		#var random_x = randi_range(x_min, x_max)
		#var random_y = randi_range(y_min, y_max)
		#var world_pos = tile_map_layer.map_to_local(Vector2i(random_x, random_y))
		#
		#return world_pos
	#else:
		#print('Invalid type bitch')

func _ready() -> void:
	rng.seed = 100
	
	generate_rocks()
	
	#pathfinding_grid.region = tile_map_layer.get_used_rect()
	#pathfinding_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	#pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS #Maybe change this later
	#pathfinding_grid.update()
	
	#print(tile_map_layer.get_used_rect())
	#print(tile_map_layer.get_used_cells())
	
	#This functionality disables certain points
	#for cell in tile_map_layer.get_used_cells():
		#pathfinding_grid.set_point_solid(cell, true)
