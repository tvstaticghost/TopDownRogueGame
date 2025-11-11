extends Node2D

const LEFT_SECTION_1 = preload("uid://dwl1n83o3olms")
const RIGHT_SECTION_1 = preload("uid://c5xjrbc6kaho6")
const PLAYER = preload("uid://6n24mvh65b57")

#Add fragments to each list when they are created and preloaded
var LEFT_SECTIONS = [LEFT_SECTION_1]
var RIGHT_SECTIONS = [RIGHT_SECTION_1]

var SPAWN_POSITIONS = []

#TODO THis is insanely broken
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var left_test = LEFT_SECTIONS[0].instantiate()
	add_child(left_test)
	
	var right_test = RIGHT_SECTIONS[0].instantiate()
	add_child(right_test)
	
	var right_conn_point = right_test.get_child(0)
	var left_conn_point = left_test.get_child(0)
	
	SPAWN_POSITIONS.append(right_test.get_child(1).global_position)
	SPAWN_POSITIONS.append(left_test.get_child(1).global_position)
	
	var offset = right_conn_point.position  # local to right_test
	right_test.global_position = left_conn_point.global_position - offset
	
	print(SPAWN_POSITIONS)
