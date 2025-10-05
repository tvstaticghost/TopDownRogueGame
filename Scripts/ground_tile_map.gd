extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var fastNoiseLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fastNoiseLite = FastNoiseLite.new()
	fastNoiseLite.noise_type = FastNoiseLite.TYPE_PERLIN
	fastNoiseLite.seed = randi()
	fastNoiseLite.frequency = 0.01
	
	var used_rect = tile_map_layer.get_used_cells()
	
