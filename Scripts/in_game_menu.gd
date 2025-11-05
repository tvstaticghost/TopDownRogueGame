extends Control

#Containers
@onready var main_container: VBoxContainer = $TextureRect/MainContainer
@onready var settings_container: VBoxContainer = $TextureRect/SettingsContainer

#Buttons
@onready var settings_button: Button = $TextureRect/MainContainer/SettingsButton
@onready var quit_game_button: Button = $TextureRect/MainContainer/QuitGameButton

#Sliders
@onready var volume_slider: HSlider = $TextureRect/SettingsContainer/VolumeSlider
@onready var brightness_slider: HSlider = $TextureRect/SettingsContainer/BrightnessSlider
@onready var audio_manager: Node2D = $"../../AudioManager"

@export var bus_name: String
var bus_index: int

var world_environment: WorldEnvironment
var game_paused: bool = false
var transition_music: bool = false
var db_value

var forest_sounds
var max_music_scale: float = 1.0
var min_music_scale: float = 0.2
var current_music_scale: float = 1.0
var music_scale_amount: float = 0.01

func _ready() -> void:
	bus_index = AudioServer.get_bus_index("music")
	db_value = 100.0
	if audio_manager == null:
		print("Add the audio_manager scene to the level")
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		visible = !visible
		game_paused = !game_paused
		get_tree().paused = game_paused
		print('toggle menu')
		transition_music = !transition_music
		if forest_sounds == null:
			forest_sounds = audio_manager.get_child(0)
		
	if game_paused:
		if current_music_scale > min_music_scale:
			current_music_scale -= music_scale_amount
			forest_sounds.pitch_scale = current_music_scale
	elif !game_paused:
		if current_music_scale < max_music_scale:
			current_music_scale += music_scale_amount
			forest_sounds.pitch_scale = current_music_scale

func toggle_menu():
	main_container.visible = !main_container.visible
	settings_container.visible = !settings_container.visible

func _on_settings_button_pressed() -> void:
	toggle_menu()


func _on_back_button_pressed() -> void:
	toggle_menu()
	

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(volume_slider.value)
		)
