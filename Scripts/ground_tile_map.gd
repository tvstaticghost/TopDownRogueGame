extends Node2D
@onready var tile_map_layer: TileMapLayer = $DirtLayer
@onready var grass_layer: TileMapLayer = $GrassLayer

const BIG_ROCK = preload("res://Scenes/big_rock.tscn")
const BIG_ROCK_2 = preload("res://Scenes/big_rock_2.tscn")
const ROCK_CLUSTER = preload("res://Scenes/rock_cluster.tscn")
const ROCK_CLUSTER_2 = preload("res://Scenes/rock_cluster_2.tscn")
const ROCK_CLUSTER_3 = preload("res://Scenes/rock_cluster_3.tscn")

var cluster_list = [ROCK_CLUSTER, ROCK_CLUSTER_2, ROCK_CLUSTER_3]

const TILE_SIZE = 16
const TURNS_TO_MOVE: int = 2 #Maybe adjust
var pathfinding_grid: AStarGrid2D = AStarGrid2D.new()

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
			
func test_call(source_pos:Vector2, target_pos: Vector2):
	var path_to_target = pathfinding_grid.get_point_path(source_pos / TILE_SIZE, target_pos / TILE_SIZE)
	return path_to_target
	
func get_random_target():
	var rand_int = randi() % 20
	var cell_pos = tile_map_layer.get_used_cells()[rand_int]
	var world_pos = tile_map_layer.map_to_local(cell_pos)
	return world_pos

func _ready() -> void:
	rng.seed = 100
	
	generate_rocks()
	
	pathfinding_grid.region = tile_map_layer.get_used_rect()
	pathfinding_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	pathfinding_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE #Maybe change this later
	pathfinding_grid.update()
	
	#This functionality disables certain points
	#for cell in tile_map_layer.get_used_cells():
		#pathfinding_grid.set_point_solid(cell, true)
