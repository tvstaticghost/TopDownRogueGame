extends Node2D

@onready var forest_sounds: AudioStreamPlayer = $ForestSounds
@onready var ground_tile_map: Node2D = $GroundTileMap
@onready var player: CharacterBody2D = $Player
@onready var test_enemy: Node2D = $TestEnemy
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_call"):
		if ground_tile_map != null:
			if test_enemy != null and player != null:
				print(test_enemy.position)
				print(player.position)
				ground_tile_map.test_call(test_enemy.position, player.position)
