extends SubViewport

@onready var side_camera: Camera2D = $SideCamera
@onready var camera_2d: Camera2D = $"../../../Camera2D"

func _ready() -> void:
	world_2d = get_world_2d()  # share the main world
	side_camera.make_current()

func _physics_process(_delta: float) -> void:
	side_camera.position = camera_2d.position
