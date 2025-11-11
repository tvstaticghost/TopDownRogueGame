extends Node2D

#TileMap is 16x16 px square cells
@onready var border_map: TileMapLayer = $BorderMap

const BORDER_TREE_1 = preload("uid://cpk55evrnrucp")
const BORDER_TREE_2 = preload("uid://21vhfquc2icr")
const BORDER_TREE_3 = preload("uid://cc2xlbe7fwa14")
const BORDER_TREE_4 = preload("uid://brwmfbh2t1mnr")

var used_rect
var tree_array = []
var big_tree_array = []

const TREE_SHADER = preload("uid://d0yvcgwngfwoc")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_array.append(BORDER_TREE_1)
	tree_array.append(BORDER_TREE_2)
	tree_array.append(BORDER_TREE_3)
	tree_array.append(BORDER_TREE_4)
	
	big_tree_array.append(BORDER_TREE_1)
	big_tree_array.append(BORDER_TREE_3)
	big_tree_array.append(BORDER_TREE_4)
	
	used_rect = border_map.get_used_rect().size
	print(used_rect)
	print("(Width, Height) : (%d, %d)" % [used_rect[0] - 1, used_rect[1] - 1])
	
	var rand_x_distance = 0
	var rand_y_distance = 0
	for height in range(0, used_rect[1]):
		rand_x_distance = randi_range(10, 13)
		
		#Break from loop when there is no room left in the height of the map to spawn trees
		if height > used_rect[1] - 1:
			height = used_rect[1] - 1
			
		#Resetting last_x added to zero, when going to another row, I haven't added tree along the width yet
		var last_x_added = 0
		for width in range(0, used_rect[0]):
			#We are on the right row now
			if height == 0 or height == used_rect[1] - 1 or height == rand_y_distance:
				if width == 0 or width == last_x_added + rand_x_distance:
					#Need to check for the width spacing now
					var cell_position = border_map.map_to_local(Vector2i(width, height))
					#pass true if its the first row of the tile map, I don't want the small trees as an option to spawn
					if height == 0:
						spawn_tree(cell_position, true)
					else:
						spawn_tree(cell_position, false)
					last_x_added = width
				elif width == used_rect[0] - 1:
					var cell_position = border_map.map_to_local(Vector2i(width, height))
					if height == 0:
						spawn_tree(cell_position, true)
					else:
						spawn_tree(cell_position, false)
		
		if height == rand_y_distance:
			rand_y_distance = height + randi_range(8, 10)
	
func spawn_tree(tree_position, first_row: bool):
	var tree_to_use
	var new_tree
	if !first_row:
		tree_to_use = randi_range(0, len(tree_array) - 1)
		new_tree = tree_array[tree_to_use].instantiate()
	else:
		tree_to_use = randi_range(0, len(big_tree_array) - 1)
		new_tree = big_tree_array[tree_to_use].instantiate()
	new_tree.position = tree_position
	new_tree.z_index = 4
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = TREE_SHADER
	
	shader_material.set_shader_parameter("sway_speed", randf_range(0.1, 0.5))
	shader_material.set_shader_parameter("sway_strength", randf_range(0.2, 1.0))
	
	new_tree.material = shader_material
	
	border_map.add_child(new_tree)
