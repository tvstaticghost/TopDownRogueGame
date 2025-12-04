extends CharacterBody2D

enum enemy_states {PATROL, CHASE, ATTACK, INVESTIGATE, TRANSITIONING}
enum patrol_type {TIGHT, MAPWIDE, IDLE}

var current_enemy_state: enemy_states
@export var enemy_patrol_type: patrol_type = patrol_type.TIGHT

@export var running_speed: float = 125.0
@export var walking_speed: float = 80.0
@export var enemy_vision_distance: float = 100.0
@export var rotation_speed: float = 0.15

@onready var investigate_timer: Timer = $InvestigateTimer
@onready var transition_timer: Timer = $TransitionTimer
@onready var enemy_visuals: AnimatedSprite2D = $EnemyVisuals
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var nav_timer: Timer = $NavTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
const OUTLINE = "res://Shaders/outline.gdshader"
@onready var hurt_box_critical: Area2D = $HurtBoxCritical
@onready var hurt_box_normal: Area2D = $HurtBoxNormal

@onready var hit_box: Area2D = $HitBox
@onready var collision_polygon_2d: CollisionPolygon2D = $HitBox/CollisionPolygon2D

var player: CharacterBody2D
var level
var map_bounds
var current_speed: float
@export var speed_increments: float = 10.0
var number_of_investigations

var pre_investigation_pos: Vector2
var pre_investigation_rotation: float

var can_take_action: bool = true
var has_target: bool = false
var running: bool = false
var can_move: bool = true
var attacking: bool = false
var can_hear_player: bool = false
var is_investigating: bool = false
var transitioning: bool = false

var dead: bool = false

func _ready() -> void:
	# Connect to the Level's nav_ready signal
	face_player()
	pre_investigation_pos = position
	pre_investigation_rotation = rotation_degrees
	hit_box.monitoring = false
	
	current_speed = walking_speed
	level = get_tree().get_first_node_in_group("Level")
	if level:
		level.connect("nav_ready", Callable(self, "_on_nav_ready"))
		
	SignalManager.spawn_raven.connect(apply_outline)
	SignalManager.despawn_raven.connect(remove_outline)
	SignalManager.arrow_hit.connect(arrow_hit)
	
	print(enemy_patrol_type)
	
func apply_outline(_target_position: Vector2):
	var mat = ShaderMaterial.new()
	mat.shader = load(OUTLINE)
	enemy_visuals.material = mat
	
func remove_outline(_target_position: Vector2):
	enemy_visuals.material = null
	
func initialize_everything() -> void:
	print('initialize')
	player = get_tree().get_first_node_in_group("Player")
	current_enemy_state = enemy_states.PATROL
	set_animation("idle")

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	
	if can_take_action and !dead:
		check_state()
	
func set_animation(animation: String):
		enemy_visuals.play(animation)

func can_see_player():
	var direction_to_player = position.direction_to(player.position)
	var facing_direction = Vector2.RIGHT.rotated(rotation)
	var distance_to_player = position.distance_to(player.position)

	if direction_to_player.dot(facing_direction) > 0.5 and distance_to_player < enemy_vision_distance:
		return true
	return false

func get_random_position() -> Vector2:
	print('getting position')
	var random_position
	if enemy_patrol_type == patrol_type.MAPWIDE:
		# Random anywhere within the map bounds
		random_position = Vector2(
		randf_range(map_bounds.position.x, map_bounds.position.x + map_bounds.size.x),
		randf_range(map_bounds.position.y, map_bounds.position.y + map_bounds.size.y)
		)
	elif enemy_patrol_type == patrol_type.TIGHT:
		var offset_x = randf_range(100.0, 500.0)
		var offset_y = randf_range(100.0, 500.0)

		var random_position_x = position.x + (offset_x if randi() % 2 == 0 else -offset_x)
		var random_position_y = position.y + (offset_y if randi() % 2 == 0 else -offset_y)

		# Clamp the result so it stays within map_bounds
		var clamped_x = clamp(
			random_position_x,
			map_bounds.position.x,
			map_bounds.position.x + map_bounds.size.x
			)
		var clamped_y = clamp(
			random_position_y,
			map_bounds.position.y,
			map_bounds.position.y + map_bounds.size.y
			)

		random_position = Vector2(clamped_x, clamped_y)
	return random_position

