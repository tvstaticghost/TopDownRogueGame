extends Node2D

@onready var alerted_timer: Timer = $AlertedTimer
@onready var label: Label = $Sprite2D/Label

var need_to_fade: bool = false

@export var alpha_dec_amount: float = 0.1
@export var pop_scale_amount: float = 1.3
@export var pop_duration: float = 0.15

func _ready() -> void:
	label.self_modulate.a = 0
	label.scale = Vector2.ONE
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_parent().position
	position.y += -50
	
	if need_to_fade:
		label.self_modulate.a = clamp(label.self_modulate.a - alpha_dec_amount * delta * 60.0, 0.0, 1.0)
		if label.self_modulate.a <= 0:
			need_to_fade = false

func adjust_text(emotion: String):
	if emotion == "alert":
		label.text = "?"
	elif emotion == "chase":
		label.text = "!"
		
	label.self_modulate.a = 0
	label.scale = Vector2.ONE
	
	label.self_modulate.a = 1.0
	alerted_timer.start()
	
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE * pop_scale_amount, pop_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "self_modulate:a", 1.0, pop_duration * 0.75)

func _on_alerted_timer_timeout() -> void:
	need_to_fade = true
