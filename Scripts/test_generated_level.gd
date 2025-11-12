extends Node2D

const LEFT_SECTION_1 = preload("uid://dwl1n83o3olms")
const LEFT_SECTION_2 = preload("uid://7mr8ae62p42i")
const RIGHT_SECTION_1 = preload("uid://c5xjrbc6kaho6")
const PLAYER = preload("uid://6n24mvh65b57")

#Add fragments to each list when they are created and preloaded
var LEFT_SECTIONS = [LEFT_SECTION_1, LEFT_SECTION_2]
var RIGHT_SECTIONS = [RIGHT_SECTION_1]

var SPAWN_POSITIONS = []

#TODO THis is insanely broken
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_left_frag = LEFT_SECTIONS[randi() % LEFT_SECTIONS.size()]
	var left_test = random_left_frag.instantiate()
	add_child(left_test)
	
	var right_test = RIGHT_SECTIONS[0].instantiate()
	add_child(right_test)
	
	SPAWN_POSITIONS.append(right_test.get_child(1).global_position)
	SPAWN_POSITIONS.append(left_test.get_child(1).global_position)
	
	var left_marker_pos = left_test.get_child(0).global_position
	var right_marker_pos = right_test.get_child(0).global_position
	
	var difference = left_marker_pos - right_marker_pos
	right_test.global_position = difference
	
	var spawn_pos_index = randi_range(0, len(SPAWN_POSITIONS) - 1)
	var player_object = PLAYER.instantiate()
	add_child(player_object)
	player_object.global_position = SPAWN_POSITIONS[spawn_pos_index]
