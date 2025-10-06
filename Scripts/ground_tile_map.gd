extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

const BIG_ROCK = preload("res://Scenes/big_rock.tscn")
const BIG_ROCK_2 = preload("res://Scenes/big_rock_2.tscn")
const ROCK_CLUSTER = preload("res://Scenes/rock_cluster.tscn")
const ROCK_CLUSTER_2 = preload("res://Scenes/rock_cluster_2.tscn")
const ROCK_CLUSTER_3 = preload("res://Scenes/rock_cluster_3.tscn")

var cluster_list = [ROCK_CLUSTER, ROCK_CLUSTER_2, ROCK_CLUSTER_3]

@onready var level = $".."
@onready var ground_tile_map = $"."

var rng = RandomNumberGenerator.new()
@export var noise_scalar: float = 0.1

var fastNoiseLite
# Called when the node enters the scene tree for the first time.

#func generate_rocks():
	#var cells = tile_map_layer.get_used_cells()
	#
	#for cell in cells:
		#var world_pos = tile_map_layer.map_to_local(cell)
		#if rng.randi() % 100 + 1 == 7:
			#var cluster_choice = cluster_list[rng.randi() % len(cluster_list)]
			#var rock = cluster_choice.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
			#rock.position = world_pos
			#level.add_child.call_deferred(rock)
			
func generate_rocks():
	var cells = tile_map_layer.get_used_cells()
	
	var step = 3  # every 5 tiles
	for x in range(0, tile_map_layer.get_used_rect().size.x, step):
		for y in range(0, tile_map_layer.get_used_rect().size.y, step):
			# Convert tile cell → world position
			var cell = Vector2(x, y)
			var noise_val = fastNoiseLite.get_noise_2d(cell.x * noise_scalar, cell.y * noise_scalar)
			if noise_val > 0.1:
				var cluster_choice = cluster_list[rng.randi() % cluster_list.size()]
				var rock = cluster_choice.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
				var world_pos = tile_map_layer.map_to_local(cell)
				rock.position = tile_map_layer.to_global(world_pos)
				level.add_child.call_deferred(rock)
	

func _ready() -> void:
	rng.seed = 100
	
	fastNoiseLite = FastNoiseLite.new()
	fastNoiseLite.noise_type = FastNoiseLite.TYPE_PERLIN
	fastNoiseLite.seed = randi()
	fastNoiseLite.frequency = 0.05
	fastNoiseLite.seed = 100
	
	generate_rocks()