func navigate_to_point():
	if !navigation_agent_2d.is_target_reached() and not navigation_agent_2d.is_navigation_finished():
		# World-space direction
		var nav_point_direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
		velocity = nav_point_direction * walking_speed

		# Smooth rotation (optional)
		var target_angle = nav_point_direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed)

		move_and_slide()
	else:
		if patrol_timer.is_stopped() and enemy_patrol_type != patrol_type.IDLE:
			set_animation("idle")
			print("Reached patrol target")
			patrol_timer.wait_time = randf_range(3.0, 10.0)
			patrol_timer.start()

func perform_patrol():
	if can_see_player():
		current_enemy_state = enemy_states.CHASE
		enemy_visuals.render_chase()
		return
	else:
		if can_hear_player: #This is jank as fuck
			current_enemy_state = enemy_states.INVESTIGATE
			return
	if !has_target and enemy_patrol_type != patrol_type.IDLE:
		print('Getting random patrol target')
		navigation_agent_2d.target_position = get_random_position()
		has_target = true

		if enemy_visuals.animation != "walk":
			set_animation("walk")
	navigate_to_point()
	
func generate_investigation_point():
	#Adjust these settings, probably create export variables
	var offset_x = randf_range(50.0, 200.0)
	var offset_y = randf_range(50.0, 200.0)

	var random_position_x = position.x + (offset_x if randi() % 2 == 0 else -offset_x)
	var random_position_y = position.y + (offset_y if randi() % 2 == 0 else -offset_y)

		# Clamp the result so it stays within map_bounds
	var clamped_x = clamp(
		random_position_x,
		map_bounds.position.x,
		map_bounds.position.x + map_bounds.size.x
		)
	var clamped_y = clamp(
		random_position_y,
		map_bounds.position.y,
		map_bounds.position.y + map_bounds.size.y
		)

	var random_position = Vector2(clamped_x, clamped_y)
	return random_position

#TODO - tweat this logic so the investigation isn't so random
func investigate():
	if !is_investigating:
		is_investigating = true
		number_of_investigations = randi() % 3 + 3
		print("Number of investigations set to %d" % number_of_investigations)
		
	if can_see_player():
		current_enemy_state = enemy_states.CHASE
		enemy_visuals.render_chase()
		return
	if !navigation_agent_2d.is_target_reached() and not navigation_agent_2d.is_navigation_finished():
		if enemy_visuals.animation != "run":
			set_animation("run")
			
		var nav_point_direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
		velocity = nav_point_direction * current_speed
		if current_speed < running_speed:
			current_speed += speed_increments
			print('New max speed: %d' % current_speed)
		var target_angle = nav_point_direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed)

		move_and_slide()
	else:
		if investigate_timer.is_stopped():
			# LIMIT THIS LOGIC WITH THE INVESTIGATION TIMER
			print("Reached target during investigation - start new cycle")
			if number_of_investigations > 0:
				number_of_investigations -= 1
				print("Number of investigations left %d" % number_of_investigations)
				
				var decision_event = randi() % 2
				#TODO fix this logic. It happens immediately with no delay
				if decision_event == 0:
					print('rotating not moving')
					var random_rotation = randf_range(0.0, TAU)
					rotation = lerp_angle(rotation, random_rotation, rotation_speed)
				else:
					print('moving and rotating')
					
				var random_time = randf_range(1.5, 3.0)
				investigate_timer.wait_time = random_time
				investigate_timer.start()
				set_animation("idle")
			else:
				investigate_timer.stop()
				is_investigating = false
				#ADD an intermediate go back to original location step
				var random_time = randf_range(1.5, 3.0)
				transition_timer.wait_time = random_time
				investigate_timer.stop()
				transition_timer.stop()
				transition_timer.start()
			
func chase_player():
	if !can_move:
		return

	if enemy_visuals.animation != "run":
		set_animation("run")

	if nav_timer.is_stopped():
		nav_timer.start()

	navigation_agent_2d.target_position = player.global_position

	var distance_to_player = position.distance_to(player.position)
	if distance_to_player < 100.0:
		print("Close enough to attack! Distance:", distance_to_player)
		current_enemy_state = enemy_states.ATTACK
		return

	# Only handle movement if navigation still has a path
	if !navigation_agent_2d.is_target_reached() and not navigation_agent_2d.is_navigation_finished():
		var nav_point_direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
		velocity = nav_point_direction * current_speed
		if current_speed < running_speed:
			current_speed += speed_increments

		var target_angle = nav_point_direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed)
		move_and_slide()

			
func face_player():
	if player == null:
		return
	var direction_to_player = (player.global_position - global_position).normalized()
	var target_angle = direction_to_player.angle()
	rotation = target_angle
	#rotation = lerp_angle(rotation, target_angle, rotation_speed)
			
