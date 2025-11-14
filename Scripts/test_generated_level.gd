extends Node2D

const CENTER_SECTION_1 = preload("uid://dk7ui4jxvkjud")
const CENTER_SECTION_2 = preload("uid://cp5u5nsxyr84g")

const TOP_SECTION_1 = preload("uid://de2u1kqr6mbgm")
const BOTTOM_SECTION_1 = preload("uid://dwtcmc6hxl8y3")

const LEFT_SECTION_1 = preload("uid://dwl1n83o3olms")
const LEFT_SECTION_2 = preload("uid://7mr8ae62p42i")
const RIGHT_SECTION_1 = preload("uid://c5xjrbc6kaho6")
const PLAYER = preload("uid://6n24mvh65b57")

#Add fragments to each list when they are created and preloaded
var LEFT_SECTIONS = [LEFT_SECTION_1, LEFT_SECTION_2]
var RIGHT_SECTIONS = [RIGHT_SECTION_1]
var TOP_SECTIONS = [TOP_SECTION_1]
var BOTTOM_SECTIONS = [BOTTOM_SECTION_1]
var CENTER_SECTIONS = [CENTER_SECTION_1, CENTER_SECTION_2]

var SPAWN_POSITIONS = []

var fragment_queue = []
#TODO everything is broken....
func add_first_frag():
	#Start with a left fragment
	var random_left_frag = LEFT_SECTIONS[randi() % LEFT_SECTIONS.size()]
	var left_frag = random_left_frag.instantiate()
	add_child(left_frag)
	
	#Always add a center (CHANGE THIS LATER)
	var frag = CENTER_SECTIONS[randi() % CENTER_SECTIONS.size()]
	var frag_inst = frag.instantiate()
	add_child(frag_inst)
	var start_pos
	for child in frag_inst.get_children():
		if child.is_in_group("WesternConnection"):
			start_pos = child.global_position
	
	var target_pos = left_frag.get_child(0).global_position
	var difference = target_pos - start_pos
	frag_inst.global_position = difference
	
	for child in frag_inst.get_children():
		if child.is_in_group("WesternConnection"):
			child.add_to_group("UsedConnection")
	
	fragment_queue.push_back(frag_inst)
	
func render_map():
	while len(fragment_queue) > 0:
		print("Looping")
		var frag
		
		var current_frag = fragment_queue[0]
		for child in current_frag.get_children():
			
			if child.is_in_group("UsedConnection"):
				continue
			
			if child.is_in_group("ConnectionPoint"):
				if child.is_in_group("EasternConnection"):
					frag = RIGHT_SECTIONS[randi() % RIGHT_SECTIONS.size()]
				elif child.is_in_group("WesternConnection"):
					frag = LEFT_SECTIONS[randi() % LEFT_SECTIONS.size()]
				elif child.is_in_group("SouthernConnection"):
					frag = BOTTOM_SECTIONS[randi() % BOTTOM_SECTIONS.size()]
				elif child.is_in_group("NorthernConnection"):
					frag = TOP_SECTIONS[randi() % TOP_SECTIONS.size()]
				
				print(frag)
				var frag_inst = frag.instantiate()
				add_child(frag_inst)
				var target_pos = frag_inst.get_child(0).global_position
				var starting_pos = child.global_position
				var difference = starting_pos - target_pos
				frag_inst.global_position = difference
		
		fragment_queue.pop_at(0)

#TODO THis is insanely broken
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_first_frag()
	render_map()
	#var random_left_frag = LEFT_SECTIONS[randi() % LEFT_SECTIONS.size()]
	#var left_test = random_left_frag.instantiate()
	#add_child(left_test)
	#
	#var right_test = RIGHT_SECTIONS[0].instantiate()
	#add_child(right_test)
	#
	#SPAWN_POSITIONS.append(right_test.get_child(1).global_position)
	#SPAWN_POSITIONS.append(left_test.get_child(1).global_position)
	#
	#var left_marker_pos = left_test.get_child(0).global_position
	#var right_marker_pos = right_test.get_child(0).global_position
	#
	#var difference = left_marker_pos - right_marker_pos
	#right_test.global_position = difference
	#
	#var spawn_pos_index = randi_range(0, len(SPAWN_POSITIONS) - 1)
	#var player_object = PLAYER.instantiate()
	#add_child(player_object)
	#player_object.global_position = SPAWN_POSITIONS[spawn_pos_index]
	
