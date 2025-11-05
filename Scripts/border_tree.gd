extends Node

@onready var border_tree_1: Sprite2D = $"."

@export var max_opacity: float = 1.0
@export var min_opacity: float = 0.4
@export var opacity_step_amount: float = 5
var current_opacity
var player_under_tree: bool = false

func _ready() -> void:
	current_opacity = max_opacity

func _process(delta: float) -> void:
	if player_under_tree:
		if current_opacity > min_opacity:
			current_opacity -= opacity_step_amount * delta
			border_tree_1.self_modulate = Color(1, 1, 1, current_opacity)
	else:
		if current_opacity < max_opacity:
			current_opacity += opacity_step_amount * delta
			border_tree_1.self_modulate = Color(1, 1, 1, current_opacity)

func _on_fade_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_under_tree = true


func _on_fade_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_under_tree = false
