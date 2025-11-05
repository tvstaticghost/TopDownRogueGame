extends Node

const MAX_HEALTH: float = 100.0
var current_health: float = MAX_HEALTH

func _ready() -> void:
	SignalManager.player_hit.connect(take_damage)
	
func take_damage(damage: float):
	print("Player has taken %d damage" % damage)