func perform_attack():
	if player == null:
		return
	
	#Double check that this is working as expected
	if attacking:
		if enemy_visuals.frame == 4 or enemy_visuals.frame == 5:
			hit_box.monitoring = true
		else:
			hit_box.monitoring = false

	if !attacking:
		face_player()

		# If close enough, attack
		if position.distance_to(player.position) < 100:
			print('less than 100')
		if navigation_agent_2d.is_navigation_finished():
			attacking = true
			can_move = false
			enemy_visuals.play("slash")
		else:
				# If player moves out of range, go back to chasing
			current_enemy_state = enemy_states.CHASE

			
func transition():
	if enemy_visuals.animation != "walk":
		set_animation("walk")
		
	if !navigation_agent_2d.is_target_reached() and not navigation_agent_2d.is_navigation_finished():
		var nav_point_direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
		velocity = nav_point_direction * walking_speed
		var target_angle = nav_point_direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed)

		move_and_slide()
	else:
		print("transitioning back to original pos is complete")
		current_enemy_state = enemy_states.PATROL
		transitioning = false
		navigation_agent_2d.target_desired_distance = 100.0
		print('nav desired distance %f' % navigation_agent_2d.target_desired_distance)
		if enemy_patrol_type == patrol_type.IDLE:
			rotation = pre_investigation_rotation
			#rotation += lerp_angle(rotation, pre_investigation_rotation, rotation_speed)
		if enemy_visuals.animation == "walk" or enemy_visuals.animation == "run":
			set_animation("idle")

func check_state():
	match current_enemy_state:
		enemy_states.PATROL:
			perform_patrol()
		enemy_states.CHASE:
			chase_player()
		enemy_states.ATTACK:
			perform_attack()
		enemy_states.INVESTIGATE:
			investigate()
		enemy_states.TRANSITIONING:
			transition()
			
func event_to_change_state(event: String):
	if event == "hit" or event == "hear":
		if current_enemy_state == enemy_states.PATROL:
			current_enemy_state = enemy_states.INVESTIGATE

#TODO figure out a bug where when the knight is hit after already investigating the return point is not set
func arrow_hit(arrow_position: Vector2):
	print('Arrow hit enemy')
	
	if current_enemy_state != enemy_states.CHASE and current_enemy_state != enemy_states.ATTACK: 
		enemy_visuals.render_alert()
		
	if is_investigating:
		is_investigating = false
		investigate_timer.stop()
		
	if current_enemy_state == enemy_states.PATROL or current_enemy_state == enemy_states.TRANSITIONING:
		if enemy_patrol_type != patrol_type.IDLE:
			print('Assigning pre positionsawass')
			pre_investigation_pos = position
			pre_investigation_rotation = rotation_degrees
		current_enemy_state = enemy_states.INVESTIGATE
	navigation_agent_2d.target_position = arrow_position
	print("Setting arrow target")
	

func _on_nav_timer_timeout() -> void:
	if navigation_agent_2d.target_position != player.global_position:
		navigation_agent_2d.target_position = player.global_position
	nav_timer.start()


func _on_enemy_visuals_animation_finished() -> void:
	can_move = true
	attacking = false
	
func _on_patrol_timer_timeout() -> void:
	print('patrol timer went off')
	has_target = false
	patrol_timer.stop()
	
func _on_nav_ready(bounds: Rect2):
	initialize_everything()
	map_bounds = bounds
	print(map_bounds)
	
func _on_investigate_timer_timeout() -> void:
	print('investigation timer went off')
	navigation_agent_2d.target_position = generate_investigation_point()
	investigate_timer.stop()

#Enemy dies and everything is disabled - possibly add a dissolve effect and queue_free
func die():
	if dead:
		return
		
	print("Knight is now dead")
	dead = true
	
	#Disable the collisions and hit box/hurt box monitoring
	collision_shape_2d.set_deferred("disabled", true)
	hit_box.set_deferred("monitoring", false)
	hurt_box_critical.set_deferred("monitoring", false)
	hurt_box_normal.set_deferred("monitoring", false)
	
	enemy_visuals.play("die")
	z_index = -1
	nav_timer.stop()
	patrol_timer.stop()
	velocity = Vector2.ZERO
	can_move = false
	can_take_action = false


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		SignalManager.player_hit.emit(25.0)


func _on_transition_timer_timeout() -> void:
	transition_timer.stop()
	navigation_agent_2d.target_desired_distance = 10.0
	navigation_agent_2d.target_position = pre_investigation_pos
	current_enemy_state = enemy_states.TRANSITIONING
	print("investigation is over - return to patrol state")
